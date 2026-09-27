import 'package:equatable/equatable.dart';

/// Base failure class for the domain layer.
/// Covers auth, server, cache, network, and validation failures.
abstract class AppFailure extends Equatable {
  final String message;
  const AppFailure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends AppFailure {
  const ServerFailure([super.message = 'Server error occurred']);
}

class NetworkFailure extends AppFailure {
  const NetworkFailure([super.message = 'Network error. Check your connection.']);
}

class CacheFailure extends AppFailure {
  const CacheFailure([super.message = 'Local cache error']);
}

class AuthFailure extends AppFailure {
  const AuthFailure([super.message = 'Authentication error']);
}

class ValidationFailure extends AppFailure {
  const ValidationFailure([super.message = 'Validation error']);
}

class NotFoundFailure extends AppFailure {
  const NotFoundFailure([super.message = 'Resource not found']);
}

class PermissionFailure extends AppFailure {
  const PermissionFailure([super.message = 'Permission denied']);
}
