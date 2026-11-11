import '../../models/profile_model.dart';

/// Contract for profile data management (Interface Segregation Principle).
/// Clients only depend on methods they actually need.
abstract class IProfileRepository {
  /// Fetches a user profile by ID.
  Future<UserProfile?> getProfile(String userId);

  /// Updates profile attributes.
  Future<void> updateProfile(UserProfile profile);
}
