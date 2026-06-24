# Cinema Booking VNPay Sandbox Server

Backend demo tao VNPay Sandbox payment URL cho Flutter app.

Khong dua `VNPAY_HASH_SECRET` vao Flutter. Secret chi nam trong backend `.env`.

## Setup

```bash
cd backend/vnpay-server
npm install
copy .env.example .env
```

Sua `.env`:

```env
PORT=8080
APP_DEEP_LINK=cinemabookingapp://payment-result
VNPAY_RETURN_URL=http://10.0.2.2:8080/api/vnpay/return
VNPAY_TMN_CODE=your_sandbox_tmn_code
VNPAY_HASH_SECRET=your_sandbox_hash_secret
VNPAY_HOST=https://sandbox.vnpayment.vn
VNPAY_FORCE_FAIL=false
```

Chay server:

```bash
npm run dev
```

Kiem tra:

```bash
curl http://localhost:8080/health
```

## Flutter config

Android emulator dung:

```env
VNPAY_BACKEND_URL=http://10.0.2.2:8080
```

May that dung IP LAN cua may chay backend:

```env
VNPAY_BACKEND_URL=http://192.168.1.x:8080
```

## API

`POST /api/vnpay/create-payment-url`

```json
{
  "bookingId": "CB123",
  "amount": 195000,
  "orderInfo": "Thanh toan ve phim CB123"
}
```

Response:

```json
{
  "paymentUrl": "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html?...",
  "txnRef": "CB123..."
}
```

## Return flow

VNPay return URL phai tro ve backend:

```env
VNPAY_RETURN_URL=http://10.0.2.2:8080/api/vnpay/return
```

Sau khi backend verify return params cua VNPay, backend se tu dong mo lai app bang:

```env
APP_DEEP_LINK=cinemabookingapp://payment-result
```

Flutter lang nghe deep link nay va day nguoi dung sang man hinh booking successful hoac payment error.

## Demo payment failed

Cach nhanh nhat de demo fail chac chan:

```env
VNPAY_FORCE_FAIL=true
```

Sau do restart backend. Ban van thanh toan tren VNPay sandbox nhu binh thuong, nhung khi VNPay return ve backend, backend se gui deep link `status=failed` ve app de hien man hinh payment error.

Cach fail theo sandbox that: tai trang VNPay, bam huy giao dich hoac nhap sai thong tin/OTP neu sandbox cho phep. Khi VNPay tra response code khac `00`, app se hien payment error.

## Luu y

- De trong `VNPAY_BANK_CODE` neu muon VNPay tu hien cac phuong thuc test duoc ho tro.
- VNPay yeu cau amount gui len la VND, thu vien se build URL theo config.
- Khong dua `VNPAY_HASH_SECRET` vao Flutter app.
