import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_cine_marquee_app_bar.dart';
import '../../widgets/custom_sign_in_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return const ProfileScreen();
  }

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthProvider>().loadCustomerProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.screenBackground,
      appBar: CustomCineMarqueeAppBar(
        leadingImagePath: ImageConstant.imgButton,
        titleText: 'PROFILE',
        actionImagePath: ImageConstant.imgButtonDeepOrange100,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final customer = authProvider.currentCustomer;
          final user = authProvider.currentUser;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MY ACCOUNT',
                  style: TextStyleHelper.instance.title18RegularBebasNeue
                      .copyWith(letterSpacing: 2),
                ),
                SizedBox(height: 16.h),
                _buildProfileCard(
                  fullName: customer?.fullName ?? 'Guest',
                  email: customer?.email ?? user?.email ?? '-',
                  phone: customer?.phone ?? '-',
                  membership: (customer?.membershipLevel ?? 'regular')
                      .toUpperCase(),
                ),
                SizedBox(height: 32.h),
                CustomSignInButton(
                  text: 'LOG OUT',
                  width: double.infinity,
                  isLoading: authProvider.isLoading,
                  onPressed: authProvider.isLoading
                      ? null
                      : () => _onLogoutPressed(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileCard({
    required String fullName,
    required String email,
    required String phone,
    required String membership,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.h),
      decoration: BoxDecoration(
        color: appTheme.gray_900_cc,
        borderRadius: BorderRadius.circular(12.h),
        border: Border.all(color: appTheme.color19A48B, width: 1.h),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileRow('FULL NAME', fullName),
          SizedBox(height: 16.h),
          _buildProfileRow('EMAIL', email),
          SizedBox(height: 16.h),
          _buildProfileRow('PHONE', phone),
          SizedBox(height: 16.h),
          _buildProfileRow('MEMBERSHIP', membership),
        ],
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyleHelper.instance.label10RegularBebasNeue.copyWith(
            letterSpacing: 1,
            color: appTheme.gray_500,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyleHelper.instance.title16RegularDMSans.copyWith(
            color: appTheme.gray_300,
          ),
        ),
      ],
    );
  }

  Future<void> _onLogoutPressed(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();

    if (!context.mounted) return;

    NavigatorService.navigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRoutes.cinemaLoginScreen,
      (route) => false,
    );
  }
}
