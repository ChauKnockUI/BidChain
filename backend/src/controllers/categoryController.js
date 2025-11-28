const Category = require('../models/Category');

// POST /category/create
exports.createCategory = async (req, res) => {
  try {
    const { name, description } = req.body;

    if (!name) {
      return res.status(400).json({ success: false, message: "name is required" });
    }

    const exists = await Category.findOne({ name });
    if (exists) {
      return res.status(400).json({ success: false, message: "Category already exists" });
    }

    const newCat = await Category.create({ name, description });

    res.json({ success: true, message: "Category created", data: newCat });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

// GET /category/all
exports.getAllCategories = async (req, res) => {
  try {
    const list = await Category.find().sort({ createdAt: -1 });
    res.json({ success: true, data: list });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};
