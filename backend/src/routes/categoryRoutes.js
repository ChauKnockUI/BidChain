const express = require('express');
const router = express.Router();
const CategoryController = require('../controllers/categoryController');

// Tạo category
router.post('/create', CategoryController.createCategory);

// Lấy tất cả categories
router.get('/all', CategoryController.getAllCategories);

module.exports = router;
