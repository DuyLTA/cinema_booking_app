# Reset Password Setup

App dang dung Supabase Auth de gui ma reset password ve email:

1. `resetPasswordForEmail(email)` gui email recovery.
2. Nguoi dung nhap ma OTP trong app.
3. `verifyOTP(type: OtpType.recovery)` tao recovery session ngan han.
4. `updateUser(UserAttributes(password: newPassword))` doi mat khau.
5. App sign out recovery session va yeu cau dang nhap lai.

## Supabase Dashboard

### 1. Bat email/password auth

Vao Supabase Dashboard:

- Authentication
- Providers
- Email
- Bat Email provider va Password sign-in

### 2. Doi Reset Password template sang OTP

Vao:

- Authentication
- Email Templates
- Reset password

Template can co `{{ .Token }}` de Supabase gui ma 6 chu so thay vi chi gui link.

Subject goi y:

```text
Your Cine Booking password reset code
```

Body goi y:

```html
<h2>Reset your Cine Booking password</h2>
<p>Use this code in the app to reset your password:</p>
<p style="font-size: 28px; font-weight: 700; letter-spacing: 6px;">{{ .Token }}</p>
<p>This code expires shortly. If you did not request this, you can ignore this email.</p>
```

Supabase cung cap cac bien email template nhu `{{ .ConfirmationURL }}`, `{{ .Token }}`, `{{ .TokenHash }}`, `{{ .SiteURL }}` va `{{ .RedirectTo }}`. Luong hien tai cua app can `{{ .Token }}`.

### 3. Cau hinh SMTP de gui mail that

Neu chua cau hinh custom SMTP, Supabase default SMTP chi phu hop test/noi bo va co gioi han gui. De gui mail that cho user bat ky, vao:

- Project Settings
- Authentication
- SMTP Settings
- Enable Custom SMTP

Dien thong tin SMTP tu nha cung cap email, vi du Resend, AWS SES, Postmark, SendGrid, Brevo:

- Sender email / From address: `no-reply@your-domain.com`
- Sender name: `Cine Booking`
- SMTP host
- SMTP port, thuong la `587`
- SMTP user
- SMTP password

Nen cau hinh SPF, DKIM, DMARC cho domain gui mail de tang deliverability.

## Test flow

1. Tao user that trong Supabase Auth bang email ban co the nhan mail.
2. Mo app o Login screen.
3. Nhap email vao o `EMAIL OR PHONE`.
4. Bam `Forgot Password?`.
5. Kiem tra inbox/spam, lay code trong email.
6. Nhap code + mat khau moi + confirm password.
7. Bam `Update`.
8. Dang nhap lai bang mat khau moi.

## Luu y

- Luong reset password hien tai chi chap nhan email, khong chap nhan phone, vi ma duoc gui qua email.
- Neu email khong ve, kiem tra SMTP, spam folder, rate limit va email template co `{{ .Token }}` hay khong.
- Neu gap loi "Email address not authorized", nghia la project dang dung default SMTP cua Supabase va email nhan khong nam trong team/project duoc phep test.
