import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/legal_entity.dart';
import '../../providers/legal_entity_provider.dart';
import '../../widgets/custom_button.dart';
import 'create_legal_entity_screen.dart';

class LegalEntityListScreen extends StatefulWidget {
  const LegalEntityListScreen({super.key});

  @override
  State<LegalEntityListScreen> createState() => _LegalEntityListScreenState();
}

class _LegalEntityListScreenState extends State<LegalEntityListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header with search and filters
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Legal Entities',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    CustomButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const CreateLegalEntityScreen(),
                          ),
                        );
                        if (result == true) {
                          // Refresh the legal entities list if creation was successful
                          if (mounted) {
                            final provider = context
                                .read<LegalEntityProvider>();
                            await provider.refreshLegalEntities();
                          }
                        }
                      },
                      text: 'Add New Entity',
                      icon: Icons.add,
                      variant: ButtonVariant.filled,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Search and Filter Row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search legal entities...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      value: _statusFilter,
                      hint: const Text('Filter by Status'),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All Statuses'),
                        ),
                        const DropdownMenuItem(
                          value: 'pending',
                          child: Text('Pending'),
                        ),
                        const DropdownMenuItem(
                          value: 'approved',
                          child: Text('Approved'),
                        ),
                        const DropdownMenuItem(
                          value: 'rejected',
                          child: Text('Rejected'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _statusFilter = value;
                        });
                        context.read<LegalEntityProvider>().setFilterStatus(
                          value,
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    CustomButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const CreateLegalEntityScreen(),
                          ),
                        );
                        if (result == true) {
                          // Refresh the legal entities list if creation was successful
                          if (mounted) {
                            final provider = context
                                .read<LegalEntityProvider>();
                            await provider.refreshLegalEntities();
                          }
                        }
                      },
                      text: 'Add New Entity',
                      icon: Icons.add,
                      variant: ButtonVariant.filled,
                    ),
                    const SizedBox(width: 16),
                    CustomButton(
                      onPressed: () {
                        // Show invitation dialog
                      },
                      text: 'Send Invitation',
                      icon: Icons.email,
                      variant: ButtonVariant.outlined,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Legal Entities List
          Expanded(
            child: Consumer<LegalEntityProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final entities = provider.searchLegalEntities(_searchQuery);

                if (entities.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.business, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No legal entities found matching "$_searchQuery"'
                              : 'No legal entities found',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        if (_searchQuery.isEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Get started by adding your first legal entity',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.refreshLegalEntities(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: entities.length,
                    itemBuilder: (context, index) {
                      final entity = entities[index];
                      return _buildLegalEntityCard(context, entity, provider);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalEntityCard(
    BuildContext context,
    LegalEntity entity,
    LegalEntityProvider provider,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                        entity.legalName ?? 'Nome non specificato',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entity.identifierCode ?? 'Codice non specificato',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(entity.status),
              ],
            ),

            const SizedBox(height: 16),

            // Company details
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.email,
                    label: 'Email',
                    value: entity.email ?? '',
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.phone,
                    label: 'Phone',
                    value: entity.phone ?? '',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.person,
                    label: 'Representative',
                    value: entity.legalRapresentative ?? '',
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.location_on,
                    label: 'Address',
                    value: entity.displayAddress,
                  ),
                ),
              ],
            ),

            if (entity.website != null) ...[
              const SizedBox(height: 12),
              _buildDetailItem(
                icon: Icons.language,
                label: 'Website',
                value: entity.website!,
              ),
            ],

            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    onPressed: () => _viewEntityDetails(context, entity),
                    text: 'View Details',
                    icon: Icons.visibility,
                    variant: ButtonVariant.outlined,
                  ),
                ),
                const SizedBox(width: 12),
                if (entity.isPending) ...[
                  Expanded(
                    child: CustomButton(
                      onPressed: () =>
                          _approveEntity(context, entity, provider),
                      text: 'Approve',
                      backgroundColor: Colors.green,
                      variant: ButtonVariant.filled,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      onPressed: () => _rejectEntity(context, entity, provider),
                      text: 'Reject',
                      backgroundColor: Colors.red,
                      variant: ButtonVariant.filled,
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: CustomButton(
                      onPressed: () =>
                          _sendInvitation(context, entity, provider),
                      text: 'Send Invitation',
                      variant: ButtonVariant.filled,
                    ),
                  ),
                ],
              ],
            ),

            // Timestamps
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Created: ${_formatDate(entity.createdAt)}',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ),
                Text(
                  'Status: ${entity.statusDisplayName}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(LegalEntityStatus status) {
    Color chipColor;
    String statusText;

    switch (status) {
      case LegalEntityStatus.pending:
        chipColor = Colors.orange;
        statusText = 'Pending';
        break;
      case LegalEntityStatus.approved:
        chipColor = Colors.green;
        statusText = 'Approved';
        break;
      case LegalEntityStatus.rejected:
        chipColor = Colors.red;
        statusText = 'Rejected';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _viewEntityDetails(BuildContext context, LegalEntity entity) {
    // Navigate to entity details screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(entity.legalName ?? 'Nome non specificato'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(
                'Legal Name',
                entity.legalName ?? 'Non specificato',
              ),
              _buildDetailRow(
                'Identifier Code',
                entity.identifierCode ?? 'Non specificato',
              ),
              _buildDetailRow('Email', entity.email ?? 'Non specificato'),
              _buildDetailRow('Phone', entity.phone ?? 'Non specificato'),
              _buildDetailRow(
                'Legal Representative',
                entity.legalRapresentative ?? 'Non specificato',
              ),
              _buildDetailRow(
                'Operational Address',
                entity.operationalAddress ?? 'Non specificato',
              ),
              _buildDetailRow(
                'Headquarters Address',
                entity.headquarterAddress ?? 'Non specificato',
              ),
              if (entity.pec != null) _buildDetailRow('PEC', entity.pec!),
              if (entity.website != null)
                _buildDetailRow('Website', entity.website!),
              _buildDetailRow('Status', entity.statusDisplayName),
              _buildDetailRow('Created', _formatDate(entity.createdAt)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _approveEntity(
    BuildContext context,
    LegalEntity entity,
    LegalEntityProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Legal Entity'),
        content: Text(
          'Are you sure you want to approve "${entity.legalName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Salva il ScaffoldMessenger prima dell'operazione asincrona
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      final success = await provider.approveLegalEntity(entity.idLegalEntity);

      if (success && mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('${entity.legalName} has been approved'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _rejectEntity(
    BuildContext context,
    LegalEntity entity,
    LegalEntityProvider provider,
  ) async {
    final rejectionReason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Legal Entity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to reject "${entity.legalName}"?'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Rejection Reason',
                hintText: 'Enter reason for rejection',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, 'Rejection reason'); // Placeholder
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (rejectionReason != null && rejectionReason.isNotEmpty) {
      final success = await provider.rejectLegalEntity(
        entity.idLegalEntity,
        rejectionReason,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${entity.legalName} has been rejected'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendInvitation(
    BuildContext context,
    LegalEntity entity,
    LegalEntityProvider provider,
  ) async {
    final email = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Invitation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Send invitation to register for "${entity.legalName}"'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Email Address',
                hintText: 'Enter email to send invitation',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, 'invitation@example.com'); // Placeholder
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );

    if (email != null && email.isNotEmpty) {
      final success = await provider.sendInvitation(
        email: email,
        legalEntityId: entity.idLegalEntity,
        inviterId: 'admin_user_id', // Replace with actual admin user ID
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invitation sent to $email'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
