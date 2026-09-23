class ProfileMe {
  final int id;
  final int userId;
  final String fullName;
  final String? city;
  final String? bio;
  final String title;
  final String? avatar;
  final List<String> skills;
  final List<Experience> experience;
  final List<Education> education;
  final String? cvFile;
  final bool jobSeekerComplete;
  final bool employerComplete;
  final bool freelancerComplete;
  final bool isComplete;
  final bool openToJobSeeker;
  final bool openToEmployer;
  final String? createdAt;
  final String? updatedAt;
  final dynamic employerInfo;
  final dynamic freelancerInfo;

  const ProfileMe({
    required this.id,
    required this.userId,
    required this.fullName,
    this.city,
    this.bio,
    required this.title,
    this.avatar,
    required this.skills,
    required this.experience,
    required this.education,
    this.cvFile,
    required this.jobSeekerComplete,
    required this.employerComplete,
    required this.freelancerComplete,
    required this.isComplete,
    this.openToJobSeeker = false,
    this.openToEmployer = false,
    this.createdAt,
    this.updatedAt,
    this.employerInfo,
    this.freelancerInfo,
  });

  factory ProfileMe.fromJson(Map<String, dynamic> json) {
    return ProfileMe(
      id: json['id'] as int,
      userId: json['userId'] as int,
      fullName: json['fullName'] as String? ?? 'Foydalanuvchi',
      city: json['city'] as String?,
      bio: json['bio'] as String?,
      title: json['title'] as String? ?? '',
      avatar: json['avatar'] as String?,
      skills: (json['skills'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      experience: (json['experience'] as List<dynamic>?)
              ?.map((e) => Experience.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      education: (json['education'] as List<dynamic>?)
              ?.map((e) => Education.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      cvFile: json['cvFile'] as String?,
      jobSeekerComplete: json['jobSeekerComplete'] as bool? ?? false,
      employerComplete: json['employerComplete'] as bool? ?? false,
      freelancerComplete: json['freelancerComplete'] as bool? ?? false,
      isComplete: json['isComplete'] as bool? ?? false,
      openToJobSeeker: json['openToJobSeeker'] as bool? ?? false,
      openToEmployer: json['openToEmployer'] as bool? ?? false,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      employerInfo: json['employerInfo'],
      freelancerInfo: json['freelancerInfo'],
    );
  }
}

class Experience {
  final String id;
  final String title;
  final String company;
  final String startDate;
  final String? endDate;
  final String? location;
  final String? description;
  final bool current;

  const Experience({
    required this.id,
    required this.title,
    required this.company,
    required this.startDate,
    this.endDate,
    this.location,
    this.description,
    this.current = false,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      id: json['id'].toString(),
      title: json['title'] as String? ?? '',
      company: json['company'] as String? ?? '',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String?,
      location: json['location'] as String?,
      description: json['description'] as String?,
      current: json['current'] as bool? ?? (json['endDate'] == null || json['endDate'] == ""),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'startDate': startDate,
      'endDate': endDate,
      'location': location,
      'description': description,
      'current': current,
    };
  }
}

class Education {
  final String id;
  final String school;
  final String degree;
  final String field;
  final String startDate;
  final String? endDate;
  final bool current;

  const Education({
    required this.id,
    required this.school,
    required this.degree,
    required this.field,
    required this.startDate,
    this.endDate,
    required this.current,
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      id: json['id'].toString(),
      school: json['school'] as String? ?? '',
      degree: json['degree'] as String? ?? '',
      field: json['field'] as String? ?? '',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String?,
      current: json['current'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school': school,
      'degree': degree,
      'field': field,
      'startDate': startDate,
      'endDate': endDate,
      'current': current,
    };
  }
}


