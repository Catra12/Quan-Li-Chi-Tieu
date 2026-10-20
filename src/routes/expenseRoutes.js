const express = require('express');
const router = express.Router();
const Expense = require('../models/Expense');

// GET /expenses - Danh sách chi tiêu & tính tổng
router.get('/', async (req, res) => {
  try {
    const expenses = await Expense.find().sort({ createdAt: -1 });
    const totalAmount = expenses.reduce((sum, item) => sum + (Number(item.amount) || 0), 0);
    res.render('index', {
      expenses,
      totalAmount,
      error: null
    });
  } catch (error) {
    console.error('Lỗi khi lấy danh sách chi tiêu:', error);
    res.status(500).render('index', {
      expenses: [],
      totalAmount: 0,
      error: 'Không thể tải danh sách chi tiêu. Vui lòng kiểm tra kết nối cơ sở dữ liệu.'
    });
  }
});

// POST /expenses - Thêm khoản chi tiêu mới
router.post('/', async (req, res) => {
  try {
    const { title, amount, category } = req.body;
    if (!title || !amount) {
      return res.redirect('/expenses');
    }

    await Expense.create({
      title: title.trim(),
      amount: Number(amount),
      category: category ? category.trim() : 'Khác'
    });

    res.redirect('/expenses');
  } catch (error) {
    console.error('Lỗi khi thêm khoản chi tiêu:', error);
    res.redirect('/expenses');
  }
});

// POST /expenses/:id/delete - Xóa khoản chi tiêu
router.post('/:id/delete', async (req, res) => {
  try {
    const { id } = req.params;
    await Expense.findByIdAndDelete(id);
    res.redirect('/expenses');
  } catch (error) {
    console.error('Lỗi khi xóa khoản chi tiêu:', error);
    res.redirect('/expenses');
  }
});

module.exports = router;
