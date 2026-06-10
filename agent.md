# Agent Notes - Cinema Booking App

Tai lieu nay tom tat nhanh du an de tiep tuc phat trien ma khong phai doc lai toan bo repo tu dau.

## Tong quan

- Du an la ung dung Flutter dat ve xem phim, target mobile/web/desktop theo scaffold mac dinh cua Flutter.
- Backend hien tai dung Supabase: Auth + PostgreSQL tables.
- State management dung `provider`.
- UI dang co phong cach cinema dark theme, nhieu widget/screen co ve duoc sinh tu design tool va da duoc noi mot phan voi backend.
- File env can co o root: `.env` voi `SUPABASE_URL` va `SUPABASE_KEY`. File nay duoc khai bao trong `pubspec.yaml` assets.

## Stack va dependencies chinh

- Flutter / Dart SDK: `environment sdk: ^3.12.1`
- `supabase_flutter`
- `flutter_dotenv`
- `provider`
- `cached_network_image`
- `flutter_svg`
- `url_launcher`

Lenh thuong dung:

```powershell
flutter pub get
flutter analyze
flutter test
flutter run
flutter run -d chrome
```

## Cau truc thu muc quan trong

- `lib/main.dart`: entrypoint, load `.env`, initialize Supabase, setup `MultiProvider`, splash auth check.
- `lib/routes/app_routes.dart`: routing dang dung that trong app.
- `lib/core/routes/app_routes.dart`: hien chi la TODO, khong phai route dang dung.
- `lib/core/app_export.dart`: barrel export cho Provider, routes, theme, utils.
- `lib/core/utils/`: navigator, responsive sizing, image constants, mapper UI.
- `lib/theme/`: theme helper va text style helper.
- `lib/widgets/`: custom widgets dung chung cho UI.
- `lib/models/`: model du lieu Supabase/global (`MovieModel`, `CustomerModel`, `CinemaEntityModel`).
- `lib/services/`: lop goi Supabase (`AuthService`, `MovieService`, `CinemaService`, `ShowtimeService`).
- `lib/providers/`: provider app-level (`AuthProvider`, `MovieProvider`).
- `lib/presentation/`: screen-level UI, model va provider rieng cho tung man hinh.
- `assets/images/`, `assets/fonts/`: anh SVG/PNG va font app.
- `SUPABASE_SETUP.md`, `BACKEND_API.md`, `simple_auth_movie_flow.md`, `cinema_booking_database_spec_short.md`: tai lieu backend/schema/flow.

## Luong khoi dong app

1. `main()` goi `dotenv.load(fileName: ".env")`.
2. Doc `SUPABASE_URL` va `SUPABASE_KEY`; thieu se throw exception.
3. Goi `Supabase.initialize(...)`.
4. `MyApp` tao `MultiProvider`:
   - `AuthProvider`
   - `MovieProvider`
5. `MaterialApp` dung `home: SplashScreen()` va `routes: AppRoutes.routes`.
6. `SplashScreen` goi `AuthProvider.checkSession()`.
7. Neu da login -> `AppRoutes.cinemaHomeScreen`; neu chua login -> `AppRoutes.cinemaLoginScreen`.

## Routing hien tai

File dung chinh: `lib/routes/app_routes.dart`.

Routes dang khai bao:

- `/login` va `/cinema_login_screen` -> `CinemaLoginScreen`
- `/cinema_register_screen` -> `CinemaRegisterScreen`
- `/cinema_home_screen` -> `CinemaHomeScreen`
- `/movie_detail_screen` -> `MovieDetailScreen`
- `/app_navigation_screen` -> `AppNavigationScreen`

`CinemaHomeScreen` co nested `Navigator` rieng cho bottom navigation:

- `cinemaHomeScreenInitialPage`
- `movieListScreen`
- `movieDetailScreen`
- `profileScreen`

Khi them route moi, uu tien cap nhat `lib/routes/app_routes.dart`. Can can nhac xoa/hoan thien `lib/core/routes/app_routes.dart` vi file nay dang de TODO va de gay nham lan.

## Backend/Supabase dang dung

Bang dang duoc code goi truc tiep:

- `customers`
- `movies`
- `cinemas`
- `showtimes`

Tai lieu schema day du hon nam o `cinema_booking_database_spec_short.md`, gom cac bang booking nhu rooms, seats, showtime_seats, bookings, tickets, transactions, foods, coupons, notifications, chat.

### AuthService

File: `lib/services/auth_service.dart`

Chuc nang:

- Dang ky bang Supabase Auth, sau do insert profile vao `customers`.
- Dang nhap email/password.
- Dang nhap bang phone bang cach resolve phone -> email trong `customers`.
- Cache `CustomerModel` theo user id.
- Validate/refresh session khi app khoi dong.
- Logout va reset password.

### MovieService

File: `lib/services/movie_service.dart`

Chuc nang:

- Load movie theo `status`: `now_showing`, `coming_soon`, `ended`.
- Load now showing / coming soon / all movies.
- Get movie by id.
- Search movie theo title/genre, hien tai filter client-side sau khi query.
- Get movie by genre.

### CinemaService va ShowtimeService

