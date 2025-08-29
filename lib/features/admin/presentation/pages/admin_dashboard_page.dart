import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/providers/legal_entity_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/models/legal_entity_model.dart';
import '../widgets/legal_entity_card.dart';
import '../widgets/create_legal_entity_dialog.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final legalEntitiesAsync = ref.watch(legalEntityProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Amministratore'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(legalEntityProvider.notifier).loadLegalEntities(),
          ),
        ],
      ),
      body: legalEntitiesAsync.when(
        data: (legalEntities) => _buildDashboard(context, ref, legalEntities),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Errore nel caricamento',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(legalEntityProvider.notifier).loadLegalEntities(),
                child: const Text('Riprova'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateLegalEntityDialog(context, ref),
        icon: const Icon(Icons.add_business),
        label: const Text('Nuovo Ente'),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, WidgetRef ref, List<LegalEntity> legalEntities) {
    final pendingEntities = legalEntities.where((e) => e.isPending).toList();
    final approvedEntities = legalEntities.where((e) => e.isApproved).toList();
    final rejectedEntities = legalEntities.where((e) => e.isRejected).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistics Cards
          _buildStatisticsCards(context, pendingEntities, approvedEntities, rejectedEntities),
          const SizedBox(height: 32),

          // Pending Legal Entities
          if (pendingEntities.isNotEmpty) ...[
            _buildSectionHeader('Enti in Attesa', pendingEntities.length, Colors.orange),
            const SizedBox(height: 16),
            ...pendingEntities.map((entity) => LegalEntityCard(
              legalEntity: entity,
              onApprove: () => _handleApproveEntity(ref, entity),
              onReject: () => _handleRejectEntity(context, ref, entity),
            )),
            const SizedBox(height: 32),
          ],

          // Approved Legal Entities
          if (approvedEntities.isNotEmpty) ...[
            _buildSectionHeader('Enti Approvati', approvedEntities.length, Colors.green),
            const SizedBox(height: 16),
            ...approvedEntities.map((entity) => LegalEntityCard(
              legalEntity: entity,
              showActions: false,
            )),
            const SizedBox(height: 32),
          ],

          // Rejected Legal Entities
          if (rejectedEntities.isNotEmpty) ...[
            _buildSectionHeader('Enti Rifiutati', rejectedEntities.length, Colors.red),
            const SizedBox(height: 16),
            ...rejectedEntities.map((entity) => LegalEntityCard(
              legalEntity: entity,
              showActions: false,
            )),
          ],

          // Empty State
          if (legalEntities.isEmpty) ...[
            const SizedBox(height: 64),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.business_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nessun ente legale trovato',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crea il primo ente legale utilizzando il pulsante +',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(BuildContext context, List<LegalEntity> pending, List<LegalEntity> approved, List<LegalEntity> rejected) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'In Attesa',
            pending.length.toString(),
            Icons.pending_actions,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Approvati',
            approved.length.toString(),
            Icons.check_circle_outline,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Rifiutati',
            rejected.length.toString(),
            Icons.cancel_outlined,
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  void _showCreateLegalEntityDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const CreateLegalEntityDialog(),
    );
  }

  Future<void> _handleApproveEntity(WidgetRef ref, LegalEntity entity) async {
    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) return;

      await ref.read(legalEntityProvider.notifier).approveLegalEntity(
        entity.idLegalEntity,
        currentUser.idUser,
      );

      if (ref.mounted) {
        ScaffoldMessenger.of(ref.context).showSnackBar(
          SnackBar(
            content: Text('${entity.legalName} è stato approvato'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (ref.mounted) {
        ScaffoldMessenger.of(ref.context).showSnackBar(
          SnackBar(
            content: Text('Errore durante l\'approvazione: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleRejectEntity(BuildContext context, WidgetRef ref, LegalEntity entity) async {
    final rejectionReason = await _showRejectionDialog(context);
    if (rejectionReason == null || rejectionReason.trim().isEmpty) return;

    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) return;

      await ref.read(legalEntityProvider.notifier).rejectLegalEntity(
        entity.idLegalEntity,
        rejectionReason.trim(),
        currentUser.idUser,
      );

      if (ref.mounted) {
        ScaffoldMessenger.of(ref.context).showSnackBar(
          SnackBar(
            content: Text('${entity.legalName} è stato rifiutato'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (ref.mounted) {
        ScaffoldMessenger.of(ref.context).showSnackBar(
          SnackBar(
            content: Text('Errore durante il rifiuto: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _showRejectionDialog(BuildContext context) async {
    final controller = TextEditingController();
    
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Motivo del Rifiuto'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Inserisci il motivo del rifiuto',
            hintText: 'Es. Documentazione incompleta',
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Conferma'),
          ),
        ],
      ),
    );
  }
}
