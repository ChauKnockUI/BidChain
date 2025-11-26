const jwt = require('jsonwebtoken');
require('dotenv').config();
const { body, validationResult } = require("express-validator");

const JWT_SECRET = process.env.JWT_SECRET || 'dev_secret';

function authMiddleware(req, res, next) {
  const auth = req.headers.authorization;
  if (!auth) return res.status(401).json({ error: 'No token' });
  const token = auth.split(' ')[1];
  try {
    const payload = jwt.verify(token, JWT_SECRET);
    req.user = payload;
    next();
  } catch (e) {
    return res.status(401).json({ error: 'Invalid token' });
  }
}



const validateRegister = [
  body("username").isLength({ min: 3, max: 30 }).trim().escape(),
  body("password").isLength({ min: 8 }),
  body("email").isEmail().normalizeEmail(),
  body("full_name").isLength({ min: 2 }).trim().escape(),
  body("role")
    .optional()
    .isIn(['ADMIN', 'MANAGER', 'USER'])
    .withMessage("Role không hợp lệ"),

  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    next();
  }
];

module.exports = { authMiddleware, validateRegister };