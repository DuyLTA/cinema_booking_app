import cors from 'cors';
import 'dotenv/config';
import express from 'express';
import { HashAlgorithm, ProductCode, VNPay, VnpLocale, ignoreLogger } from 'vnpay';

const app = express();
const port = Number(process.env.PORT || 8080);

app.use(cors());
app.use(express.json());

const requiredEnv = ['VNPAY_TMN_CODE', 'VNPAY_HASH_SECRET'];

function assertConfig() {
  const missing = requiredEnv.filter((key) => !process.env[key]);
  if (missing.length > 0) {
    throw new Error(`Missing VNPay config: ${missing.join(', ')}`);
  }
}

function createVnPayClient() {
  assertConfig();

  return new VNPay({
    tmnCode: process.env.VNPAY_TMN_CODE,
    secureSecret: process.env.VNPAY_HASH_SECRET,
    vnpayHost: process.env.VNPAY_HOST || 'https://sandbox.vnpayment.vn',
    testMode: true,
    hashAlgorithm: HashAlgorithm.SHA512,
    enableLog: false,
    loggerFn: ignoreLogger,
  });
}

function clientIp(req) {
  const forwarded = req.headers['x-forwarded-for'];
  if (typeof forwarded === 'string' && forwarded.trim().length > 0) {
    return forwarded.split(',')[0].trim();
  }
  return req.socket.remoteAddress?.replace('::ffff:', '') || '127.0.0.1';
}

function sanitizeOrderInfo(value) {
  return String(value || 'Thanh toan ve phim')
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-zA-Z0-9 #:-]/g, '')
    .slice(0, 180);
}

function formatVnPayDate(date) {
  const pad = (value) => String(value).padStart(2, '0');
  return [
    date.getFullYear(),
    pad(date.getMonth() + 1),
    pad(date.getDate()),
    pad(date.getHours()),
    pad(date.getMinutes()),
    pad(date.getSeconds()),
  ].join('');
}

function createTxnRef(rawBookingId) {
  const bookingId = String(rawBookingId || 'CB')
    .replace(/[^a-zA-Z0-9]/g, '')
    .slice(0, 32);
  const random = Math.random().toString(36).slice(2, 8).toUpperCase();
  return `${bookingId}${Date.now()}${random}`.slice(0, 100);
}

function escapeHtml(value) {
  return String(value || '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

function buildAppReturnLink({ isSuccess, message, query }) {
  const appDeepLink = process.env.APP_DEEP_LINK || 'cinemabookingapp://payment-result';
  const url = new URL(appDeepLink);
  url.searchParams.set('status', isSuccess ? 'success' : 'failed');
  url.searchParams.set('txnRef', String(query.vnp_TxnRef || ''));
  url.searchParams.set('responseCode', String(query.vnp_ResponseCode || ''));
  url.searchParams.set('message', message || '');
  return url.toString();
}

app.get('/health', (req, res) => {
  res.json({ ok: true, service: 'cinema-booking-vnpay-server' });
});

app.post('/api/vnpay/create-payment-url', (req, res) => {
  try {
    const amount = Number(req.body.amount);
    const bookingId = String(req.body.bookingId || Date.now());
    const txnRef = createTxnRef(bookingId);

    if (!Number.isFinite(amount) || amount <= 0) {
      return res.status(400).json({ message: 'amount must be positive VND' });
    }

    const vnpay = createVnPayClient();
    const paymentParams = {
      vnp_Amount: Math.round(amount),
      vnp_IpAddr: clientIp(req),
      vnp_ReturnUrl:
        req.body.returnUrl ||
        process.env.VNPAY_RETURN_URL ||
        `http://localhost:${port}/api/vnpay/return`,
      vnp_TxnRef: txnRef,
      vnp_OrderInfo: sanitizeOrderInfo(
        req.body.orderInfo || `Thanh toan don hang ${txnRef}`,
      ),
      vnp_OrderType: ProductCode.Other,
      vnp_Locale: VnpLocale.VN,
      vnp_ExpireDate: formatVnPayDate(new Date(Date.now() + 15 * 60 * 1000)),
    };

    const bankCode = process.env.VNPAY_BANK_CODE?.trim();
    if (bankCode) {
      paymentParams.vnp_BankCode = bankCode;
    }

    const paymentUrl = vnpay.buildPaymentUrl(paymentParams);

    return res.json({ paymentUrl, txnRef });
  } catch (error) {
    console.error(error);
    return res.status(500).json({
      message: error instanceof Error ? error.message : 'Cannot create payment URL',
    });
  }
});

app.get('/api/vnpay/return', (req, res) => {
  try {
    const vnpay = createVnPayClient();
    const verify = vnpay.verifyReturnUrl(req.query);
    const forceFail = process.env.VNPAY_FORCE_FAIL === 'true';
    const isSuccess = verify.isSuccess && !forceFail;
    const message = forceFail ? 'Demo forced payment failure' : verify.message;

    const title = isSuccess ? 'Payment successful' : 'Payment failed';
    const color = isSuccess ? '#16a34a' : '#dc2626';
    const appReturnLink = buildAppReturnLink({
      isSuccess,
      message,
      query: req.query,
    });

    return res.send(`
      <!doctype html>
      <html lang="vi">
        <head>
          <meta charset="utf-8" />
          <meta name="viewport" content="width=device-width, initial-scale=1" />
          <title>${title}</title>
          <style>
            body { font-family: Arial, sans-serif; padding: 32px; text-align: center; }
            h1 { color: ${color}; }
            code { display: block; margin-top: 12px; color: #555; word-break: break-all; }
            a {
              display: inline-block;
              margin-top: 24px;
              padding: 12px 18px;
              border-radius: 8px;
              background: #8b0015;
              color: #fff;
              text-decoration: none;
            }
          </style>
          <script>
            setTimeout(function () {
              window.location.href = ${JSON.stringify(appReturnLink)};
            }, 700);
          </script>
        </head>
        <body>
          <h1>${title}</h1>
          <p>${escapeHtml(message)}</p>
          <code>TxnRef: ${escapeHtml(req.query.vnp_TxnRef)}</code>
          <code>ResponseCode: ${escapeHtml(req.query.vnp_ResponseCode)}</code>
          <p>Returning to the Cinema Booking app...</p>
          <a href="${escapeHtml(appReturnLink)}">Open Cinema Booking app</a>
        </body>
      </html>
    `);
  } catch (error) {
    console.error(error);
    return res.status(500).json({
      message: error instanceof Error ? error.message : 'Cannot verify VNPay return',
    });
  }
});

app.listen(port, () => {
  console.log(`VNPay demo server listening on http://localhost:${port}`);
});
