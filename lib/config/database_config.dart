class DatabaseConfig {
  // Update these with your XAMPP MySQL configuration
  static const String host = '10.0.2.2'; // or your server IP
  static const int port = 3306;
  static const String databaseName = 'acrifeed';
  static const String username = 'root'; // default XAMPP username
  static const String password = ''; // default XAMPP password is empty
  static const int databaseVersion = 1; // Add this missing field

  static String get connectionString =>
      'mysql://$username:$password@$host:$port/$databaseName';
}