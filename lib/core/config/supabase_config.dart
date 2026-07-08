import 'env.dart';

class SupabaseConfig {
  const SupabaseConfig._();

  static String get url => Env.supabaseUrl;
  static String get anonKey => Env.supabaseAnonKey;
}