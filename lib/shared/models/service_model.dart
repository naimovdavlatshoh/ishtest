import 'job_model.dart';

const Map<String, String> serviceCategoryLabels = {
  'plumber': 'Santexnik',
  'electrician': 'Elektrik',
  'cleaner': 'Tozalash',
  'handyman': 'Usta',
  'painter': "Bo'yoqchi",
  'nanny': 'Enaga',
  'tutor': 'Repetitor',
  'driver': 'Haydovchi',
  'beauty': "Go'zallik",
  'other': 'Boshqa',
};

const Map<String, String> servicePriceTypeLabels = {
  'hourly': 'Soatlik',
  'fixed': "Belgilangan narx",
  'negotiable': 'Kelishiladi',
};

class ServiceModel {
  final int id;
  final String title;
  final String description;
  final String location;
  final String category;
  final int? priceMin;
  final int? priceMax;
  final String priceCurrency;
  final String priceType;
  final String? image;
  final int authorId;
  final String status;
  final int viewsCount;
  final String createdAt;
  final String updatedAt;
  final JobAuthor? author;

  ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.category,
    this.priceMin,
    this.priceMax,
    this.priceCurrency = 'UZS',
    required this.priceType,
    this.image,
    required this.authorId,
    required this.status,
    required this.viewsCount,
    required this.createdAt,
    required this.updatedAt,
    this.author,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      location: json['location'] as String? ?? '',
      category: json['category'] as String? ?? 'other',
      priceMin: json['price_min'] as int?,
      priceMax: json['price_max'] as int?,
      priceCurrency: json['price_currency'] as String? ?? 'UZS',
      priceType: json['price_type'] as String? ?? 'negotiable',
      image: json['image'] as String?,
      authorId: json['author_id'] as int,
      status: json['status'] as String? ?? 'active',
      viewsCount: json['views_count'] as int? ?? 0,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      author: json['author'] != null ? JobAuthor.fromJson(json['author'] as Map<String, dynamic>) : null,
    );
  }

  ServiceModel copyWith({String? status}) {
    return ServiceModel(
      id: id,
      title: title,
      description: description,
      location: location,
      category: category,
      priceMin: priceMin,
      priceMax: priceMax,
      priceCurrency: priceCurrency,
      priceType: priceType,
      image: image,
      authorId: authorId,
      status: status ?? this.status,
      viewsCount: viewsCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
      author: author,
    );
  }
}
