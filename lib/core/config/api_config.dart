class ApiConfig {
  // Replace with your Supabase project details
  static const String projectUrl = 'https://cqjyvaqlycsrovnenujd.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNxanl2YXFseWNzcm92bmVudWpkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc2OTA1NDUsImV4cCI6MjA4MzI2NjU0NX0._jfMwFzsJkl1xEG9UpFHrrLeQe3qhfm0MFF0ANJyCek';

  // API Endpoints
  static const String authBaseUrl = '$projectUrl/auth/v1';
  static const String restBaseUrl = '$projectUrl/rest/v1';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Headers
  static Map<String, String> get defaultHeaders => {
    'apikey': anonKey,
    'Content-Type': 'application/json',
  };

  static Map<String, String> authHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
}