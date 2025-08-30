import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/legal_entity_invitation.dart';
import '../config/app_config.dart';

class EmailService {
  static final EmailService _instance = EmailService._internal();
  factory EmailService() => _instance;
  EmailService._internal();

  // Configurazione SMTP interna (placeholder per implementazione reale)
  static const String _smtpHost = 'localhost';
  static const int _smtpPort = 1025; // MailHog per sviluppo
  static const String _smtpUsername = 'test@example.com';
  static const String _smtpPassword = 'password';

  // Metodo per inviare invito via email
  Future<bool> sendLegalEntityInvitation(
    LegalEntityInvitation invitation,
  ) async {
    try {
      // Per ora usiamo un servizio esterno come MailHog o simili
      // In produzione si può integrare con SendGrid, AWS SES, etc.

      final emailData = {
        'to': invitation.email,
        'subject': 'Invito a unirsi a JetCV Enterprise',
        'html': _generateInvitationEmailHTML(invitation),
        'text': _generateInvitationEmailText(invitation),
      };

      // Opzione 1: MailHog per sviluppo locale
      if (AppConfig.enableDebugMode) {
        return await _sendViaMailHog(emailData);
      }

      // Opzione 2: Servizio email esterno (SendGrid, etc.)
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
          'from': 'noreply@jetcv.com',
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

  // Metodo per inviare via servizio esterno
  Future<bool> _sendViaExternalService(Map<String, dynamic> emailData) async {
    try {
      // Placeholder per integrazione con servizi reali
      // Esempio con SendGrid:
      /*
      final response = await http.post(
        Uri.parse('https://api.sendgrid.com/v3/mail/send'),
        headers: {
          'Authorization': 'Bearer ${AppConfig.sendgridApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'personalizations': [
            {
              'to': [{'email': emailData['to']}],
            }
          ],
          'from': {'email': 'noreply@jetcv.com'},
          'subject': emailData['subject'],
          'content': [
            {
              'type': 'text/html',
              'value': emailData['html'],
            }
          ],
        }),
      );
      */

      // Per ora simuliamo l'invio
      await Future.delayed(const Duration(seconds: 1));
      print('Email sent to ${emailData['to']}: ${emailData['subject']}');

      return true;
    } catch (e) {
      print('Error sending via external service: $e');
      return false;
    }
  }

  // Genera HTML per l'email di invito
  String _generateInvitationEmailHTML(LegalEntityInvitation invitation) {
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
            
            <p><strong>Email:</strong> ${invitation.email}</p>
            <p><strong>Scadenza invito:</strong> ${invitation.expiresAt?.toString() ?? '7 giorni'}</p>
            
            <div style="text-align: center;">
                <a href="${invitation.invitationLink}" class="button">
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
  String _generateInvitationEmailText(LegalEntityInvitation invitation) {
    return '''
JetCV Enterprise - Invito

Benvenuto in JetCV Enterprise!

Hai ricevuto un invito per unirti alla piattaforma.

Email: ${invitation.email}
Scadenza invito: ${invitation.expiresAt?.toString() ?? '7 giorni'}

Per accettare l'invito, visita questo link:
${invitation.invitationLink}

⚠️ Attenzione: Questo invito scade il ${invitation.expiresAt?.toString() ?? 'tra 7 giorni'}.

Se non hai richiesto questo invito, puoi ignorare questa email.

Per assistenza, contatta il supporto tecnico.

© 2024 JetCV Enterprise. Tutti i diritti riservati.
Questo è un messaggio automatico, non rispondere a questa email.
    ''';
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

      if (AppConfig.enableDebugMode) {
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

      if (AppConfig.environment == 'development') {
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