- `CinemaService.getAllCinemas()` load bang `cinemas`.
- `ShowtimeService.getMovieIdsForCinema(...)` load `showtimes` active, co filter ngay o client-side neu truyen `date`.

## State management

App-level providers:

- `AuthProvider`: quan ly login/register/logout/session/current customer.
- `MovieProvider`: quan ly danh sach phim, search, status tab, detail lookup.

Screen-level providers:

- `CinemaLoginProvider`: controller/focus/validation va goi `AuthProvider.login`.
- `CinemaRegisterProvider`: controller/focus/validation va goi `AuthProvider.register`.
- `CinemaHomeProvider`: load movie sections + cinemas, map backend model sang UI model.
- `MovieDetailProvider`: load movie detail qua `MovieProvider.getMovieById`.
- Cac provider/model khac trong `presentation/*/provider` va `presentation/*/models` chu yeu phuc vu UI.

Quy uoc hien tai la screen builder thuong tao provider rieng bang `ChangeNotifierProvider`, con data dung chung thi lay tu provider app-level.

## UI va theme

- App dung dark cinema palette trong `lib/theme/theme_helper.dart`.
- Text styles nam trong `lib/theme/text_style_helper.dart`.
- Responsive sizing dung extension/helper trong `lib/core/utils/size_utils.dart`; UI hay dung `.h`.
- Anh/icon constants nam o `lib/core/utils/image_constant.dart`.
- Widget custom quan trong: `CustomImageView`, `CustomEditText`, `CustomSignInButton`, `CustomIconButton`, `CustomBottomBar`, `CustomBookButton`, `CustomCineMarqueeAppBar`.
- UI dang co font: Bebas Neue, Bodoni Moda, DM Sans.

Khi sua UI, nen giu phong cach hien tai: nen toi, do ruou vang/kem, typography cinema, va tai su dung custom widgets/theme thay vi viet style moi le te.

## Tinh nang dang co

- Splash/auth check.
- Login email hoac phone + password.
- Register email/password/full name/phone.
- Home screen co now showing, coming soon, cinemas, offers.
- Movie list va movie detail.
- Profile tab co route nested trong home.
- Load movies/cinemas tu Supabase.

## Placeholder/chua hoan thien

- Google Sign-In: dang show SnackBar "coming soon".
- Apple Sign-In: dang show SnackBar "coming soon".
- Forgot password UI flow: dang show SnackBar, chua goi reset that.
- Tickets tab trong bottom bar tam tro ve home initial page.
- Seat selection, food/drink, coupon, payment, notification, chat support moi co trong tai lieu/schema, chua co implementation day du.
- `test/widget_test.dart` van la counter smoke test mac dinh va khong phu hop voi app hien tai.
- Mot so file root co ve la artifact/tam thoi: `flutter_login_screen`, `flutter_launch_screen`, `tmp_test_import.dart`, `tmp_test_import2.dart`, `movie_detail.svg` rong.
- Trong code con mot so `print('DEBUG: ...')` o movie detail/home routing, nen thay bang logging/bo di khi on dinh.

## Luu y khi phat trien tiep

- Dung `lib/routes/app_routes.dart` lam source of truth cho route.
- Khi them bang Supabase moi, tao model trong `lib/models/`, service trong `lib/services/`, provider neu can state UI.
- Khi query Supabase, nen them timeout nhu cac service hien tai.
- Khong hardcode credentials; dung `.env`.
- Khi them screen moi, can nhac pattern:
  - `presentation/<screen>/<screen>.dart`
  - `presentation/<screen>/provider/<screen>_provider.dart`
  - `presentation/<screen>/models/<screen>_model.dart`
- Uu tien tai su dung mapper trong `lib/core/utils/movie_ui_mapper.dart` khi can convert model backend sang model UI.
- Neu them booking flow, bat dau tu schema trong `cinema_booking_database_spec_short.md` va can tao services theo thu tu: cinemas/rooms -> showtimes -> seats/showtime_seats -> bookings/tickets/transactions.
- Can than voi nested navigator trong `CinemaHomeScreen`: route trong bottom tab khong nhat thiet la route top-level cua `MaterialApp`.

## Viec nen lam gan tiep theo

1. Sua/xoa `test/widget_test.dart` vi test counter hien tai se khong dung voi app nay.
2. Don cac file artifact/tam neu khong can: `tmp_test_import*.dart`, root design dump files.
3. Hoan thien forgot password bang `AuthService.resetPassword`.
4. Thay `print DEBUG` bang logging hoac remove.
5. Implement Tickets tab bang booking history hoac booking flow dau tien.
6. Viet service/model cho showtime detail va seat selection.
7. Kiem tra lai RLS Supabase cho cac bang moi truoc khi noi UI.

## Tai lieu tham chieu trong repo

- `README.md`: tong quan du an va setup co ban.
- `QUICK_START.md`: setup backend Supabase nhanh.
- `SUPABASE_SETUP.md`: SQL tao bang customers/movies, RLS, sample data.
- `BACKEND_API.md`: API service/provider hien co.
- `simple_auth_movie_flow.md`: yeu cau flow don gian login/register/movie list.
- `cinema_booking_database_spec_short.md`: schema rong cho ung dung cinema booking day du.
