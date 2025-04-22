class CurrentUser {
  static String? userId;

  void setUserId(String id) {
    userId = id;
  }

  void logout() {
    userId = null;
  }

  String? get UserId => userId;
}
