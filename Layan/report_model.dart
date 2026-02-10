class ReportModel {
  final String? id;
  final String userId;
  final String title;
  final String campusSection; // "male" or "female"
  final String category; // "electricity", "damages", "other"
  final String buildingId;
  final String buildingName;
  final String locationDetails;
  final double? latitude;
  final double? longitude;
  final String description;
  final String? photoUrl;
  final String status; // "under_processing" or "fixed"
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ReportModel({
    this.id,
    required this.userId,
    required this.title,
    required this.campusSection,
    required this.category,
    required this.buildingId,
    required this.buildingName,
    required this.locationDetails,
    this.latitude,
    this.longitude,
    required this.description,
    this.photoUrl,
    this.status = 'under_processing',
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'campusSection': campusSection,
      'category': category,
      'buildingId': buildingId,
      'buildingName': buildingName,
      'locationDetails': locationDetails,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'photoUrl': photoUrl,
      'status': status,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory ReportModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ReportModel(
      id: documentId,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      campusSection: map['campusSection'] ?? '',
      category: map['category'] ?? '',
      buildingId: map['buildingId'] ?? '',
      buildingName: map['buildingName'] ?? '',
      locationDetails: map['locationDetails'] ?? '',
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      description: map['description'] ?? '',
      photoUrl: map['photoUrl'],
      status: map['status'] ?? 'under_processing',
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
    );
  }

  ReportModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? campusSection,
    String? category,
    String? buildingId,
    String? buildingName,
    String? locationDetails,
    double? latitude,
    double? longitude,
    String? description,
    String? photoUrl,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReportModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      campusSection: campusSection ?? this.campusSection,
      category: category ?? this.category,
      buildingId: buildingId ?? this.buildingId,
      buildingName: buildingName ?? this.buildingName,
      locationDetails: locationDetails ?? this.locationDetails,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      photoUrl: photoUrl ?? this.photoUrl,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
