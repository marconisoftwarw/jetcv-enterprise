import 'lib/services/email_service.dart';
import 'lib/models/legal_entity_invitation.dart';

void main() {
  final emailService = EmailService();
  emailService.testInvitationLink();
}
