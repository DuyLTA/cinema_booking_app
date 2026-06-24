# Agent Context - Cinema Booking App

File nay la ban tom tat dung de bat dau nhanh mot phien lam viec moi. Toan bo tieu chi chuyen sau ve code style, cau truc, state, UI, navigation, model, error handling va checklist kiem tra da duoc gom tai day de khong can doc them file khac.

## 1. Muc Tieu

- Uu tien code de doc, de review, de sua va de mo rong.
- Giu dung theme hien tai: cinema dark theme, do ruou, vang kem, nen toi, mobile-first.
- Khong gom UI, logic va du lieu vao mot file lon.
- Muc tieu lon nhat cua moi change:
  - Cau truc ro rang.
  - UI tach thanh widget nho.
  - Logic tach khoi UI.

## 2. Cau Truc Project

- Man hinh dat trong `lib/presentation/`.
- Widget dung chung dat trong `lib/widgets/`.
- Model dat trong `lib/models/`.
- Service goi Supabase/API dat trong `lib/services/`.
- Provider/state app-level dat trong `lib/providers/`.
- Route cap nhat tai `lib/routes/app_routes.dart`.
- Theme, text style, mau sac va asset constants dung cac file co san trong `lib/theme/` va `lib/core/utils/`.
- Khi them route moi, phai khai bao ro rang trong `app_routes.dart`.

## 3. Code Style

- Ten class, bien, ham phai co y nghia.
- File dung snake_case, class dung PascalCase, bien/ham dung camelCase.
- Uu tien `const` constructor khi co the.
- Chay Dart formatter cho file vua sua khi co the.
- Khong de warning/error nghiem trong trong pham vi file vua sua.
- Comment chi dung cho doan kho hieu hoac quan trong.

## 4. Tach UI Va Logic

- Tranh de mot `build()` qua dai.
- Tach UI thanh widget/helper method ro vai tro: header, card, list item, empty state, action button.
- Neu UI lap lai, dua vao widget dung chung thay vi copy-paste.
- Widget con nhan du lieu qua constructor, khong phu thuoc qua nhieu vao bien ngoai.
- Validate, goi API, xu ly response va mapping data nam trong provider/service/model phu hop.
- Khong goi API truc tiep trong `build()`.
- Khong dat qua nhieu logic nghiep vu trong `onPressed`.

## 5. State Va Navigation

- Dung `setState()` cho state cuc bo don gian.
- Dung `Provider` cho state lien quan nhieu widget/man hinh.
- Khong lam dung bien global.
- Moi flow lay data can co loading, success, empty va error neu phu hop.
- Navigation phai ro rang, back button phai hoat dong dung.
- Khi truyen du lieu giua man hinh, uu tien model/id ro rang thay vi Map tuy tien.
- Phan biet route top-level cua `MaterialApp` voi nested navigator trong `CinemaHomeScreen`.

## 6. Model Va Du Lieu

- Entity chinh phai co model ro rang, khong xu ly bang Map rai rac o UI.
- Neu doc/ghi Supabase JSON, model can co mapping/parsing tap trung.
- Du lieu truyen giua cac man hinh phai null-safe va co cau truc ro rang.
- Khong hard-code duong dan anh/API endpoint rai rac.
- Khong dua thong tin nhay cam vao source code; dung `.env` khi can.

## 7. Xu Ly Loi

- Form phai co validate co ban truoc khi submit.
- Goi API/Supabase can co try-catch hoac xu ly error tai service/provider.
- Loi hien thi bang thong bao than thien, uu tien `AppSnackBar`.
- Khong de app crash khi du lieu null, rong, mat mang hoac server loi.
- Can co empty state khi danh sach khong co du lieu.

## 8. Responsive Va Hieu Nang

- Mobile-first, luon can nhac man hinh nho.
- Dung `SafeArea`, `Expanded`, `Flexible`, `SingleChildScrollView`, `ListView` dung cho.
- Tranh hard-code width/height qua cung neu co nguy co overflow.
- Text dai phai co `maxLines`, `overflow` hoac layout linh hoat.
- Khong de RenderFlex overflow tren man hinh nho.
- Dung `ListView.builder()`/builder pattern cho danh sach dai.
- Khong goi API lap lai trong `build()`.
- Tranh rebuild toan bo man hinh khi chi mot phan nho thay doi.

