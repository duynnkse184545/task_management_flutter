class ApiConstants {
  // Auth endpoints
  static const String signUp = '/signup';
  static const String signIn = '/token';
  static const String signOut = '/logout';
  static const String user = '/user';
  static const String refreshToken = '/token?grant_type=refresh_token';

  // Database tables (PostgREST)
  static const String profiles = '/profiles';
  static const String workspaces = '/workspaces';
  static const String workspaceMembers = '/workspace_members';
  static const String categories = '/categories';
  static const String tasks = '/tasks';
  static const String tags = '/tags';
  static const String taskTags = '/task_tags';
  static const String activityLogs = '/activity_logs';

  // Query parameters
  static const String selectAll = 'select=*';
  static const String preferReturn = 'return=representation';

  // PostgREST operators
  static String eq(String column, String value) => '$column=eq.$value';
  static String neq(String column, String value) => '$column=neq.$value';
  static String gt(String column, String value) => '$column=gt.$value';
  static String gte(String column, String value) => '$column=gte.$value';
  static String lt(String column, String value) => '$column=lt.$value';
  static String lte(String column, String value) => '$column=lte.$value';
  static String like(String column, String value) => '$column=like.$value';
  static String ilike(String column, String value) => '$column=ilike.$value';
  static String inList(String column, List<String> values) =>
      '$column=in.(${values.join(',')})';
  static String order(String column, {bool ascending = true}) =>
      'order=$column.${ascending ? 'asc' : 'desc'}';
}