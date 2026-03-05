class CompanyModel {
  final int id;
  final String name;
  final String description;
  final String? logo;
  final String website;
  final String location;
  final String industry;
  final String size;
  final int ownerId;
  final bool isVerified;
  final String createdAt;
  final String updatedAt;

  CompanyModel({
    required this.id,
    required this.name,
    required this.description,
    this.logo,
    required this.website,
    required this.location,
    required this.industry,
    required this.size,
    required this.ownerId,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      logo: json['logo'] as String?,
      website: json['website'] as String? ?? '',
      location: json['location'] as String? ?? '',
      industry: json['industry'] as String? ?? '',
      size: json['size'] as String? ?? '',
      ownerId: json['owner_id'] as int? ?? 0,
      isVerified: json['is_verified'] as bool? ?? false,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'logo': logo,
      'website': website,
      'location': location,
      'industry': industry,
      'size': size,
    };
  }

  CompanyModel copyWith({
    int? id,
    String? name,
    String? description,
    String? logo,
    String? website,
    String? location,
    String? industry,
    String? size,
    int? ownerId,
    bool? isVerified,
    String? createdAt,
    String? updatedAt,
  }) {
    return CompanyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logo: logo ?? this.logo,
      website: website ?? this.website,
      location: location ?? this.location,
      industry: industry ?? this.industry,
      size: size ?? this.size,
      ownerId: ownerId ?? this.ownerId,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