## 9. Chu De UI Dinh Huong

- Dark cinema theme la mac dinh.
- Mau sac chu dao: den, nau dam, do ruou, vang kem.
- Typography hien tai la mot phan cua visual identity, can giu nhat quan.
- Trang sang trong, gia ve, profile, booking, payment phai cung mot ngon ngu giao dien.
- Khong copy-paste UI/logic sang nhieu noi neu co the tach thanh widget dung chung.

## 10. Lenh Hay Dung

```powershell
flutter pub get
flutter analyze
flutter run
flutter run -d chrome
dart format <file>
```

Luu y:
- `flutter analyze` co the fail neu co thu muc root `theme/` cu chua tracking dung. Thu muc dung that cua app la `lib/theme/`.
- Khi can analyzer sach, xu ly hoac bo thu muc root `theme/` cu neu no khong con dung.

## 11. Auth Va Backend

- Backend hien tai dung Supabase: Auth + PostgreSQL.
- State management dung `provider`.
- Auth flow quan trong:
  - Login bang email hoac phone + password.
  - Register bang email/password/full name/phone.
  - Reset password qua email code.
  - Google/Apple co the duoc mo rong neu co config.
- Files quan trong:
  - `lib/services/auth_service.dart`
  - `lib/providers/auth_provider.dart`
  - `lib/presentation/cinema_login_screen/provider/cinema_login_provider.dart`
  - `lib/presentation/cinema_register_screen/provider/cinema_register_provider.dart`

## 12. Main App Map

- `lib/main.dart`: load `.env`, initialize Supabase, setup providers, hien `OnboardingScreen`.
- `lib/routes/app_routes.dart`: route source of truth.
- `lib/core/app_export.dart`: barrel export cho provider/routes/theme/utils/snackbar.
- `lib/core/utils/image_constant.dart`: path assets.
- `lib/core/utils/app_snackbar.dart`: snackbar dung chung.
- `lib/theme/`: theme va text style.
- `lib/widgets/`: custom widgets dung chung.
- `lib/models/`: model global.
- `lib/services/`: service goi Supabase.
- `lib/providers/`: provider app-level.
- `lib/presentation/`: screens, screen providers, screen models.

## 13. Tinh Nang Hien Tai Da Co

- Onboarding co 3 slide va hien truoc khi vao app.
- Home, Movies, Profile da co header chung.
- Profile da tach sang route rieng de tranh loi bottom sheet.
- Register co luong confirm code qua email.
- VNPay flow, booking success/fail, ticket persistence va select seat/session da co.
- Tickets tab da co luong hien ticket va chi tiet ticket.

## 14. Sap Xep Hien Tai Can Nho

- Root workspace: `c:\Users\Admin\cinema_booking_app`
- File docs goc chuyen sau truoc day da duoc nen lai vao day.
- Neu can hieu chi tiet DB, xem them cac file SQL/setup co san trong project.

## 15. Checklist Truoc Khi Ket Thuc

- Chay formatter cho file vua sua khi co the.
- Chay analyze pham vi file/tinh nang neu co the.
- Kiem tra manual cac flow chinh bi anh huong: validate form, loading/error/empty, navigation/back, data hien thi.
- Neu khong chay duoc lenh kiem tra, phai noi ro ly do trong final response.

## 16. Loi Can Tranh Manh

- Viet gan nhu toan bo app trong `main.dart`.
- Mot man hinh co `build()` qua dai, kho review.
- Copy-paste UI lap lai o nhieu man hinh.
- Khong co model, dung Map/du lieu roi rac khap noi.
- Goi API truc tiep trong `build()`.
- Khong xu ly loi mang, loi du lieu rong, null data.
- Navigation loi hoac back khong dung.
- UI overflow tren man hinh nho.
- De lai warning/error nghiem trong trong code vua sua.

