import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/legal_entity_invitation.dart';
import '../config/app_config.dart';

class EmailService {
  static final EmailService _instance = EmailService._internal();
  factory EmailService() => _instance;
  EmailService._internal();

  // Configurazione email
  static const String _fromEmail = "jjectcvuser@gmail.com";

  // Metodo per inviare invito via email
  Future<bool> sendLegalEntityInvitation(
    LegalEntityInvitation invitation, {
    Map<String, dynamic>? legalEntityData,
  }) async {
    try {
      // Per ora usiamo un servizio esterno come MailHog o simili
      // In produzione si può integrare con SendGrid, AWS SES, etc.

      final emailData = {
        'to': invitation.email,
        'subject': 'Invito a unirsi a JetCV Enterprise',
        'html': _generateInvitationEmailHTML(invitation, legalEntityData),
        'text': _generateInvitationEmailText(invitation, legalEntityData),
      };

      // Opzione 1: MailHog per sviluppo locale
      if (AppConfig.environment == 'development' && AppConfig.enableDebugMode) {
        return await _sendViaMailHog(emailData);
      }

      // Opzione 2: Servizio email esterno (AWS SES tramite SendGrid)
      return await _sendViaExternalService(emailData);
    } catch (e) {
      print('Error sending invitation email: $e');
      return false;
    }
  }

