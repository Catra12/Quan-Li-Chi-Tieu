const mongoose = require('mongoose');
const Expense = require('../src/models/Expense');

describe('Expense Model Unit Tests', () => {
  afterAll(async () => {
    await mongoose.disconnect();
  });
  // Test case 1: Tạo khoản chi tiêu hợp lệ (title, amount, category) thành công
  test('Tạo khoản chi tiêu hợp lệ (title, amount, category) thành công', () => {
    const validExpense = new Expense({
      title: 'Ăn trưa',
      amount: 50000,
      category: 'Ăn uống'
    });

    const error = validExpense.validateSync();
    expect(error).toBeUndefined();
    expect(validExpense.title).toBe('Ăn trưa');
    expect(validExpense.amount).toBe(50000);
    expect(validExpense.category).toBe('Ăn uống');
    expect(validExpense.createdAt).toBeInstanceOf(Date);
  });

  // Test case 2: Báo lỗi validation nếu thiếu title
  test('Báo lỗi validation nếu thiếu title', () => {
    const invalidExpense = new Expense({
      amount: 50000,
      category: 'Ăn uống'
    });

    const error = invalidExpense.validateSync();
    expect(error).toBeDefined();
    expect(error.errors.title).toBeDefined();
    expect(error.errors.title.message).toBe('Tiêu đề không được để trống');
  });

  // Test case 3: Báo lỗi validation nếu amount là số âm (< 0)
  test('Báo lỗi validation nếu amount là số âm (< 0)', () => {
    const invalidExpense = new Expense({
      title: 'Mua sách',
      amount: -10000,
      category: 'Học tập'
    });

    const error = invalidExpense.validateSync();
    expect(error).toBeDefined();
    expect(error.errors.amount).toBeDefined();
    expect(error.errors.amount.message).toBe('Số tiền phải lớn hơn hoặc bằng 0');
  });
});
