import 'job_model.dart';

class ApplicationModel {
  final int id;
  final int jobId;
  final int applicantId;
  final String coverLetter;
  final String status;
  final String createdAt;
  final String updatedAt;
  final JobAuthor? applicant; // The applicant's profile info matches JobAuthor structure in the JSON
  final JobModel? job;
  final String? conversationId;

  ApplicationModel({
    required this.id,
    required this.jobId,
    required this.applicantId,
    required this.coverLetter,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.applicant,
    this.job,
    this.conversationId,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id'] as int,
      jobId: json['job_id'] as int,
      applicantId: json['applicant_id'] as int,
      coverLetter: json['cover_letter'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      applicant: json['applicant'] != null ? JobAuthor.fromJson(json['applicant'] as Map<String, dynamic>) : null,
      job: json['job'] != null ? JobModel.fromJson(json['job'] as Map<String, dynamic>) : null,
      conversationId: json['conversation_id'] as String?,
    );
  }

  ApplicationModel copyWith({
    int? id,
    int? jobId,
    int? applicantId,
    String? coverLetter,
    String? status,
    String? createdAt,
    String? updatedAt,
    JobAuthor? applicant,
    JobModel? job,
    String? conversationId,
  }) {
    return ApplicationModel(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      applicantId: applicantId ?? this.applicantId,
      coverLetter: coverLetter ?? this.coverLetter,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      applicant: applicant ?? this.applicant,
      job: job ?? this.job,
      conversationId: conversationId ?? this.conversationId,
    );
  }
}
