import 'company_model.dart';

class JobModel {
  final int id;
  final String title;
  final String description;
  final String location;
  final int? salaryMin;
  final int? salaryMax;
  final String salaryCurrency;
  final String jobType;
  final List<String> requirements;
  final bool isRemote;
  final int authorId;
  final int? companyId;
  final String status;
  final int viewsCount;
  final String createdAt;
  final String updatedAt;
  final CompanyModel? company;
  final JobAuthor? author;

  JobModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    this.salaryMin,
    this.salaryMax,
    this.salaryCurrency = 'UZS',
    required this.jobType,
    required this.requirements,
    required this.isRemote,
    required this.authorId,
    this.companyId,
    required this.status,
    required this.viewsCount,
    required this.createdAt,
    required this.updatedAt,
    this.company,
    this.author,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      location: json['location'] as String? ?? '',
      salaryMin: json['salary_min'] as int?,
      salaryMax: json['salary_max'] as int?,
      salaryCurrency: json['salary_currency'] as String? ?? 'UZS',
      jobType: json['job_type'] as String? ?? 'full-time',
      requirements: (json['requirements'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      isRemote: json['is_remote'] as bool? ?? false,
      authorId: json['author_id'] as int,
      companyId: json['company_id'] as int?,
      status: json['status'] as String? ?? 'active',
      viewsCount: json['views_count'] as int? ?? 0,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      company: json['company'] != null ? CompanyModel.fromJson(json['company'] as Map<String, dynamic>) : null,
      author: json['author'] != null ? JobAuthor.fromJson(json['author'] as Map<String, dynamic>) : null,
    );
  }

  JobModel copyWith({
    int? id,
    String? title,
    String? description,
    String? location,
    int? salaryMin,
    int? salaryMax,
    String? salaryCurrency,
    String? jobType,
    List<String>? requirements,
    bool? isRemote,
    int? authorId,
    int? companyId,
    String? status,
    int? viewsCount,
    String? createdAt,
    String? updatedAt,
    CompanyModel? company,
    JobAuthor? author,
  }) {
    return JobModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
      salaryCurrency: salaryCurrency ?? this.salaryCurrency,
      jobType: jobType ?? this.jobType,
      requirements: requirements ?? this.requirements,
      isRemote: isRemote ?? this.isRemote,
      authorId: authorId ?? this.authorId,
      companyId: companyId ?? this.companyId,
      status: status ?? this.status,
      viewsCount: viewsCount ?? this.viewsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      company: company ?? this.company,
      author: author ?? this.author,
    );
  }
}

class JobAuthor {
  final int id;
  final String email;
  final String phone;
  final String firstName;
  final String lastName;
  final String role;
  final String? avatar;
  final String? telegramId;
  final bool isActive;
  final bool isVerified;

  JobAuthor({
    required this.id,
    required this.email,
    required this.phone,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.avatar,
    this.telegramId,
    this.isActive = true,
    this.isVerified = false,
  });

  factory JobAuthor.fromJson(Map<String, dynamic> json) {
    return JobAuthor(
      id: json['id'] as int,
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      avatar: json['avatar'] as String?,
      telegramId: json['telegram_id'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }
}
