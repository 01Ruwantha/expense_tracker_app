import 'package:firebase_auth/firebase_auth.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/either_result.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

/// Firebase implementation of AuthRepository.
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth;

  AuthRepositoryImpl({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  UserEntity? _mapUser(User? user) {
    if (user == null) return null;
    return UserEntity(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  @override
  Stream<UserEntity?> get authStateChanges =>
      _auth.authStateChanges().map(_mapUser);

  @override
  Future<UserEntity?> getCurrentUser() async {
    return _mapUser(_auth.currentUser);
  }

  @override
  EitherResult<UserEntity> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = _mapUser(cred.user);
      if (user == null) return const Left(AuthFailure('Sign in failed'));
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseError(e.code, e.message)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  EitherResult<UserEntity> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (displayName.isNotEmpty) {
        try {
          await cred.user?.updateDisplayName(displayName);
          await cred.user?.reload();
        } catch (_) {}
      }
      final user = _mapUser(_auth.currentUser ?? cred.user);
      if (user == null) return const Left(AuthFailure('Sign up failed'));
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseError(e.code, e.message)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  EitherResult<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseError(e.code, e.message)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  EitherResult<void> signOut() async {
    try {
      await _auth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  String _mapFirebaseError(String code, [String? message]) {
    if (message != null && message.contains('CONFIGURATION_NOT_FOUND')) {
      return 'Email/Password sign-in is not enabled in Firebase Console. Go to Authentication > Sign-in method in Firebase Console and enable Email/Password.';
    }
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'An account with this email already exists. Try signing in.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'operation-not-allowed':
        return 'Email/Password sign-in is disabled in Firebase Console. Please enable it under Authentication > Sign-in method.';
      case 'configuration-not-found':
        return 'Firebase Authentication configuration not found. Please enable Email/Password in Firebase Console.';
      default:
        return message ?? 'Authentication failed ($code). Please try again.';
    }
  }
}
