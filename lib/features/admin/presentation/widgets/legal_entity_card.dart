import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../shared/models/legal_entity_model.dart';

class LegalEntityCard extends StatelessWidget {
  final LegalEntity legalEntity;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final bool showActions;

  const LegalEntityCard({
    super.key,
    required this.legalEntity,
    this.onApprove,
    this.onReject,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        legalEntity.legalName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        legalEntity.identifierCode,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(),
              ],
            ),
            const SizedBox(height: 16),

            // Contact Information
            _buildInfoRow(Icons.email_outlined, 'Email', legalEntity.email),
            _buildInfoRow(Icons.phone_outlined, 'Telefono', legalEntity.phone),
            if (legalEntity.website != null)
              _buildInfoRow(Icons.language_outlined, 'Website', legalEntity.website!),
            if (legalEntity.pec != null)
              _buildInfoRow(Icons.mail_outlined, 'PEC', legalEntity.pec!),

            const SizedBox(height: 16),

            // Address Information
            _buildInfoRow(Icons.location_on_outlined, 'Indirizzo Operativo', legalEntity.operationalAddress),
            _buildInfoRow(Icons.business_outlined, 'Sede Legale', legalEntity.headquartersAddress),
            _buildInfoRow(Icons.person_outlined, 'Rappresentante Legale', legalEntity.legalRepresentative),

            const SizedBox(height: 16),

            // Additional Address Fields
            if (legalEntity.address != null || legalEntity.city != null || legalEntity.state != null) ...[
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
              const SizedBox(height: 16),
            ],

            // Timestamps
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    Icons.schedule_outlined,
                    'Creato il',
                    DateFormat('dd/MM/yyyy HH:mm').format(legalEntity.createdAt),
                  ),
                ),
                if (legalEntity.statusUpdatedAt != null)
                  Expanded(
                    child: _buildInfoRow(
                      Icons.update_outlined,
                      'Aggiornato il',
                      DateFormat('dd/MM/yyyy HH:mm').format(legalEntity.statusUpdatedAt!),
                    ),
                  ),
              ],
            ),

            // Action Buttons
            if (showActions && (onApprove != null || onReject != null)) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  if (onApprove != null) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onApprove,
                        icon: const Icon(Icons.check),
                        label: const Text('Approva'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    if (onReject != null) const SizedBox(width: 16),
                  ],
                  if (onReject != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onReject,
                        icon: const Icon(Icons.close),
                        label: const Text('Rifiuta'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color chipColor;
    IconData chipIcon;
    
    switch (legalEntity.status) {
      case 'pending':
        chipColor = Colors.orange;
        chipIcon = Icons.pending;
        break;
      case 'approved':
        chipColor = Colors.green;
        chipIcon = Icons.check_circle;
        break;
      case 'rejected':
        chipColor = Colors.red;
        chipIcon = Icons.cancel;
        break;
      default:
        chipColor = Colors.grey;
        chipIcon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(chipIcon, size: 16, color: chipColor),
          const SizedBox(width: 4),
          Text(
            legalEntity.statusDisplayName,
            style: TextStyle(
              color: chipColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
