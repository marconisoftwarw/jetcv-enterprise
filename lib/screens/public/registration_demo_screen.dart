import 'package:flutter/material.dart';
import 'legal_entity_public_registration_screen.dart';
import 'legal_entity_link_registration_screen.dart';
import '../../services/url_parameter_service.dart';

class RegistrationDemoScreen extends StatelessWidget {
  const RegistrationDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo Registrazione'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Scegli il tipo di registrazione:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),

            // Public registration button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LegalEntityPublicRegistrationScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(20),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Column(
                children: [
                  Icon(Icons.public, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'Registrazione Pubblica',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Registrazione completa con selezione piano',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Link registration button
            ElevatedButton(
              onPressed: () {
                // Example of link-based registration with prefill data
                final prefillData = {
                  'personalName': 'Mario Rossi',
                  'personalEmail': 'mario.rossi@example.com',
                  'personalPhone': '+39 123 456 7890',
                  'legalName': 'Rossi S.r.l.',
                  'identifierCode': 'IT12345678901',
                  'entityEmail': 'info@rossi.it',
                  'legalRepresentative': 'Mario Rossi',
                  'operationalAddress': 'Via Roma 123',
                  'operationalCity': 'Milano',
                  'operationalPostalCode': '20100',
                  'operationalState': 'MI',
                  'operationalCountry': 'Italia',
                  'headquarterAddress': 'Via Roma 123',
                  'headquarterCity': 'Milano',
                  'headquarterPostalCode': '20100',
                  'headquarterState': 'MI',
                  'headquarterCountry': 'Italia',
                  'phone': '+39 02 1234567',
                  'pec': 'pec@rossi.it',
                  'website': 'https://www.rossi.it',
                };

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LegalEntityLinkRegistrationScreen(
                      invitationToken: 'inv_123456789',
                      prefillData: prefillData,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(20),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Column(
                children: [
                  Icon(Icons.link, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'Registrazione tramite Link',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Registrazione con dati precompilati',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // URL generation example
            const Text(
              'Esempio di generazione link:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Link generato:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    _generateExampleLink(),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _generateExampleLink() {
    final prefillData = {
      'personalName': 'Mario Rossi',
      'personalEmail': 'mario.rossi@example.com',
      'legalName': 'Rossi S.r.l.',
      'identifierCode': 'IT12345678901',
    };

    return UrlParameterService.generateRegistrationLink(
      invitationToken: 'inv_123456789',
      prefillData: prefillData,
      baseUrl: 'https://app.jetcv.com/register',
    );
  }
}
