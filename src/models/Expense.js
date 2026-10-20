const mongoose = require('mongoose');

const expenseSchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, 'Tiêu đề không được để trống'],
    trim: true
  },
  amount: {
    type: Number,
    required: [true, 'Số tiền không được để trống'],
    min: [0, 'Số tiền phải lớn hơn hoặc bằng 0']
  },
  category: {
    type: String,
    trim: true,
    default: 'Khác'
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Expense', expenseSchema);
