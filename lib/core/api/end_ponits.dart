class EndPoints {
  static String baseUrl = 'https://777api.omnia.sh/mounir/';
  static String storageBaseUrl = 'https://fsn1.your-objectstorage.com/777/';

  static const String sharedBaseUrl = 'https://777api.omnia.sh/';
  static void setBaseUrl(String url) {
    baseUrl = url;
    print('EndPoints baseUrl updated to: $baseUrl');
  }

  static const String loginAuth = 'accounts/login';
  static const String verifyAuth = 'accounts/verify';
  static const String profileCheck = 'accounts/profile';
  static const String userProfile = 'accounts/profile';
  static const String getServices = 'services/';
  static const String uploadFile = 'files/upload';
  static const String getAvailableTimes = 'reservations/available';
  static const String packages = 'packages/';
  static const String reservations = 'reservations/book';
  static const String getReservations = 'reservations/';
  static const String logout = 'logout';
  static const String getReels = 'reels/';
  static const String setFcmToken = 'accounts/set-fcm-token';
}

class ApiKeys {
  static const String status = 'status';
  static const String errorMessage = 'message';
  static const String message = 'message';
  static const String data = 'data';

  static const String name = 'name';
  static const String email = 'email';
  static const String phone = 'phone';
  static const String token = 'token';
  static const String id = 'id';
  static const String image = 'image';
}
