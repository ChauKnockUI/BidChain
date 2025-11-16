
const { body, validationResult } = require("express-validator");

const validateBid = [
  body("auctionId")
    .isInt({ min: 0 })
    .withMessage("auctionId must be a positive integer"),
  body("amountWei")
    .isString()
    .notEmpty()
    .matches(/^\d+$/)
    .withMessage("amountWei must be a valid wei string"),
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    next();
  },
];

module.exports = { validateBid };