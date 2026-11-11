/// Environment configuration supporting compile-time `--dart-define` parameters.
class EnvConfig {
  EnvConfig._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://vfwfgryfhbrozihqtlwt.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZmd2ZncnlmaGJyb3ppaHF0bHd0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODcyMDE3OTYsImV4cCI6MjEwMjc3Nzc5Nn0.y4LOUaIilXkPaEcOHSNGnHaf1_iK3lS-zfGAc1WWdXU',
  );
}
