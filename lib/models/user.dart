import 'dart:convert';

class User {
  final bool userType;
  final String uid;
  final String username;
  final String email;
  final String? profilePicture;

  User({
    this.userType = false,
    required this.uid,
    required this.username,
    required this.email,
    this.profilePicture,
  });

  Map<String, dynamic> toMap() {
    return {
      'userType': userType,
      'uid': uid,
      'username': username,
      'email': email,
      'profilePicture': profilePicture,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userType: map['userType'],
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      profilePicture: map['profilePicture'],

    );
  }
}
