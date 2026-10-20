require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const path = require('path');
const expenseRoutes = require('./routes/expenseRoutes');

const app = express();
const PORT = process.env.PORT || 3000;
const MONGO_URI = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/quanlychitieu';

// Cấu hình View Engine (EJS)
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// Middleware xử lý dữ liệu form và JSON
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

// Route kiểm tra trạng thái dịch vụ (Health Check cho DevOps)
app.get('/health', (req, res) => {
  const isDbConnected = mongoose.connection.readyState === 1;
  res.status(200).json({
    status: 'UP',
    database: isDbConnected ? 'CONNECTED' : 'DISCONNECTED'
  });
});

// Routes ứng dụng
app.use('/expenses', expenseRoutes);

// Trang chủ chuyển hướng sang danh sách chi tiêu
app.get('/', (req, res) => {
  res.redirect('/expenses');
});

// Kết nối MongoDB và khởi động Server
mongoose.connect(MONGO_URI)
  .then(() => {
    console.log(`✅ Kết nối MongoDB thành công: ${MONGO_URI}`);
  })
  .catch((err) => {
    console.error(`❌ Lỗi kết nối MongoDB (${MONGO_URI}):`, err.message);
  });

app.listen(PORT, () => {
  console.log(`🚀 Server đang chạy tại http://localhost:${PORT}`);
  console.log(`🏥 Health Check: http://localhost:${PORT}/health`);
});

module.exports = app;
