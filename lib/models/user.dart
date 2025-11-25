class UserModel {
  final String uid;
  final String? name;
  final String? email;
  final String? photoUrl;

  UserModel({required this.uid, this.name, this.email, this.photoUrl});

  factory UserModel.fromFirebaseUser(dynamic user) {
    return UserModel(
      uid: user.uid,
      name: user.displayName,
      email: user.email,
      photoUrl: user.photoURL,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      uid: documentId,
      name: data['name'],
      email: data['email'],
      photoUrl: data['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'email': email, 'photoUrl': photoUrl};
  }
}
