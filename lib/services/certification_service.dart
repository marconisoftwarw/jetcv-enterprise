import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../models/certification.dart';
import '../models/certification_support.dart';

class CertificationService {
  static final CertificationService _instance =
      CertificationService._internal();
  factory CertificationService() => _instance;
  CertificationService._internal();

  final ImagePicker _imagePicker = ImagePicker();

  // API endpoints per bypassare RLS
  static const String _baseUrl = 'https://skqsuxmdfqxbkhmselaz.supabase.co';
  static const String _apiKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNrcXN1eG1kZnF4YmtobXNlbGF6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYwNjQxMDMsImV4cCI6MjA3MTY0MDEwM30.NkwMkK6wZVPv2G_U39Q-rOMT5yUKLvPePnfXHKMR6JU';

  // KYC API endpoints
  static const String _kycVerifyCallApi = '/functions/v1/verify-call-api';
  static const String _kycCheckVeriffSession =
      '/functions/v1/check-veriff-session';

  // Metodi per le certificazioni
  Future<List<Certification>> getCertifications({
    String? legalEntityId,
    String? userId,
    CertificationStatus? status,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/rest/v1/certification'),
        headers: {
          'apikey': _apiKey,
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        List<Certification> certifications = data
            .map((json) => Certification.fromJson(json))
            .toList();

        // Filtra per entità legale
        if (legalEntityId != null) {
          certifications = certifications
              .where((c) => c.idLegalEntity == legalEntityId)
              .toList();
        }

        // Filtra per utente
        if (userId != null) {
          certifications = certifications
              .where((c) => c.idLegalEntity == userId)
              .toList();
        }

        // Filtra per status
        if (status != null) {
          certifications = certifications
              .where((c) => c.status == status)
              .toList();
        }

        return certifications;
      } else {
        throw Exception(
          'Failed to load certifications: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error getting certifications: $e');
      return [];
    }
  }

  Future<Certification?> getCertificationById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/rest/v1/certification?id=eq.$id'),
        headers: {
          'apikey': _apiKey,
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return Certification.fromJson(data.first);
        }
      }
      return null;
    } catch (e) {
      print('Error getting certification: $e');
      return null;
    }
  }

  Future<Certification?> createCertification(
    Certification certification,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/rest/v1/certification'),
        headers: {
          'apikey': _apiKey,
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(certification.toJson()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Certification.fromJson(data);
      } else {
        throw Exception(
          'Failed to create certification: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error creating certification: $e');
      return null;
    }
  }

  Future<Certification?> updateCertification(
    Certification certification,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse(
          '$_baseUrl/rest/v1/certification?id=eq.${certification.idCertification}',
        ),
        headers: {
          'apikey': _apiKey,
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(certification.toJson()),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return Certification.fromJson(data.first);
        }
      }
      return null;
    } catch (e) {
      print('Error updating certification: $e');
      return null;
    }
  }

  Future<bool> deleteCertification(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/rest/v1/certification?id=eq.$id'),
        headers: {'apikey': _apiKey, 'Authorization': 'Bearer $_apiKey'},
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Error deleting certification: $e');
      return false;
    }
  }

  // Metodi per i media
  Future<CertificationMedia?> captureMedia(String type) async {
    try {
      XFile? file;

      switch (type) {
        case MediaType.camera:
          file = await _imagePicker.pickImage(source: ImageSource.camera);
          break;
        case MediaType.gallery:
          file = await _imagePicker.pickImage(source: ImageSource.gallery);
          break;
        case MediaType.liveVideo:
          file = await _imagePicker.pickVideo(source: ImageSource.camera);
          break;
        case MediaType.fileAttachment:
          // Per ora usiamo la galleria per i file
          file = await _imagePicker.pickImage(source: ImageSource.gallery);
          break;
      }

      if (file != null) {
        // Qui dovresti caricare il file su Supabase Storage
        // Per ora restituiamo un URL temporaneo
        return CertificationMedia(
          idCertification: 'temp_certification',
          type: MediaType.camera, // Default type
          url: file.path,
          createdAt: DateTime.now(),
        );
      }

      return null;
    } catch (e) {
      print('Error capturing media: $e');
      return null;
    }
  }

  // Metodi per la geolocalizzazione
  Future<CertificationLocation?> getCurrentLocation() async {
    try {
      // Verifica i permessi
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      // Ottieni la posizione corrente
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return CertificationLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  // Metodi per i timestamp fidati
  Future<CertificationTimestamp> getTrustedTimestamp() async {
    try {
      // Per ora usiamo il timestamp del sistema
      // In produzione, dovresti usare un servizio di timestamp fidato
      return CertificationTimestamp(
        timestamp: DateTime.now(),
        source: TimestampSource.system,
        sourceDetails: 'System clock',
        isTrusted: false, // Cambia in true quando usi un servizio fidato
      );
    } catch (e) {
      print('Error getting trusted timestamp: $e');
      // Fallback al timestamp manuale
      return CertificationTimestamp(
        timestamp: DateTime.now(),
        source: TimestampSource.manual,
        sourceDetails: 'Manual fallback',
        isTrusted: false,
      );
    }
  }

  // Metodi per il KYC
  Future<Map<String, dynamic>?> verifyCallApi(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$_kycVerifyCallApi'),
        headers: {
          'apikey': _apiKey,
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('KYC verification failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in KYC verification: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> checkVeriffSession(String sessionId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$_kycCheckVeriffSession'),
        headers: {
          'apikey': _apiKey,
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'sessionId': sessionId}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Veriff session check failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error checking Veriff session: $e');
      return null;
    }
  }

  // Metodi per la sincronizzazione
  Future<bool> syncCertification(String id) async {
    try {
      final certification = await getCertificationById(id);
      if (certification == null) return false;

      // Aggiorna lo status a sincronizzato
      final updatedCertification = certification.copyWith(
        status: CertificationStatus.submitted,
        updatedT: DateTime.now(),
      );

      final result = await updateCertification(updatedCertification);
      return result != null;
    } catch (e) {
      print('Error syncing certification: $e');
      return false;
    }
  }

  Future<bool> markAsWaitingSync(String id) async {
    try {
      final certification = await getCertificationById(id);
      if (certification == null) return false;

      final updatedCertification = certification.copyWith(
        status: CertificationStatus.draft,
      );

      final result = await updateCertification(updatedCertification);
      return result != null;
    } catch (e) {
      print('Error marking certification as waiting sync: $e');
      return false;
    }
  }

  // Metodi per la gestione offline
  Future<void> saveOfflineData(Certification certification) async {
    try {
      // Salva i dati offline localmente
      // In produzione, usa un database locale come SQLite o Hive
      final offlineData = jsonEncode(certification.toJson());

      // Per ora, stampiamo i dati offline
      print('Offline data saved: $offlineData');
    } catch (e) {
      print('Error saving offline data: $e');
    }
  }

  Future<List<Certification>> getOfflineCertifications() async {
    try {
      // Carica le certificazioni offline
      // In produzione, carica da un database locale
      return [];
    } catch (e) {
      print('Error getting offline certifications: $e');
      return [];
    }
  }

  // Metodi per la verifica OTP e QR
  Future<bool> verifyOTP(String otp, String userId) async {
    try {
      // Implementa la verifica OTP
      // Per ora, accetta qualsiasi OTP di 6 cifre
      return otp.length == 6 && int.tryParse(otp) != null;
    } catch (e) {
      print('Error verifying OTP: $e');
      return false;
    }
  }

  Future<String?> scanQRCode() async {
    try {
      // Implementa la scansione del codice QR
      // Per ora, restituisce un ID temporaneo
      return 'qr_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      print('Error scanning QR code: $e');
      return null;
    }
  }

  // Metodi per la gestione degli utenti
  Future<bool> addUserToCertification(
    String certificationId,
    String userId,
  ) async {
    try {
      final certification = await getCertificationById(certificationId);
      if (certification == null) return false;

      // TODO: Implementare l'aggiunta di utenti alla certificazione
      // Questo richiede l'aggiornamento del modello Certification per supportare gli utenti
      print('Adding user $userId to certification $certificationId');

      return true;
    } catch (e) {
      print('Error adding user to certification: $e');
      return false;
    }
  }

  // Metodi per la gestione degli allegati
  Future<bool> uploadAttachment(
    String certificationId,
    File file,
    String? description,
  ) async {
    try {
      // TODO: Implementare il caricamento degli allegati
      // Questo richiede l'aggiornamento del modello Certification per supportare gli allegati
      print(
        'Uploading attachment for certification $certificationId: ${file.path}',
      );

      return true;
    } catch (e) {
      print('Error uploading attachment: $e');
      return false;
    }
  }
}
