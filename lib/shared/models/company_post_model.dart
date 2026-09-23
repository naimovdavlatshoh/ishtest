import 'job_model.dart';
import 'company_model.dart';

/// Backend-driven company/job-board post (POST /api/v1/posts) -- distinct
/// from the unrelated feed `PostModel` (social feed mock posts).
class CompanyPostModel {
  final int id;
  final String title;
  final String content;
  final String? image;
  final int authorId;
  final int? companyId;
  final String status;
  final int likesCount;
  final bool liked;
  final String createdAt;
  final String updatedAt;
  final CompanyModel? company;
  final JobAuthor? author;

  CompanyPostModel({
    required this.id,
    required this.title,
    required this.content,
    this.image,
    required this.authorId,
    this.companyId,
    required this.status,
    required this.likesCount,
    this.liked = false,
    required this.createdAt,
    required this.updatedAt,
    this.company,
    this.author,
  });

  factory CompanyPostModel.fromJson(Map<String, dynamic> json) {
    return CompanyPostModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      image: json['image'] as String?,
      authorId: json['author_id'] as int,
      companyId: json['company_id'] as int?,
      status: json['status'] as String? ?? 'published',
      likesCount: json['likes_count'] as int? ?? 0,
      liked: json['liked'] as bool? ?? false,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      company: json['company'] != null ? CompanyModel.fromJson(json['company'] as Map<String, dynamic>) : null,
      author: json['author'] != null ? JobAuthor.fromJson(json['author'] as Map<String, dynamic>) : null,
    );
  }

  CompanyPostModel copyWith({bool? liked, int? likesCount, String? status}) {
    return CompanyPostModel(
      id: id,
      title: title,
      content: content,
      image: image,
      authorId: authorId,
      companyId: companyId,
      status: status ?? this.status,
      likesCount: likesCount ?? this.likesCount,
      liked: liked ?? this.liked,
      createdAt: createdAt,
      updatedAt: updatedAt,
      company: company,
      author: author,
    );
  }
}
