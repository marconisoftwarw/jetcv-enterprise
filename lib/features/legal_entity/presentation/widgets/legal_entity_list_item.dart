import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../shared/models/legal_entity_model.dart';

class LegalEntityListItem extends StatelessWidget {
  final LegalEntity legalEntity;

  const LegalEntityListItem({
    super.key,
    required this.legalEntity,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor().withOpacity(0.1),
          child: Icon(
            Icons.business,
            color: _getStatusColor(),
          ),
        ),
        title: Text(
          legalEntity.legalName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              legalEntity.identifierCode,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    legalEntity.city ?? legalEntity.operationalAddress,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: _buildStatusChip(),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Contact Information
                _buildInfoSection(
                  'Informazioni di Contatto',
                  [
                    _buildInfoRow(Icons.email_outlined, 'Email', legalEntity.email),
                    _buildInfoRow(Icons.phone_outlined, 'Telefono', legalEntity.phone),
                    if (legalEntity.pec != null)
                      _buildInfoRow(Icons.mail_outlined, 'PEC', legalEntity.pec!),
                    if (legalEntity.website != null)
                      _buildInfoRow(Icons.language_outlined, 'Website', legalEntity.website!),
                  ],
                ),
                const SizedBox(height: 16),

                // Address Information
                _buildInfoSection(
                  'Indirizzi',
                  [
                    _buildInfoRow(Icons.location_on_outlined, 'Indirizzo Operativo', legalEntity.operationalAddress),
                    _buildInfoRow(Icons.business_outlined, 'Sede Legale', legalEntity.headquartersAddress),
                  ],
                ),
                const SizedBox(height: 16),

                // Additional Details
                _buildInfoSection(
                  'Dettagli Aggiuntivi',
                  [
                    _buildInfoRow(Icons.person_outlined, 'Rappresentante Legale', legalEntity.legalRepresentative),
                    if (legalEntity.address != null)
                      _buildInfoRow(Icons.home_outlined, 'Indirizzo', legalEntity.address!),
                    if (legalEntity.city != null)
                      _buildInfoRow(Icons.location_city_outlined, 'Città', legalEntity.city!),
                    if (legalEntity.state != null)
                      _buildInfoRow(Icons.map_outlined, 'Provincia', legalEntity.state!),
                    if (legalEntity.postalcode != null)
                      _buildInfoRow(Icons.pin_drop_outlined, 'CAP', legalEntity.postalcode!),
                    if (legalEntity.countrycode != null)
                      _buildInfoRow(Icons.flag_outlined, 'Paese', legalEntity.countrycode!),
                  ],
                ),
                const SizedBox(height: 16),

                // Timestamps
                _buildInfoSection(
                  'Informazioni Temporali',
                  [
                    _buildInfoRow(
                      Icons.schedule_outlined,
                      'Creato il',
                      DateFormat('dd/MM/yyyy HH:mm').format(legalEntity.createdAt),
                    ),
                    if (legalEntity.statusUpdatedAt != null)
                      _buildInfoRow(
                        Icons.update_outlined,
                        'Aggiornato il',
                        DateFormat('dd/MM/yyyy HH:mm').format(legalEntity.statusUpdatedAt!),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor().withOpacity(0.3)),
      ),
      child: Text(
        legalEntity.statusDisplayName,
        style: TextStyle(
          color: _getStatusColor(),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (legalEntity.status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
