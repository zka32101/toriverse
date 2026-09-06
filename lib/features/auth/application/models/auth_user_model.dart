/// Application-layer user model (independent of Firebase)
class AuthUserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime? lastSignInAt;

  AuthUserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.emailVerified = false,
    required this.createdAt,
    this.lastSignInAt,
  });

  /// Create from Firebase User
  factory AuthUserModel.fromFirebaseUser(
    covariant dynamic firebaseUser,
  ) {
    return AuthUserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      emailVerified: firebaseUser.emailVerified,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      lastSignInAt: firebaseUser.metadata.lastSignInTime,
    );
  }

  @override
  String toString() =>
      'AuthUserModel(id: $id, email: $email, displayName: $displayName)';
}
