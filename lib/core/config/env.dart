import 'environment.dart';

class Env {
  const Env._();

  static String get supabaseUrl => Environment.supabaseUrl;
  static String get supabaseAnonKey => Environment.supabaseAnonKey;
  static String get googleWebClientId => Environment.googleWebClientId;
  static String get googleIosClientId => Environment.googleIosClientId;
}
