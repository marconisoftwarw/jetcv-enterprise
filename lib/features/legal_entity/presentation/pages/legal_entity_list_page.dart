import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/legal_entity_provider.dart';
import '../../../../shared/models/legal_entity_model.dart';
import '../widgets/legal_entity_list_item.dart';

class LegalEntityListPage extends ConsumerWidget {
  const LegalEntityListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final legalEntitiesAsync = ref.watch(legalEntityProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enti Legali'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(legalEntityProvider.notifier).loadLegalEntities(),
          ),
        ],
      ),
      body: legalEntitiesAsync.when(
        data: (legalEntities) => _buildLegalEntityList(context, legalEntities),
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
    );
  }

  Widget _buildLegalEntityList(BuildContext context, List<LegalEntity> legalEntities) {
    if (legalEntities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              'Gli enti legali appariranno qui una volta creati',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Group entities by status
    final pendingEntities = legalEntities.where((e) => e.isPending).toList();
    final approvedEntities = legalEntities.where((e) => e.isApproved).toList();
    final rejectedEntities = legalEntities.where((e) => e.isRejected).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pending Entities
          if (pendingEntities.isNotEmpty) ...[
            _buildSectionHeader('In Attesa di Approvazione', pendingEntities.length, Colors.orange),
            const SizedBox(height: 16),
            ...pendingEntities.map((entity) => LegalEntityListItem(legalEntity: entity)),
            const SizedBox(height: 32),
          ],

          // Approved Entities
          if (approvedEntities.isNotEmpty) ...[
            _buildSectionHeader('Approvati', approvedEntities.length, Colors.green),
            const SizedBox(height: 16),
            ...approvedEntities.map((entity) => LegalEntityListItem(legalEntity: entity)),
            const SizedBox(height: 32),
          ],

          // Rejected Entities
          if (rejectedEntities.isNotEmpty) ...[
            _buildSectionHeader('Rifiutati', rejectedEntities.length, Colors.red),
            const SizedBox(height: 16),
            ...rejectedEntities.map((entity) => LegalEntityListItem(legalEntity: entity)),
          ],
        ],
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
}