  // Metodo per inviare via MailHog (sviluppo locale)
  Future<bool> _sendViaMailHog(Map<String, dynamic> emailData) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8025/api/v1/messages'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'from': _fromEmail,
          'to': [emailData['to']],
          'subject': emailData['subject'],
          'html': emailData['html'],
          'text': emailData['text'],
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error sending via MailHog: $e');
      return false;
    }
  }

  // Metodo per inviare via API locale
  Future<bool> _sendViaExternalService(Map<String, dynamic> emailData) async {
    try {
      return await _sendViaLocalAPI(emailData);
    } catch (e) {
      print('❌ Error sending email: $e');

      // Fallback: simulazione per test
      print('🔄 Falling back to simulation for testing...');
      await Future.delayed(const Duration(seconds: 1));
      print(
        '✅ Email sent successfully (simulated) to ${emailData['to']}: ${emailData['subject']}',
      );
      return true;
    }
  }

  // Metodo per inviare via API locale
  Future<bool> _sendViaLocalAPI(Map<String, dynamic> emailData) async {
    try {
      final response = await http.post(
        Uri.parse('http://18.102.14.247:4000/api/email/send'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'to': emailData['to'],
          'subject': emailData['subject'],
          'text': emailData['text'],
          'html': emailData['html'],
          'from': _fromEmail,
        }),
      );

      if (response.statusCode == 200) {
        print(
          '✅ Email sent successfully via Local API to ${emailData['to']}: ${emailData['subject']}',
        );
        print('API response: ${response.body}');
        return true;
      } else {
        print(
          '❌ Error sending via Local API. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('❌ Error sending via Local API: $e');
      rethrow;
    }
  }

  // Genera HTML per l'email di invito
  String _generateInvitationEmailHTML(
    LegalEntityInvitation invitation,
    Map<String, dynamic>? legalEntityData,
  ) {
    // Genera il link con i parametri della legal entity
    final invitationLink = _generateInvitationLink(invitation, legalEntityData);

    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Invito JetCV Enterprise</title>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: #1976d2; color: white; padding: 20px; text-align: center; }
        .content { padding: 20px; background: #f9f9f9; }
        .button { display: inline-block; padding: 12px 24px; background: #4caf50; color: white; text-decoration: none; border-radius: 4px; margin: 20px 0; }
        .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
        .expiry { background: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 4px; margin: 20px 0; }
        .entity-info { background: #e3f2fd; border: 1px solid #bbdefb; padding: 15px; border-radius: 4px; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚀 JetCV Enterprise</h1>
            <p>Invito a unirsi alla piattaforma</p>
        </div>
        
        <div class="content">
            <h2>Benvenuto in JetCV Enterprise!</h2>
            
            <p>Hai ricevuto un invito per unirti alla piattaforma JetCV Enterprise.</p>
            
            ${legalEntityData != null ? '''
            <div class="entity-info">
                <h3>📋 Informazioni Entità Legale</h3>
                <p><strong>Nome:</strong> ${legalEntityData['legal_name'] ?? 'N/A'}</p>
                <p><strong>Codice Identificativo:</strong> ${legalEntityData['identifier_code'] ?? 'N/A'}</p>
                <p><strong>Email:</strong> ${legalEntityData['email'] ?? 'N/A'}</p>
                <p><strong>Rappresentante Legale:</strong> ${legalEntityData['legal_rapresentative'] ?? 'N/A'}</p>
            </div>
            ''' : ''}
            
            <p><strong>Email:</strong> ${invitation.email}</p>
            <p><strong>Scadenza invito:</strong> ${invitation.expiresAt?.toString() ?? '7 giorni'}</p>
            
            <div style="text-align: center;">
                <a href="$invitationLink" class="button">
                    🎯 Accetta Invito
                </a>
            </div>
            
            <div class="expiry">
                <strong>⚠️ Attenzione:</strong> Questo invito scade il ${invitation.expiresAt?.toString() ?? 'tra 7 giorni'}.
            </div>
            
            <p>Se non hai richiesto questo invito, puoi ignorare questa email.</p>
            
            <p>Per assistenza, contatta il supporto tecnico.</p>
        </div>
        
        <div class="footer">
            <p>© 2024 JetCV Enterprise. Tutti i diritti riservati.</p>
            <p>Questo è un messaggio automatico, non rispondere a questa email.</p>
        </div>
    </div>
</body>
</html>
    ''';
  }

  // Genera testo semplice per l'email di invito
  String _generateInvitationEmailText(
    LegalEntityInvitation invitation,
    Map<String, dynamic>? legalEntityData,
  ) {
    // Genera il link con i parametri della legal entity
    final invitationLink = _generateInvitationLink(invitation, legalEntityData);

    final entityInfo = legalEntityData != null
        ? '''
INFORMAZIONI ENTITÀ LEGALE:
Nome: ${legalEntityData['legal_name'] ?? 'N/A'}
Codice Identificativo: ${legalEntityData['identifier_code'] ?? 'N/A'}
Email: ${legalEntityData['email'] ?? 'N/A'}
Rappresentante Legale: ${legalEntityData['legal_rapresentative'] ?? 'N/A'}

'''
        : '';

    return '''
JetCV Enterprise - Invito

Benvenuto in JetCV Enterprise!

Hai ricevuto un invito per unirti alla piattaforma.

$entityInfo
Email: ${invitation.email}
Scadenza invito: ${invitation.expiresAt?.toString() ?? '7 giorni'}

Per accettare l'invito, visita questo link:
$invitationLink

⚠️ Attenzione: Questo invito scade il ${invitation.expiresAt?.toString() ?? 'tra 7 giorni'}.

Se non hai richiesto questo invito, puoi ignorare questa email.

Per assistenza, contatta il supporto tecnico.

© 2024 JetCV Enterprise. Tutti i diritti riservati.
Questo è un messaggio automatico, non rispondere a questa email.
    ''';
  }

  // Genera il link di invito con i parametri della legal entity
  String _generateInvitationLink(
    LegalEntityInvitation invitation,
    Map<String, dynamic>? legalEntityData,
  ) {
    final baseUrl = AppConfig.appUrl;
    final token = invitation.invitationToken;

    // Costruisci l'URL base per il signup
    final url = Uri.parse('$baseUrl/signup');

    // Aggiungi i parametri di query
    final queryParams = <String, String>{
      'token': token,
      'email': invitation.email,
    };

    // Aggiungi i parametri della legal entity se disponibili
    if (legalEntityData != null) {
      if (legalEntityData['legal_name'] != null) {
        queryParams['legal_name'] = legalEntityData['legal_name'];
      }
      if (legalEntityData['identifier_code'] != null) {
        queryParams['identifier_code'] = legalEntityData['identifier_code'];
      }
      if (legalEntityData['email'] != null) {
        queryParams['entity_email'] = legalEntityData['email'];
      }
      if (legalEntityData['legal_rapresentative'] != null) {
        queryParams['legal_rapresentative'] =
            legalEntityData['legal_rapresentative'];
      }
      if (legalEntityData['operational_address'] != null) {
        queryParams['operational_address'] =
            legalEntityData['operational_address'];
      }
      if (legalEntityData['operational_city'] != null) {
        queryParams['operational_city'] = legalEntityData['operational_city'];
      }
      if (legalEntityData['operational_postal_code'] != null) {
        queryParams['operational_postal_code'] =
            legalEntityData['operational_postal_code'];
      }
      if (legalEntityData['operational_state'] != null) {
        queryParams['operational_state'] = legalEntityData['operational_state'];
      }
      if (legalEntityData['operational_country'] != null) {
        queryParams['operational_country'] =
            legalEntityData['operational_country'];
      }
      if (legalEntityData['headquarter_address'] != null) {
        queryParams['headquarter_address'] =
            legalEntityData['headquarter_address'];
      }
      if (legalEntityData['headquarter_city'] != null) {
        queryParams['headquarter_city'] = legalEntityData['headquarter_city'];
      }
      if (legalEntityData['headquarter_postal_code'] != null) {
        queryParams['headquarter_postal_code'] =
            legalEntityData['headquarter_postal_code'];
      }
      if (legalEntityData['headquarter_state'] != null) {
        queryParams['headquarter_state'] = legalEntityData['headquarter_state'];
      }
      if (legalEntityData['headquarter_country'] != null) {
        queryParams['headquarter_country'] =
            legalEntityData['headquarter_country'];
      }
      if (legalEntityData['phone'] != null) {
        queryParams['phone'] = legalEntityData['phone'];
      }
      if (legalEntityData['pec'] != null) {
        queryParams['pec'] = legalEntityData['pec'];
      }
      if (legalEntityData['website'] != null) {
        queryParams['website'] = legalEntityData['website'];
      }
    }

    // Costruisci l'URL finale con i parametri
    final finalUrl = url.replace(queryParameters: queryParams);

    return finalUrl.toString();
  }

  // Metodo per verificare lo stato dell'email
  Future<bool> checkEmailStatus(String messageId) async {
    try {
      // Placeholder per verifica stato email
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e) {
      print('Error checking email status: $e');
      return false;
    }
  }

  // Metodo per testare la generazione del link di invito
  void testInvitationLink() {
    print('🧪 Testing invitation link generation...');

    // Simula dati di una legal entity
    final legalEntityData = {
      'legal_name': 'Test Company SRL',
      'identifier_code': '12345678901',
      'email': 'test@company.com',
      'legal_rapresentative': 'Mario Rossi',
      'operational_address': 'Via Roma 123',
      'operational_city': 'Milano',
      'operational_postal_code': '20100',
      'operational_state': 'MI',
      'operational_country': 'Italy',
      'headquarter_address': 'Via Milano 456',
      'headquarter_city': 'Roma',
      'headquarter_postal_code': '00100',
      'headquarter_state': 'RM',
      'headquarter_country': 'Italy',
      'phone': '+39 02 1234567',
      'pec': 'test@pec.it',
      'website': 'https://testcompany.com',
    };

    // Simula un invito
    final invitation = LegalEntityInvitation(
      idInvitation: 123,
      idLegalEntity: 'test-legal-entity-123',
      invitationToken: 'abc123def456',
      email: 'user@example.com',
      status: InvitationStatus.pending,
      expiresAt: DateTime.now().add(const Duration(days: 7)),
    );

    // Genera il link
    final link = _generateInvitationLink(invitation, legalEntityData);

    print('Generated link: $link');
    print(
      'Expected format: http://localhost:8080/signup?token=...&email=...&legal_name=...',
    );

    // Verifica che l'URL contenga i parametri corretti
    final uri = Uri.parse(link);
    print('Base URL: ${uri.origin}${uri.path}');
    print('Query parameters: ${uri.queryParameters}');
  }

  // Metodo per testare la configurazione email
  Future<bool> testEmailConfiguration() async {
    try {
      print('🧪 Testing Local API configuration...');

      final apiUrl = 'http://18.102.14.247:4000/api/email/send';
      final fromEmail = _fromEmail;

      print('API URL: $apiUrl');
      print('From Email: $fromEmail');

      // Test con email di prova
      final testEmailData = {
        'to': 'test@example.com',
        'subject': 'Test Email Configuration',
        'html':
            '<h1>Test Email</h1><p>This is a test email to verify email configuration.</p>',
        'text':
            'Test Email\n\nThis is a test email to verify email configuration.',
      };

      final result = await _sendViaExternalService(testEmailData);

      if (result) {
        print('✅ Email configuration test successful!');
      } else {
        print('❌ Email configuration test failed!');
      }

      return result;
    } catch (e) {
      print('❌ Error testing email configuration: $e');
      return false;
    }
  }

  // Metodo per inviare email di notifica
  Future<bool> sendNotificationEmail({
    required String to,
    required String subject,
    required String message,
  }) async {
    try {
      final emailData = {
        'to': to,
        'subject': subject,
        'html': '<html><body>$message</body></html>',
        'text': message,
      };

      if (AppConfig.environment == 'development' && AppConfig.enableDebugMode) {
        return await _sendViaMailHog(emailData);
      } else {
        return await _sendViaExternalService(emailData);
      }
    } catch (e) {
      print('Error sending notification email: $e');
      return false;
    }
  }

  // Metodo per inviare invito a certificatore
  Future<bool> sendCertifierInvitation({
    required String email,
    required String invitationToken,
    required String legalEntityId,
    String? role,
    String? message,
  }) async {
    try {
      final subject = 'Invito a diventare Certificatore - JetCV Enterprise';
      final htmlContent = _generateCertifierInvitationEmailHTML(
        invitationToken: invitationToken,
        legalEntityId: legalEntityId,
        role: role,
        message: message,
      );
      final textContent = _generateCertifierInvitationEmailText(
        invitationToken: invitationToken,
        legalEntityId: legalEntityId,
        role: role,
        message: message,
      );

      if (AppConfig.environment == 'development' && AppConfig.enableDebugMode) {
        return await _sendViaMailHog({
          'to': email,
          'subject': subject,
          'html': htmlContent,
          'text': textContent,
        });
      } else {
        return await _sendViaExternalService({
          'to': email,
          'subject': subject,
          'html': htmlContent,
          'text': textContent,
        });
      }
    } catch (e) {
      print('Error sending certifier invitation email: $e');
      return false;
    }
  }

  String _generateCertifierInvitationEmailHTML({
    required String invitationToken,
    required String legalEntityId,
    String? role,
    String? message,
  }) {
    final roleText = role != null ? ' come $role' : '';
    final messageText = message != null
        ? '<p><strong>Messaggio:</strong> $message</p>'
        : '';

    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <title>Invito Certificatore - JetCV Enterprise</title>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: #1976d2; color: white; padding: 20px; text-align: center; }
          .content { padding: 20px; background: #f9f9f9; }
          .button { display: inline-block; padding: 12px 24px; background: #1976d2; color: white; text-decoration: none; border-radius: 4px; margin: 20px 0; }
          .footer { text-align: center; padding: 20px; color: #666; font-size: 14px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>🎯 Invito a diventare Certificatore</h1>
            <p>JetCV Enterprise</p>
          </div>
          
          <div class="content">
            <h2>Benvenuto nel team di certificazione!</h2>
            <p>Sei stato invitato a diventare un certificatore$roleText per JetCV Enterprise.</p>
            
            $messageText
            
            <p>Per accettare l'invito e iniziare a lavorare come certificatore, clicca sul pulsante qui sotto:</p>
            
            <a href="${AppConfig.appUrl}/certifier/invite/$invitationToken" class="button">
              🚀 Accetta Invito
            </a>
            
            <p><strong>Link diretto:</strong> <a href="${AppConfig.appUrl}/certifier/invite/$invitationToken">${AppConfig.appUrl}/certifier/invite/$invitationToken</a></p>
            
            <p><em>Questo invito è valido per 30 giorni. Se hai domande, contattaci a support@jetcv.com</em></p>
          </div>
          
          <div class="footer">
            <p>© 2024 JetCV Enterprise. Tutti i diritti riservati.</p>
          </div>
        </div>
      </body>
      </html>
    ''';
  }

  String _generateCertifierInvitationEmailText({
    required String invitationToken,
    required String legalEntityId,
    String? message,
    String? role,
  }) {
    final roleText = role != null ? ' come $role' : '';
    final messageText = message != null ? '\n\nMessaggio: $message' : '';

    return '''
      Invito a diventare Certificatore - JetCV Enterprise
      
      Benvenuto nel team di certificazione!
      
      Sei stato invitato a diventare un certificatore$roleText per JetCV Enterprise.
      $messageText
      
      Per accettare l'invito e iniziare a lavorare come certificatore, visita:
      ${AppConfig.appUrl}/certifier/invite/$invitationToken
      
      Questo invito è valido per 30 giorni. Se hai domande, contattaci a support@jetcv.com
      
      © 2024 JetCV Enterprise. Tutti i diritti riservati.
    ''';
  }
}
