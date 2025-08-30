import 'package:uuid/uuid.dart';

enum MediaType { camera, gallery, liveVideo, fileAttachment }

enum TimestampSource { system, manual, trusted }

class CertificationMedia {
  final String idMedia;
  final String idCertification;
  final MediaType type;
  final String url;
  final String? thumbnailUrl;
  final String? description;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  CertificationMedia({
    String? idMedia,
    required this.idCertification,
    required this.type,
    required this.url,
    this.thumbnailUrl,
    this.description,
    DateTime? createdAt,
    this.metadata,
  }) : idMedia = idMedia ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  factory CertificationMedia.fromJson(Map<String, dynamic> json) {
    return CertificationMedia(
      idMedia: json['id_media'],
      idCertification: json['id_certification'],
      type: MediaType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => MediaType.camera,
      ),
      url: json['url'],
      thumbnailUrl: json['thumbnail_url'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_media': idMedia,
      'id_certification': idCertification,
      'type': type.toString().split('.').last,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  CertificationMedia copyWith({
    String? idMedia,
    String? idCertification,
    MediaType? type,
    String? url,
    String? thumbnailUrl,
    String? description,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return CertificationMedia(
      idMedia: idMedia ?? this.idMedia,
      idCertification: idCertification ?? this.idCertification,
      type: type ?? this.type,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

class CertificationLocation {
  final String idLocation;
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final DateTime timestamp;

  CertificationLocation({
    String? idLocation,
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    DateTime? timestamp,
  }) : idLocation = idLocation ?? const Uuid().v4(),
       timestamp = timestamp ?? DateTime.now();

  factory CertificationLocation.fromJson(Map<String, dynamic> json) {
    return CertificationLocation(
      idLocation: json['id_location'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      address: json['address'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postal_code'],
      country: json['country'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_location': idLocation,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  CertificationLocation copyWith({
    String? idLocation,
    double? latitude,
    double? longitude,
    String? address,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    DateTime? timestamp,
  }) {
    return CertificationLocation(
      idLocation: idLocation ?? this.idLocation,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  String get displayAddress {
    final parts = <String>[];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (postalCode != null && postalCode!.isNotEmpty) parts.add(postalCode!);
    if (country != null && country!.isNotEmpty) parts.add(country!);

    if (parts.isNotEmpty) {
      return parts.join(', ');
    }
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }
}

class CertificationTimestamp {
  final String idTimestamp;
  final DateTime timestamp;
  final TimestampSource source;
  final String? sourceDetails;
  final bool isTrusted;
  final DateTime createdAt;

  CertificationTimestamp({
    String? idTimestamp,
    required this.timestamp,
    required this.source,
    this.sourceDetails,
    this.isTrusted = false,
    DateTime? createdAt,
  }) : idTimestamp = idTimestamp ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  factory CertificationTimestamp.fromJson(Map<String, dynamic> json) {
    return CertificationTimestamp(
      idTimestamp: json['id_timestamp'],
      timestamp: DateTime.parse(json['timestamp']),
      source: TimestampSource.values.firstWhere(
        (e) => e.toString().split('.').last == json['source'],
        orElse: () => TimestampSource.system,
      ),
      sourceDetails: json['source_details'],
      isTrusted: json['is_trusted'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_timestamp': idTimestamp,
      'timestamp': timestamp.toIso8601String(),
      'source': source.toString().split('.').last,
      'source_details': sourceDetails,
      'is_trusted': isTrusted,
      'created_at': createdAt.toIso8601String(),
    };
  }

  CertificationTimestamp copyWith({
    String? idTimestamp,
    DateTime? timestamp,
    TimestampSource? source,
    String? sourceDetails,
    bool? isTrusted,
    DateTime? createdAt,
  }) {
    return CertificationTimestamp(
      idTimestamp: idTimestamp ?? this.idTimestamp,
      timestamp: timestamp ?? this.timestamp,
      source: source ?? this.source,
      sourceDetails: sourceDetails ?? this.sourceDetails,
      isTrusted: isTrusted ?? this.isTrusted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get sourceDisplayName {
    switch (source) {
      case TimestampSource.system:
        return 'Sistema';
      case TimestampSource.manual:
        return 'Manuale';
      case TimestampSource.trusted:
        return 'Fidato';
    }
  }
}

class CertificationAttachment {
  final String idAttachment;
  final String idCertification;
  final String fileName;
  final String fileUrl;
  final String fileType;
  final int fileSize;
  final DateTime createdAt;
  final String? description;

  CertificationAttachment({
    String? idAttachment,
    required this.idCertification,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    required this.fileSize,
    DateTime? createdAt,
    this.description,
  }) : idAttachment = idAttachment ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  factory CertificationAttachment.fromJson(Map<String, dynamic> json) {
    return CertificationAttachment(
      idAttachment: json['id_attachment'],
      idCertification: json['id_certification'],
      fileName: json['file_name'],
      fileUrl: json['file_url'],
      fileType: json['file_type'],
      fileSize: json['file_size'],
      createdAt: DateTime.parse(json['created_at']),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_attachment': idAttachment,
      'id_certification': idCertification,
      'file_name': fileName,
      'file_url': fileUrl,
      'file_type': fileType,
      'file_size': fileSize,
      'created_at': createdAt.toIso8601String(),
      'description': description,
    };
  }

  CertificationAttachment copyWith({
    String? idAttachment,
    String? idCertification,
    String? fileName,
    String? fileUrl,
    String? fileType,
    int? fileSize,
    DateTime? createdAt,
    String? description,
  }) {
    return CertificationAttachment(
      idAttachment: idAttachment ?? this.idAttachment,
      idCertification: idCertification ?? this.idCertification,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
    );
  }

  String get fileSizeDisplay {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}

class CertificationUser {
  final String idCertificationUser;
  final String idCertification;
  final String idUser;
  final DateTime addedAt;
  final bool isVerified;
  final String? verificationMethod;
  final Map<String, dynamic>? additionalInfo;

  CertificationUser({
    String? idCertificationUser,
    required this.idCertification,
    required this.idUser,
    DateTime? addedAt,
    this.isVerified = false,
    this.verificationMethod,
    this.additionalInfo,
  }) : idCertificationUser = idCertificationUser ?? const Uuid().v4(),
       addedAt = addedAt ?? DateTime.now();

  factory CertificationUser.fromJson(Map<String, dynamic> json) {
    return CertificationUser(
      idCertificationUser: json['id_certification_user'],
      idCertification: json['id_certification'],
      idUser: json['id_user'],
      addedAt: DateTime.parse(json['added_at']),
      isVerified: json['is_verified'] ?? false,
      verificationMethod: json['verification_method'],
      additionalInfo: json['additional_info'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_certification_user': idCertificationUser,
      'id_certification': idCertification,
      'id_user': idUser,
      'added_at': addedAt.toIso8601String(),
      'is_verified': isVerified,
      'verification_method': verificationMethod,
      'additional_info': additionalInfo,
    };
  }

  CertificationUser copyWith({
    String? idCertificationUser,
    String? idCertification,
    String? idUser,
    DateTime? addedAt,
    bool? isVerified,
    String? verificationMethod,
    Map<String, dynamic>? additionalInfo,
  }) {
    return CertificationUser(
      idCertificationUser: idCertificationUser ?? this.idCertificationUser,
      idCertification: idCertification ?? this.idCertification,
      idUser: idUser ?? this.idUser,
      addedAt: addedAt ?? this.addedAt,
      isVerified: isVerified ?? this.isVerified,
      verificationMethod: verificationMethod ?? this.verificationMethod,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }
}
