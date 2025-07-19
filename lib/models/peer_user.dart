enum Gender { MALE, FEMALE, OTHER }
enum UserStatus { ONLINE, OFFLINE }

Gender genderFromString(String value) {
  return Gender.values.firstWhere((e) => e.name == value, orElse: () => Gender.OTHER);
}

String genderToString(Gender gender) => gender.name;

UserStatus statusFromString(String value) {
  return UserStatus.values.firstWhere((e) => e.name == value, orElse: () => UserStatus.OFFLINE);
}

String statusToString(UserStatus status) => status.name;

class PeerUser {
  final int id;
  final String? username;
  final String nickname;
  final String? avatarUrl;
  final Gender? gender;
  final UserStatus? status;
  final String bio;
  final int postCount;
  final int followingCount;
  final int followersCount;
  final bool isMe;
  final bool isFollowing;
  final String? backgroundUrl;

  PeerUser({
    required this.id,
    this.username,
    required this.nickname,
    this.avatarUrl,
    this.gender,
    this.status,
    this.bio = '',
    this.postCount = 0,
    this.followingCount = 0,
    this.followersCount = 0,
    this.isMe = true,
    this.isFollowing = false,
    this.backgroundUrl,
  });

  // 从 JSON 转换为 PeerUser
  factory PeerUser.fromJson(Map<String, dynamic> json) {
    return PeerUser(
      id: json['id'],
      username: json['username'],
      nickname: json['nickname'],
      avatarUrl: json['avatarUrl'],
      gender: json['gender'] != null ? genderFromString(json['gender']) : null,
      status: json['status'] != null ? statusFromString(json['status']) : null,
      bio: json['bio'] ?? '',
      postCount: json['postCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
      followersCount: json['followersCount'] ?? 0,
      isMe: json['isMe'] ?? true,
      isFollowing: json['isFollowing'] ?? false,
      backgroundUrl: json['backgroundUrl'],
    );
  }

  // 从 PeerUser 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nickname': nickname,
      'avatarUrl': avatarUrl,
      'gender': gender == null ? '' : genderToString(gender!),
      'status': status == null ? '' : statusToString(status!),
      'bio': bio,
      'postCount': postCount,
      'followingCount': followingCount,
      'followersCount': followersCount,
      'isMe': isMe,
      'isFollowing': isFollowing,
      'backgroundUrl': backgroundUrl,
    };
  }

  // 创建一个新的 PeerUser 实例，修改部分字段，其他字段保持不变
  PeerUser copyWith({
    int? id,
    String? username,
    String? nickname,
    String? avatarUrl,
    Gender? gender,
    UserStatus? status,
    String? bio,
    int? postCount,
    int? followingCount,
    int? followersCount,
    bool? isMe,
    bool? isFollowing,
    String? backgroundUrl,
  }) {
    return PeerUser(
      id: id ?? this.id,
      username: username ?? this.username,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      gender: gender ?? this.gender,
      status: status ?? this.status,
      bio: bio ?? this.bio,
      postCount: postCount ?? this.postCount,
      followingCount: followingCount ?? this.followingCount,
      followersCount: followersCount ?? this.followersCount,
      isMe: isMe ?? this.isMe,
      isFollowing: isFollowing ?? this.isFollowing,
      backgroundUrl: backgroundUrl ?? this.backgroundUrl,
    );
  }
}
