import '../../core/models/auth_result.dart';
import '../../models/profile_model.dart';

/// Contract for authentication operations (Interface Segregation & Dependency Inversion).
/// High-level modules depend on this abstraction rather than concrete implementations (Supabase, Firebase, Mock).
abstract class IAuthRepository {
  /// Signs in a user with email and password.
  Future<AuthResult> signIn({required String email, required String password});

  /// Registers a new user account with student details.
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String fullName,
    required String institution,
    required String major,
    required String academicYear,
  });

  /// Signs in as a local demo student without requiring remote cloud connectivity.
  Future<AuthResult> signInAsDemo();

  /// Signs out the currently authenticated user.
  Future<void> signOut();

  /// Gets the currently authenticated user profile, if any.
  UserProfile? getCurrentUser();
}
