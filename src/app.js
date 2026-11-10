require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const path = require('path');
const helmet = require('helmet');
const { rateLimit } = require('express-rate-limit');
const client = require('prom-client');
const expenseRoutes = require('./routes/expenseRoutes');

const app = express();
const PORT = process.env.PORT || 3000;
const MONGO_URI = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/quanlychitieu';

// --- Bảo mật Ứng dụng (Application Security Hardening) ---
// 1. Helmet: Thiết lập HTTP Security Headers an toàn, vô hiệu hóa CSP để không xung đột EJS/Bootstrap
app.use(helmet({ contentSecurityPolicy: false }));

// 2. Rate Limiting: Giới hạn tối đa 120 requests/phút mỗi IP, bỏ qua /health và /metrics
const limiter = rateLimit({
  windowMs: 60 * 1000, // 1 phút
  max: 120, // Tối đa 120 requests / 1 phút cho mỗi IP
  standardHeaders: true,
  legacyHeaders: false,
  skip: (req) => req.path === '/health' || req.path === '/metrics'
});
app.use(limiter);

// --- Prometheus Metrics Configuration ---
// Thu thập Default Metrics (CPU, RAM, Event Loop của Node.js)
client.collectDefaultMetrics();

// Histogram đo thời gian phản hồi của request HTTP
const httpRequestDurationSeconds = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.01, 0.05, 0.1, 0.3, 0.5, 1, 1.5, 2, 5]
});

// Counter đếm tổng số lượng request HTTP
const httpRequestsTotal = new client.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code']
});

// Cấu hình View Engine (EJS)
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// Middleware xử lý dữ liệu form và JSON
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

// Middleware: Structured Logging & Prometheus Metrics Collector
app.use((req, res, next) => {
  const start = process.hrtime();
  const startTime = Date.now();

  res.on('finish', () => {
    // 1. Tính toán thời gian thực thi (ms) cho Structured Log
    const durationMs = Date.now() - startTime;
    const isoTimestamp = new Date().toISOString();
    console.log(`[${isoTimestamp}] [INFO] ${req.method} ${req.originalUrl || req.url} ${res.statusCode} - ${durationMs} ms`);

    // 2. Ghi nhận Prometheus Metrics
    const diff = process.hrtime(start);
    const durationSeconds = diff[0] + diff[1] / 1e9;
    const route = req.route ? `${req.baseUrl || ''}${req.route.path}` : (req.baseUrl || req.path || 'unknown');
    const labels = {
      method: req.method,
      route: route,
      status_code: res.statusCode
    };

    httpRequestDurationSeconds.observe(labels, durationSeconds);
    httpRequestsTotal.inc(labels);
  });

  next();
});

// Route kiểm tra trạng thái dịch vụ (Health Check cho DevOps - v1.0.0)
app.get('/health', (req, res) => {
  const isDbConnected = mongoose.connection.readyState === 1;
  const timestamp = new Date().toISOString();

  if (isDbConnected) {
    return res.status(200).json({
      status: 'UP',
      database: 'CONNECTED',
      uptime: process.uptime(),
      version: '1.0.0',
      timestamp: timestamp
    });
  }

  return res.status(503).json({
    status: 'DOWN',
    database: 'DISCONNECTED',
    version: '1.0.0',
    timestamp: timestamp
  });
});

// Route cung cấp metrics cho Prometheus scrape
app.get('/metrics', async (req, res) => {
  try {
    res.set('Content-Type', client.register.contentType);
    res.end(await client.register.metrics());
  } catch (err) {
    console.error('Lỗi khi xuất Prometheus metrics:', err);
    res.status(500).end(err.message);
  }
});

// Routes ứng dụng
app.use('/expenses', expenseRoutes);

// Trang chủ chuyển hướng sang danh sách chi tiêu
app.get('/', (req, res) => {
  res.redirect('/expenses');
});

// Kết nối MongoDB và khởi động Server (Chỉ chạy khi không trong môi trường test)
if (process.env.NODE_ENV !== 'test') {
  mongoose.connect(MONGO_URI)
    .then(() => {
      console.log(`✅ Kết nối MongoDB thành công: ${MONGO_URI}`);
    })
    .catch((err) => {
      console.error(`❌ Lỗi kết nối MongoDB (${MONGO_URI}):`, err.message);
    });

  app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Server đang chạy tại http://0.0.0.0:${PORT}`);
    console.log(`🏥 Health Check: http://localhost:${PORT}/health`);
    console.log(`📊 Prometheus Metrics: http://localhost:${PORT}/metrics`);
  });
}

module.exports = app;
