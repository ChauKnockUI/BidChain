class Validators {
  // Email validation với regex RFC 5322 compliant
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    // Trim whitespace
    final trimmedValue = value.trim();

    if (trimmedValue.isEmpty) {
      return 'Email cannot be empty or whitespace';
    }

    // Email regex pattern (RFC 5322 simplified)
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(trimmedValue)) {
      return 'Please enter a valid email address';
    }

    // Check for consecutive dots
    if (trimmedValue.contains('..')) {
      return 'Email cannot contain consecutive dots';
    }

    // Check email length (max 254 characters per RFC 5321)
    if (trimmedValue.length > 254) {
      return 'Email is too long (max 254 characters)';
    }

    // Check local part length (before @)
    final localPart = trimmedValue.split('@')[0];
    if (localPart.length > 64) {
      return 'Email local part is too long (max 64 characters)';
    }

    return null;
  }

  // Username validation
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.isEmpty) {
      return 'Username cannot be empty or whitespace';
    }

    if (trimmedValue.length < 3) {
      return 'Username must be at least 3 characters';
    }

    if (trimmedValue.length > 30) {
      return 'Username must not exceed 30 characters';
    }

    // Only allow alphanumeric, underscore, and hyphen
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_-]+$');
    if (!usernameRegex.hasMatch(trimmedValue)) {
      return 'Username can only contain letters, numbers, _ and -';
    }

    // Cannot start or end with special characters
    if (trimmedValue.startsWith('_') ||
        trimmedValue.startsWith('-') ||
        trimmedValue.endsWith('_') ||
        trimmedValue.endsWith('-')) {
      return 'Username cannot start or end with _ or -';
    }

    return null;
  }

  // Password validation với multiple security rules
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (value.length > 128) {
      return 'Password must not exceed 128 characters';
    }

    // Check for at least one uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for at least one lowercase letter
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    // Check for at least one digit
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    // Check for at least one special character
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }

    // Check for common weak passwords
    final weakPasswords = [
      'password',
      'Password1!',
      '12345678',
      'qwerty123',
      'Admin123!',
      'Welcome1!',
      'Test1234!',
    ];

    if (weakPasswords.any(
      (weak) => value.toLowerCase().contains(weak.toLowerCase()),
    )) {
      return 'Password is too common, please use a stronger password';
    }

    return null;
  }

  // Simple password validation (for login only)
  static String? validateLoginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  static String? validateEthereumAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }
    if (!value.startsWith('0x') || value.length != 42) {
      return 'Invalid Ethereum address';
    }
    return null;
  }

  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }
    try {
      double.parse(value);
      return null;
    } catch (e) {
      return 'Invalid amount';
    }
  }

  // Full name validation
  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Full name is required';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.isEmpty) {
      return 'Full name cannot be empty or whitespace';
    }

    if (trimmedValue.length < 2) {
      return 'Full name must be at least 2 characters';
    }

    if (trimmedValue.length > 100) {
      return 'Full name must not exceed 100 characters';
    }

    // Only allow letters, spaces, and some special characters (apostrophe, hyphen)
    final nameRegex = RegExp(r"^[a-zA-ZÀ-ỹ\s'\-]+$");
    if (!nameRegex.hasMatch(trimmedValue)) {
      return 'Full name can only contain letters, spaces, apostrophes, and hyphens';
    }

    // Check for at least one letter
    if (!trimmedValue.contains(RegExp(r'[a-zA-ZÀ-ỹ]'))) {
      return 'Full name must contain at least one letter';
    }

    // Cannot start or end with space
    if (trimmedValue.startsWith(' ') || trimmedValue.endsWith(' ')) {
      return 'Full name cannot start or end with space';
    }

    // Cannot have consecutive spaces
    if (trimmedValue.contains(RegExp(r'\s{2,}'))) {
      return 'Full name cannot contain consecutive spaces';
    }

    return null;
  }

  // Phone number validation (international format)
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.isEmpty) {
      return 'Phone number cannot be empty';
    }

    // Remove common separators for validation
    final digitsOnly = trimmedValue.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');

    // Check if contains only digits after removing separators
    if (!RegExp(r'^[0-9]+$').hasMatch(digitsOnly)) {
      return 'Phone number can only contain digits and separators (+, -, (), spaces)';
    }

    // Check length (international phone numbers: 7-15 digits)
    if (digitsOnly.length < 7) {
      return 'Phone number is too short (minimum 7 digits)';
    }

    if (digitsOnly.length > 15) {
      return 'Phone number is too long (maximum 15 digits)';
    }

    // Vietnam phone number specific validation (optional, can be removed for international)
    if (trimmedValue.startsWith('0') && digitsOnly.length == 10) {
      // Vietnamese mobile numbers
      final vnMobileRegex = RegExp(r'^0(3|5|7|8|9)[0-9]{8}$');
      if (!vnMobileRegex.hasMatch(digitsOnly)) {
        return 'Invalid Vietnamese phone number format';
      }
    }

    return null;
  }

  // Optional phone number validation (can be empty)
  static String? validatePhoneNumberOptional(String? value) {
    if (value == null || value.isEmpty || value.trim().isEmpty) {
      return null; // Valid if empty
    }
    return validatePhoneNumber(value);
  }
}
