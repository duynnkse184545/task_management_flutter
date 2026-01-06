class AppConstants {
  // App Info
  static const String appName = 'Task Manager';
  static const String appVersion = '1.0.0';

  // Local Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String currentWorkspaceKey = 'current_workspace_id';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 64;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;

  // Date formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'MMM dd, yyyy';

  // Task defaults
  static const String defaultTaskStatus = 'todo';
  static const String defaultTaskPriority = 'medium';

  // Workspace roles
  static const String roleOwner = 'owner';
  static const String roleAdmin = 'admin';
  static const String roleMember = 'member';
  static const String roleViewer = 'viewer';
}