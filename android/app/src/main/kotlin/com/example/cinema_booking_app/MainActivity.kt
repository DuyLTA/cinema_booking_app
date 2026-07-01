package com.example.cinema_booking_app

import android.Manifest
import android.content.pm.PackageManager
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val locationChannel = "cinema_booking_app/location"
    private val locationPermissionRequestCode = 2407
    private val freshLocationTimeoutMs = 10000L
    private val maxLastKnownAgeMs = 5 * 60 * 1000L
    private var pendingLocationResult: MethodChannel.Result? = null
    private var pendingLocationListener: LocationListener? = null
    private val locationHandler = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            locationChannel
        ).setMethodCallHandler { call, result ->
            if (call.method == "getCurrentLocation") {
                getCurrentLocation(result)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getCurrentLocation(result: MethodChannel.Result) {
        val permissionGranted = if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            true
        } else {
            checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) ==
                PackageManager.PERMISSION_GRANTED ||
                checkSelfPermission(Manifest.permission.ACCESS_COARSE_LOCATION) ==
                    PackageManager.PERMISSION_GRANTED
        }

        if (!permissionGranted) {
            pendingLocationResult = result
            requestPermissions(
                arrayOf(
                    Manifest.permission.ACCESS_FINE_LOCATION,
                    Manifest.permission.ACCESS_COARSE_LOCATION
                ),
                locationPermissionRequestCode
            )
            return
        }

        requestFreshLocation(result)
    }

    private fun requestFreshLocation(result: MethodChannel.Result) {
        val locationManager = getSystemService(LOCATION_SERVICE) as LocationManager
        val providers = listOf(
            LocationManager.GPS_PROVIDER,
            LocationManager.NETWORK_PROVIDER
        ).filter { provider ->
            try {
                locationManager.isProviderEnabled(provider)
            } catch (_: Exception) {
                false
            }
        }

        if (providers.isEmpty()) {
            result.success(readRecentLastKnownLocation(locationManager))
            return
        }

        var completed = false
        lateinit var timeout: Runnable

        fun complete(location: Location?) {
            if (completed) return
            completed = true
            pendingLocationListener?.let { listener ->
                try {
                    locationManager.removeUpdates(listener)
                } catch (_: SecurityException) {
                }
            }
            pendingLocationListener = null
            locationHandler.removeCallbacks(timeout)
            result.success(
                location?.let { mapLocation(it) }
                    ?: readRecentLastKnownLocation(locationManager)
            )
        }

        val listener = LocationListener { location -> complete(location) }
        pendingLocationListener = listener
        timeout = Runnable { complete(null) }

        try {
            providers.forEach { provider ->
                locationManager.requestSingleUpdate(provider, listener, Looper.getMainLooper())
            }
            locationHandler.postDelayed(timeout, freshLocationTimeoutMs)
        } catch (_: SecurityException) {
            complete(null)
        } catch (_: IllegalArgumentException) {
            complete(null)
        }
    }

    private fun readRecentLastKnownLocation(locationManager: LocationManager): Map<String, Double>? {
        val now = System.currentTimeMillis()
        val providers = listOf(
            LocationManager.GPS_PROVIDER,
            LocationManager.NETWORK_PROVIDER,
            LocationManager.PASSIVE_PROVIDER
        )

        val location = providers
            .mapNotNull { provider ->
                try {
                    locationManager.getLastKnownLocation(provider)
                } catch (_: SecurityException) {
                    null
                } catch (_: IllegalArgumentException) {
                    null
                }
            }
            .filter { now - it.time <= maxLastKnownAgeMs }
            .maxByOrNull { it.time }

        return location?.let { mapLocation(it) }
    }

    private fun mapLocation(location: Location): Map<String, Double> {
        return mapOf("latitude" to location.latitude, "longitude" to location.longitude)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        if (requestCode != locationPermissionRequestCode) return

        val result = pendingLocationResult ?: return
        pendingLocationResult = null

        val granted = grantResults.any { it == PackageManager.PERMISSION_GRANTED }
        if (granted) {
            requestFreshLocation(result)
        } else {
            result.success(null)
        }
    }
}
