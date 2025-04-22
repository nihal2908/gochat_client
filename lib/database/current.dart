class Current {
  static String? _username;
  static String? _phone;
  static String? _countryCode;

  static String? get username => _username;
  static String? get phone => _phone;
  static String? get countryCode => _countryCode;

  static void signOut() {
    _username = null;
    _phone = null;
    _countryCode = null;
  }

  static void setUserData({
    required String username,
    required String phone,
    required String countryCode,
  }) {
    _username = username;
    _phone = phone;
    _countryCode = countryCode;
  }
}
