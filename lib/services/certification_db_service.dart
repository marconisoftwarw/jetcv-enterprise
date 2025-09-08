import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/certification_db.dart';
import 'certification_edge_service.dart';

class CertificationDBService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Certification CRUD operations
  Future<CertificationDB> createCertification(
    CertificationDB certification,
  ) async {
    try {
      final result = await CertificationEdgeService.createCertification(
        idCertifier: certification.idCertifier,
        idLegalEntity: certification.idLegalEntity,
        idLocation: certification.idLocation,
        nUsers: certification.nUsers,
        idCertificationCategory: certification.idCertificationCategory,
        status: certification.status.name,
        sentAt: certification.sentAt?.toIso8601String(),
        draftAt: certification.draftAt?.toIso8601String(),
        closedAt: certification.closedAt?.toIso8601String(),
      );

      if (result != null) {
        return CertificationDB.fromJson(result);
      }
      throw Exception('Failed to create certification: No data returned');
    } catch (e) {
      throw Exception('Failed to create certification: $e');
    }
  }

  Future<List<CertificationDB>> getCertificationsByCertifier(
    String idCertifier,
  ) async {
    try {
      final result = await CertificationEdgeService.getCertifications(
        idCertifier: idCertifier,
        limit: 100,
        offset: 0,
      );

      if (result != null && result['data'] != null) {
        final List<dynamic> data = result['data'];
        return data
            .map<CertificationDB>((json) => CertificationDB.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch certifications: $e');
    }
  }

  Future<CertificationDB> getCertificationById(String idCertification) async {
    try {
      final result = await CertificationEdgeService.getCertification(
        idCertification,
      );
      if (result != null) {
        return CertificationDB.fromJson(result);
      }
      throw Exception('Certification not found');
    } catch (e) {
      throw Exception('Failed to fetch certification: $e');
    }
  }

  Future<CertificationDB> updateCertification(
    CertificationDB certification,
  ) async {
    try {
      final result = await CertificationEdgeService.updateCertification(
        certification.idCertification,
        status: certification.status.name,
        sentAt: certification.sentAt?.toIso8601String(),
        draftAt: certification.draftAt?.toIso8601String(),
        closedAt: certification.closedAt?.toIso8601String(),
        nUsers: certification.nUsers,
      );

      if (result != null) {
        return CertificationDB.fromJson(result);
      }
      throw Exception('Failed to update certification: No data returned');
    } catch (e) {
      throw Exception('Failed to update certification: $e');
    }
  }

  Future<void> deleteCertification(String idCertification) async {
    try {
      final success = await CertificationEdgeService.deleteCertification(
        idCertification,
      );
      if (!success) {
        throw Exception('Failed to delete certification');
      }
    } catch (e) {
      throw Exception('Failed to delete certification: $e');
    }
  }

  // Certification Category CRUD operations
  Future<CertificationCategoryDB> createCertificationCategory(
    CertificationCategoryDB category,
  ) async {
    try {
      final response = await _supabase
          .from('certification_category')
          .insert(category.toJson())
          .select()
          .single();

      return CertificationCategoryDB.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create certification category: $e');
    }
  }

  Future<List<CertificationCategoryDB>> getCertificationCategoriesByLegalEntity(
    String idLegalEntity,
  ) async {
    try {
      final response = await _supabase
          .from('certification_category')
          .select()
          .eq('id_legal_entity', idLegalEntity)
          .order('order', ascending: true);

      return (response as List)
          .map((json) => CertificationCategoryDB.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch certification categories: $e');
    }
  }

  Future<CertificationCategoryDB> updateCertificationCategory(
    CertificationCategoryDB category,
  ) async {
    try {
      final response = await _supabase
          .from('certification_category')
          .update(category.toJson())
          .eq('id_certification_category', category.idCertificationCategory)
          .select()
          .single();

      return CertificationCategoryDB.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update certification category: $e');
    }
  }

  Future<void> deleteCertificationCategory(
    String idCertificationCategory,
  ) async {
    try {
      await _supabase
          .from('certification_category')
          .delete()
          .eq('id_certification_category', idCertificationCategory);
    } catch (e) {
      throw Exception('Failed to delete certification category: $e');
    }
  }

  // Certification Information CRUD operations
  Future<CertificationInformationDB> createCertificationInformation(
    CertificationInformationDB information,
  ) async {
    try {
      final response = await _supabase
          .from('certification_information')
          .insert(information.toJson())
          .select()
          .single();

      return CertificationInformationDB.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create certification information: $e');
    }
  }

  Future<List<CertificationInformationDB>>
  getCertificationInformationsByLegalEntity(String idLegalEntity) async {
    try {
      final response = await _supabase
          .from('certification_information')
          .select()
          .eq('id_legal_entity', idLegalEntity)
          .order('order', ascending: true);

      return (response as List)
          .map((json) => CertificationInformationDB.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch certification informations: $e');
    }
  }

  Future<CertificationInformationDB> updateCertificationInformation(
    CertificationInformationDB information,
  ) async {
    try {
      final response = await _supabase
          .from('certification_information')
          .update(information.toJson())
          .eq(
            'id_certification_information',
            information.idCertificationInformation,
          )
          .select()
          .single();

      return CertificationInformationDB.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update certification information: $e');
    }
  }

  Future<void> deleteCertificationInformation(
    String idCertificationInformation,
  ) async {
    try {
      await _supabase
          .from('certification_information')
          .delete()
          .eq('id_certification_information', idCertificationInformation);
    } catch (e) {
      throw Exception('Failed to delete certification information: $e');
    }
  }

  // Certification Media CRUD operations
  Future<CertificationMediaDB> createCertificationMedia(
    CertificationMediaDB media,
  ) async {
    try {
      final response = await _supabase
          .from('certification_media')
          .insert(media.toJson())
          .select()
          .single();

      return CertificationMediaDB.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create certification media: $e');
    }
  }

  Future<List<CertificationMediaDB>> getCertificationMediasByCertification(
    String idCertification,
  ) async {
    try {
      final result = await CertificationEdgeService.getCertificationMedia(
        idCertification,
      );
      return result
          .map<CertificationMediaDB>(
            (json) => CertificationMediaDB.fromJson(json),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch certification medias: $e');
    }
  }

  Future<CertificationMediaDB> updateCertificationMedia(
    CertificationMediaDB media,
  ) async {
    try {
      final result = await CertificationEdgeService.updateMedia(
        media.idCertificationMedia,
        name: media.name,
        description: media.description,
        acquisitionType: media.acquisitionType.name,
        capturedAt: media.capturedAt.toIso8601String(),
        fileType: media.fileType.name,
        idLocation: media.idLocation,
      );

      if (result != null) {
        return CertificationMediaDB.fromJson(result);
      }
      throw Exception('Failed to update certification media: No data returned');
    } catch (e) {
      throw Exception('Failed to update certification media: $e');
    }
  }

  Future<void> deleteCertificationMedia(String idCertificationMedia) async {
    try {
      final success = await CertificationEdgeService.deleteMedia(
        idCertificationMedia,
      );
      if (!success) {
        throw Exception('Failed to delete certification media');
      }
    } catch (e) {
      throw Exception('Failed to delete certification media: $e');
    }
  }

  // Certification User CRUD operations
  Future<CertificationUserDB> createCertificationUser(
    CertificationUserDB certificationUser,
  ) async {
    try {
      final response = await _supabase
          .from('certification_user')
          .insert(certificationUser.toJson())
          .select()
          .single();

      return CertificationUserDB.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create certification user: $e');
    }
  }

  Future<List<CertificationUserDB>> getCertificationUsersByCertification(
    String idCertification,
  ) async {
    try {
      final response = await _supabase
          .from('certification_user')
          .select()
          .eq('id_certification', idCertification)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => CertificationUserDB.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch certification users: $e');
    }
  }

  Future<CertificationUserDB> updateCertificationUser(
    CertificationUserDB certificationUser,
  ) async {
    try {
      final response = await _supabase
          .from('certification_user')
          .update(certificationUser.toJson())
          .eq('id_certification_user', certificationUser.idCertificationUser)
          .select()
          .single();

      return CertificationUserDB.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update certification user: $e');
    }
  }

  Future<void> deleteCertificationUser(String idCertificationUser) async {
    try {
      await _supabase
          .from('certification_user')
          .delete()
          .eq('id_certification_user', idCertificationUser);
    } catch (e) {
      throw Exception('Failed to delete certification user: $e');
    }
  }

  // Certification Information Value CRUD operations
  Future<CertificationInformationValueDB> createCertificationInformationValue(
    CertificationInformationValueDB value,
  ) async {
    try {
      final response = await _supabase
          .from('certification_information_value')
          .insert(value.toJson())
          .select()
          .single();

      return CertificationInformationValueDB.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create certification information value: $e');
    }
  }

  Future<List<CertificationInformationValueDB>>
  getCertificationInformationValuesByCertification(
    String idCertification,
  ) async {
    try {
      final response = await _supabase
          .from('certification_information_value')
          .select()
          .eq('id_certification', idCertification);

      return (response as List)
          .map((json) => CertificationInformationValueDB.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch certification information values: $e');
    }
  }

  Future<CertificationInformationValueDB> updateCertificationInformationValue(
    CertificationInformationValueDB value,
  ) async {
    try {
      final response = await _supabase
          .from('certification_information_value')
          .update(value.toJson())
          .eq(
            'id_certification_information_value',
            value.idCertificationInformationValue,
          )
          .select()
          .single();

      return CertificationInformationValueDB.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update certification information value: $e');
    }
  }

  Future<void> deleteCertificationInformationValue(
    int idCertificationInformationValue,
  ) async {
    try {
      await _supabase
          .from('certification_information_value')
          .delete()
          .eq(
            'id_certification_information_value',
            idCertificationInformationValue,
          );
    } catch (e) {
      throw Exception('Failed to delete certification information value: $e');
    }
  }

  // Location CRUD operations
  Future<LocationDB> createLocation(LocationDB location) async {
    try {
      final response = await _supabase
          .from('location')
          .insert(location.toJson())
          .select()
          .single();

      return LocationDB.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create location: $e');
    }
  }

  Future<List<LocationDB>> getLocationsByUser(String idUser) async {
    try {
      final response = await _supabase
          .from('location')
          .select()
          .eq('id_user', idUser)
          .order('acquired_at', ascending: false);

      return (response as List)
          .map((json) => LocationDB.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch locations: $e');
    }
  }

  // Complex queries
  Future<Map<String, dynamic>> getCertificationWithDetails(
    String idCertification,
  ) async {
    try {
      // Get certification with media from Edge Function
      final result = await CertificationEdgeService.getCertification(
        idCertification,
      );
      if (result == null) {
        throw Exception('Certification not found');
      }

      final certification = CertificationDB.fromJson(result);

      // Get category
      final categoryResponse = await _supabase
          .from('certification_category')
          .select()
          .eq(
            'id_certification_category',
            certification.idCertificationCategory,
          )
          .single();
      final category = CertificationCategoryDB.fromJson(categoryResponse);

      // Get users
      final users = await getCertificationUsersByCertification(idCertification);

      // Get medias from Edge Function result
      final medias = result['media'] != null
          ? (result['media'] as List)
                .map<CertificationMediaDB>(
                  (json) => CertificationMediaDB.fromJson(json),
                )
                .toList()
          : <CertificationMediaDB>[];

      // Get information values
      final informationValues =
          await getCertificationInformationValuesByCertification(
            idCertification,
          );

      return {
        'certification': certification,
        'category': category,
        'users': users,
        'medias': medias,
        'informationValues': informationValues,
      };
    } catch (e) {
      throw Exception('Failed to fetch certification with details: $e');
    }
  }

  // Statistics
  Future<Map<String, int>> getCertificationStats(String idCertifier) async {
    try {
      final response = await _supabase
          .from('certification')
          .select('status')
          .eq('id_certifier', idCertifier);

      final stats = <String, int>{};
      for (final item in response as List) {
        final status = item['status'] as String;
        stats[status] = (stats[status] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      throw Exception('Failed to fetch certification stats: $e');
    }
  }
}
