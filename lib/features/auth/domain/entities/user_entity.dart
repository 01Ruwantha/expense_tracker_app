import 'package:equatable/equatable.dart';

/// Core user entity for the domain layer.
class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;

  const UserEntity({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  String get name => displayName ?? email.split('@').first;

  @override
  List<Object?> get props => [uid, email, displayName, photoUrl];
}
