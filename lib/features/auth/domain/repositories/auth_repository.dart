import '../../../../core/errors/either_result.dart';
import '../../../auth/domain/entities/user_entity.dart';

/// Auth repository interface (domain layer).
abstract class AuthRepository {
  /// Stream of auth state changes.
  Stream<UserEntity?> get authStateChanges;

  /// Get the currently signed-in user.
  Future<UserEntity?> getCurrentUser();

  /// Sign in with email and password.
  EitherResult<UserEntity> signInWithEmail({
    required String email,
    required String password,
  });

  /// Create a new account with email and password.
  EitherResult<UserEntity> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  /// Send a password reset email.
  EitherResult<void> sendPasswordResetEmail(String email);

  /// Sign out the current user.
  EitherResult<void> signOut();
}
