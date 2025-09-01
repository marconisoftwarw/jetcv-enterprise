import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';

class LegalEntityInvitationDetailsScreen extends StatelessWidget {
  final Map<String, String> queryParameters;

  const LegalEntityInvitationDetailsScreen({
    super.key,
    required this.queryParameters,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettagli Invito'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  const Icon(Icons.business, size: 48, color: Colors.blue),
                  const SizedBox(height: 16),
                  const Text(
                    'Invito Accettato!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Benvenuto in ${queryParameters['legal_name'] ?? 'JetCV Enterprise'}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Informazioni principali
            _buildSection(
              title: 'Informazioni Principali',
              icon: Icons.info,
              children: [
                _buildInfoRow(
                  'Nome Entità Legale',
                  queryParameters['legal_name'],
                ),
                _buildInfoRow(
                  'Codice Identificativo',
                  queryParameters['identifier_code'],
                ),
                _buildInfoRow(
                  'Email Aziendale',
                  queryParameters['entity_email'],
                ),
                _buildInfoRow(
                  'Rappresentante Legale',
                  queryParameters['legal_rapresentative'],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Indirizzo operativo
            _buildSection(
              title: 'Indirizzo Operativo',
              icon: Icons.location_on,
              children: [
                _buildInfoRow(
                  'Indirizzo',
                  queryParameters['operational_address'],
                ),
                _buildInfoRow('Città', queryParameters['operational_city']),
                _buildInfoRow(
                  'CAP',
                  queryParameters['operational_postal_code'],
                ),
                _buildInfoRow(
                  'Provincia',
                  queryParameters['operational_state'],
                ),
                _buildInfoRow('Paese', queryParameters['operational_country']),
              ],
            ),
            const SizedBox(height: 24),

            // Sede legale
            _buildSection(
              title: 'Sede Legale',
              icon: Icons.home_work,
              children: [
                _buildInfoRow(
                  'Indirizzo',
                  queryParameters['headquarter_address'],
                ),
                _buildInfoRow('Città', queryParameters['headquarter_city']),
                _buildInfoRow(
                  'CAP',
                  queryParameters['headquarter_postal_code'],
                ),
                _buildInfoRow(
                  'Provincia',
                  queryParameters['headquarter_state'],
                ),
                _buildInfoRow('Paese', queryParameters['headquarter_country']),
              ],
            ),
            const SizedBox(height: 24),

            // Informazioni di contatto
            _buildSection(
              title: 'Informazioni di Contatto',
              icon: Icons.contact_phone,
              children: [
                _buildInfoRow('Telefono', queryParameters['phone']),
                _buildInfoRow('PEC', queryParameters['pec']),
                _buildInfoRow('Sito Web', queryParameters['website']),
              ],
            ),
            const SizedBox(height: 32),

            // Azioni
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    text: 'Vai alla Dashboard',
                    backgroundColor: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        '/legal-entity/register',
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Modifica Dati'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/cv-list');
                },
                icon: const Icon(Icons.description),
                label: const Text('Esplora CV'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'Non specificato',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
