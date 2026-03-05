class UserModel {
  final String id;
  final String name;
  final String email;
  final String? bio;
  final String? avatarUrl;
  final String? coverUrl;
  final String? headline;
  final String? location;
  final int connections;
  final int followers;
  final List<String> skills;
  final List<Experience> experience;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.bio,
    this.avatarUrl,
    this.coverUrl,
    this.headline,
    this.location,
    this.connections = 0,
    this.followers = 0,
    this.skills = const [],
    this.experience = const [],
    this.createdAt,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? bio,
    String? avatarUrl,
    String? coverUrl,
    String? headline,
    String? location,
    int? connections,
    int? followers,
    List<String>? skills,
    List<Experience>? experience,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      headline: headline ?? this.headline,
      location: location ?? this.location,
      connections: connections ?? this.connections,
      followers: followers ?? this.followers,
      skills: skills ?? this.skills,
      experience: experience ?? this.experience,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'coverUrl': coverUrl,
      'headline': headline,
      'location': location,
      'connections': connections,
      'followers': followers,
      'skills': skills,
      'experience': experience.map((e) => e.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      bio: json['bio'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      coverUrl: json['coverUrl'] as String?,
      headline: json['headline'] as String?,
      location: json['location'] as String?,
      connections: json['connections'] as int? ?? 0,
      followers: json['followers'] as int? ?? 0,
      skills: (json['skills'] as List<dynamic>?)?.cast<String>() ?? [],
      experience: (json['experience'] as List<dynamic>?)
              ?.map((e) => Experience.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
}

class Experience {
  final String company;
  final String position;
  final String duration;
  final String? description;

  Experience({
    required this.company,
    required this.position,
    required this.duration,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'company': company,
      'position': position,
      'duration': duration,
      'description': description,
    };
  }

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      company: json['company'] as String,
      position: json['position'] as String,
      duration: json['duration'] as String,
      description: json['description'] as String?,
    );
  }
}
