class UserModel {
  final String uid;
  final String email;
  final String? name;
  final String? phoneNumber;
  final String? workshopId;
  final String role;

  UserModel({
    required this.uid,
    required this.email,
    this.name,
    this.phoneNumber,
    this.workshopId,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'],
      phoneNumber: map['phoneNumber'],
      workshopId: map['workshopId'],
      role: map['role'] ?? 'mechanic',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'workshopId': workshopId,
      'role': role,
    };
  }
}
