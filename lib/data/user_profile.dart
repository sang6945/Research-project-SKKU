class Profile {
  final String nickname;
  final String position;
  final String birthday;
  final String email;
  final String realName;
  final String phoneNumber;

  Profile({
    required this.nickname,
    required this.position,
    required this.birthday,
    required this.email,
    required this.realName,
    required this.phoneNumber,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      nickname: json['nickname'] ?? '',
      position: json['position'] ?? '',
      birthday: json['birthday'] ?? '',
      email: json['email'] ?? '',
      realName: json['realName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
    );


  }
}
