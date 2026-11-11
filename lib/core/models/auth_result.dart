import '../../models/profile_model.dart';

/// Represents the result of an authentication operation.
/// Adheres to SRP by encapsulating auth response status, profile, and errors.
class AuthResult {
  final bool isSuccess;
  final UserProfile? user;
  final String? errorMessage;
  final bool requiresEmailConfirmation;

  const AuthResult.success(this.user, {this.requiresEmailConfirmation = false})
    : isSuccess = true,
      errorMessage = null;

  const AuthResult.failure(this.errorMessage)
    : isSuccess = false,
      user = null,
      requiresEmailConfirmation = false;
}
