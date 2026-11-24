/// Environment configuration supporting compile-time `--dart-define` parameters.
class EnvConfig {
  EnvConfig._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://vfwfgryfhbrozihqtlwt.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_vo212e2x6uZ1-A30aRXZfA_ppcBS_Lg',
  );
}
