import 'package:uuid/uuid.dart';

enum CertificationCategoryStatus { active, inactive }

class CertificationCategory {
  final String idCategory;
  final String name;
  final String description;
  final String? imageUrl;
  final String? iconName;
  final String colorCode;
  final CertificationCategoryStatus status;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  CertificationCategory({
    String? idCategory,
    required this.name,
    required this.description,
    this.imageUrl,
    this.iconName,
    required this.colorCode,
    this.status = CertificationCategoryStatus.active,
    this.sortOrder = 0,
    DateTime? createdAt,
    this.updatedAt,
    this.metadata,
  }) : idCategory = idCategory ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  factory CertificationCategory.fromJson(Map<String, dynamic> json) {
    return CertificationCategory(
      idCategory: json['idCategory'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      iconName: json['iconName'],
      colorCode: json['colorCode'],
      status: CertificationCategoryStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => CertificationCategoryStatus.active,
      ),
      sortOrder: json['sortOrder'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idCategory': idCategory,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'iconName': iconName,
      'colorCode': colorCode,
      'status': status.toString().split('.').last,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  CertificationCategory copyWith({
    String? idCategory,
    String? name,
    String? description,
    String? imageUrl,
    String? iconName,
    String? colorCode,
    CertificationCategoryStatus? status,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return CertificationCategory(
      idCategory: idCategory ?? this.idCategory,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      iconName: iconName ?? this.iconName,
      colorCode: colorCode ?? this.colorCode,
      status: status ?? this.status,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isActive => status == CertificationCategoryStatus.active;

  // Predefined categories with default images and colors
  static List<CertificationCategory> getDefaultCategories() {
    return [
      CertificationCategory(
        name: 'Qualità ISO',
        description: 'Certificazioni di qualità secondo standard ISO',
        iconName: 'quality_check',
        colorCode: '#2196F3',
        sortOrder: 1,
      ),
      CertificationCategory(
        name: 'Sicurezza sul Lavoro',
        description: 'Certificazioni per la sicurezza e salute sul lavoro',
        iconName: 'security',
        colorCode: '#FF9800',
        sortOrder: 2,
      ),
      CertificationCategory(
        name: 'Ambiente',
        description: 'Certificazioni ambientali e sostenibilità',
        iconName: 'eco',
        colorCode: '#4CAF50',
        sortOrder: 3,
      ),
      CertificationCategory(
        name: 'Alimentare',
        description: 'Certificazioni per il settore alimentare',
        iconName: 'restaurant',
        colorCode: '#E91E63',
        sortOrder: 4,
      ),
      CertificationCategory(
        name: 'IT e Cybersecurity',
        description: 'Certificazioni tecnologiche e di sicurezza informatica',
        iconName: 'computer',
        colorCode: '#9C27B0',
        sortOrder: 5,
      ),
      CertificationCategory(
        name: 'Edilizia e Costruzioni',
        description: 'Certificazioni per il settore edile e costruzioni',
        iconName: 'construction',
        colorCode: '#795548',
        sortOrder: 6,
      ),
      CertificationCategory(
        name: 'Energia',
        description: 'Certificazioni energetiche e rinnovabili',
        iconName: 'bolt',
        colorCode: '#FFEB3B',
        sortOrder: 7,
      ),
      CertificationCategory(
        name: 'Automotive',
        description: 'Certificazioni per il settore automobilistico',
        iconName: 'directions_car',
        colorCode: '#607D8B',
        sortOrder: 8,
      ),
      CertificationCategory(
        name: 'Tessile e Moda',
        description: 'Certificazioni per il settore tessile e della moda',
        iconName: 'checkroom',
        colorCode: '#F44336',
        sortOrder: 9,
      ),
      CertificationCategory(
        name: 'Farmaceutico',
        description: 'Certificazioni per il settore farmaceutico e medicale',
        iconName: 'medical_services',
        colorCode: '#00BCD4',
        sortOrder: 10,
      ),
      CertificationCategory(
        name: 'Finanziario',
        description: 'Certificazioni per servizi finanziari e bancari',
        iconName: 'account_balance',
        colorCode: '#3F51B5',
        sortOrder: 11,
      ),
      CertificationCategory(
        name: 'Logistica e Trasporti',
        description: 'Certificazioni per logistica e trasporti',
        iconName: 'local_shipping',
        colorCode: '#FF5722',
        sortOrder: 12,
      ),
      CertificationCategory(
        name: 'Turismo e Ospitalità',
        description: 'Certificazioni per il settore turistico e alberghiero',
        iconName: 'hotel',
        colorCode: '#8BC34A',
        sortOrder: 13,
      ),
      CertificationCategory(
        name: 'Formazione',
        description: 'Certificazioni per enti di formazione e educazione',
        iconName: 'school',
        colorCode: '#673AB7',
        sortOrder: 14,
      ),
      CertificationCategory(
        name: 'Altro',
        description: 'Altre tipologie di certificazione',
        iconName: 'more_horiz',
        colorCode: '#9E9E9E',
        sortOrder: 15,
      ),
    ];
  }
}
