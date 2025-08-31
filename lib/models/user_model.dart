class AppUser {
  final String uid;
  final String displayName;
  final String email;
  final String? gender;
  final DateTime? dateOfBirth;
  final double? height;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppUser({
    required this.uid,
    required this.displayName,
    required this.email,
    this.gender,
    this.dateOfBirth,
    this.height,
    this.photoURL,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppUser.fromFirestore(Map<String, dynamic> data, String uid) {
    return AppUser(
      uid: uid,
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      gender: data['gender'],
      dateOfBirth: data['dateOfBirth']?.toDate(),
      height: data['height']?.toDouble(),
      photoURL: data['photoURL'],
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'height': height,
      'photoURL': photoURL,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  AppUser copyWith({
    String? displayName,
    String? gender,
    DateTime? dateOfBirth,
    double? height,
    String? photoURL,
  }) {
    return AppUser(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      height: height ?? this.height,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}