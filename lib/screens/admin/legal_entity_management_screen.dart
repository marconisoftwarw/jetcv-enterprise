import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/legal_entity.dart';
import '../../providers/legal_entity_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class LegalEntityManagementScreen extends StatefulWidget {
  const LegalEntityManagementScreen({super.key});

  @override
  State<LegalEntityManagementScreen> createState() =>
      _LegalEntityManagementScreenState();
}

class _LegalEntityManagementScreenState
    extends State<LegalEntityManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;
  List<LegalEntity> _filteredEntities = [];

  @override
  void initState() {
    super.initState();
    _loadLegalEntities();
    _searchController.addListener(_filterEntities);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLegalEntities() async {
    print('🔄 LegalEntityManagementScreen: Starting to load legal entities...');
    final provider = context.read<LegalEntityProvider>();
    await provider.loadLegalEntities();
    print('🔄 LegalEntityManagementScreen: Provider loading completed');
    _filterEntities();
    print('🔄 LegalEntityManagementScreen: Entities filtered');
  }

  void _filterEntities() {
    final provider = context.read<LegalEntityProvider>();
    final query = _searchController.text.trim();

    print('🔍 LegalEntityManagementScreen: Filtering entities...');
    print('🔍 Search query: "$query"');
    print('🔍 Selected status: $_selectedStatus');
    print('🔍 Total entities in provider: ${provider.legalEntities.length}');
    print(
      '🔍 Entity names in provider: ${provider.legalEntities.map((e) => e.legalName).join(', ')}',
    );

    setState(() {
      if (query.isEmpty && _selectedStatus == null) {
        _filteredEntities = provider.legalEntities;
        print(
          '🔍 No filters applied, showing all ${_filteredEntities.length} entities',
        );
      } else {
        _filteredEntities = provider.searchLegalEntities(query);
        print('🔍 After search filter: ${_filteredEntities.length} entities');

        if (_selectedStatus != null) {
          _filteredEntities = _filteredEntities
              .where(
                (entity) =>
                    entity.status.toString().split('.').last == _selectedStatus,
              )
              .toList();
          print('🔍 After status filter: ${_filteredEntities.length} entities');
        }
      }

      print('🔍 Final filtered entities: ${_filteredEntities.length}');
      print(
        '🔍 Final entity names: ${_filteredEntities.map((e) => e.legalName).join(', ')}',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestione Entità Legali'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Consumer<LegalEntityProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.legalEntities.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Header con statistiche e filtri
              _buildHeader(provider),

              // Lista delle entità
              Expanded(child: _buildEntityList(provider)),
            ],
          );
        },
      ),

      // Floating Action Button per creare nuova entità
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateEntityDialog(context),
        backgroundColor: const Color(0xFF2563EB),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(LegalEntityProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistiche
          Row(
            children: [
              _buildStatCard('Totale', provider.totalCount, Colors.blue),
              const SizedBox(width: 12),
              _buildStatCard('In Attesa', provider.pendingCount, Colors.orange),
              const SizedBox(width: 12),
              _buildStatCard('Approvate', provider.approvedCount, Colors.green),
              const SizedBox(width: 12),
              _buildStatCard('Rifiutate', provider.rejectedCount, Colors.red),
            ],
          ),

          const SizedBox(height: 20),

          // Filtri e ricerca
          Row(
            children: [
              // Campo ricerca
              Expanded(
                child: CustomTextField(
                  controller: _searchController,
                  hintText: 'Cerca per nome, email o codice...',
                  prefixIcon: const Icon(Icons.search),
                ),
              ),

              const SizedBox(width: 12),

              // Filtro stato
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String?>(
                  value: _selectedStatus,
                  hint: const Text('Tutti gli Stati'),
                  underline: const SizedBox(),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Tutti gli Stati'),
                    ),
                    const DropdownMenuItem(
                      value: 'pending',
                      child: Text('In Attesa'),
                    ),
                    const DropdownMenuItem(
                      value: 'approved',
                      child: Text('Approvate'),
                    ),
                    const DropdownMenuItem(
                      value: 'rejected',
                      child: Text('Rifiutate'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                    _filterEntities();
                  },
                ),
              ),

              const SizedBox(width: 12),

              // Pulsante refresh
              IconButton(
                onPressed: _loadLegalEntities,
                icon: const Icon(Icons.refresh),
                tooltip: 'Aggiorna',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntityList(LegalEntityProvider provider) {
    if (_filteredEntities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Nessuna entità legale trovata',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty || _selectedStatus != null
                  ? 'Prova a modificare i filtri di ricerca'
                  : 'Crea la tua prima entità legale',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredEntities.length,
      itemBuilder: (context, index) {
        final entity = _filteredEntities[index];
        return _buildEntityCard(entity, provider);
      },
    );
  }

  Widget _buildEntityCard(LegalEntity entity, LegalEntityProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con nome e stato
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entity.legalName ?? 'Nome non specificato',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entity.identifierCode ?? 'Codice non specificato',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                // Stato
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(entity.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getStatusColor(entity.status).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    entity.statusDisplayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _getStatusColor(entity.status),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Informazioni di contatto
            if (entity.email != null || entity.phone != null)
              Row(
                children: [
                  if (entity.email != null) ...[
                    const Icon(Icons.email, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(entity.email!, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 16),
                  ],
                  if (entity.phone != null) ...[
                    const Icon(Icons.phone, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(entity.phone!, style: const TextStyle(fontSize: 14)),
                  ],
                ],
              ),

            const SizedBox(height: 8),

            // Rappresentante legale
            if (entity.legalRapresentative != null)
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Rappresentante: ${entity.legalRapresentative}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),

            const SizedBox(height: 12),

            // Azioni
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showEntityDetails(entity),
                  icon: const Icon(Icons.visibility),
                  label: const Text('Dettagli'),
                ),

                if (entity.isPending) ...[
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _showEditEntityDialog(entity),
                    icon: const Icon(Icons.edit),
                    label: const Text('Modifica'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _approveEntity(entity),
                    icon: const Icon(Icons.check),
                    label: const Text('Approva'),
                    style: TextButton.styleFrom(foregroundColor: Colors.green),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _showRejectDialog(entity),
                    icon: const Icon(Icons.close),
                    label: const Text('Rifiuta'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ] else ...[
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _showEditEntityDialog(entity),
                    icon: const Icon(Icons.edit),
                    label: const Text('Modifica'),
                  ),
                ],

                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _showDeleteDialog(entity),
                  icon: const Icon(Icons.delete),
                  label: const Text('Elimina'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(LegalEntityStatus status) {
    switch (status) {
      case LegalEntityStatus.pending:
        return Colors.orange;
      case LegalEntityStatus.approved:
        return Colors.green;
      case LegalEntityStatus.rejected:
        return Colors.red;
    }
  }

  void _showEntityDetails(LegalEntity entity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(entity.legalName ?? 'Dettagli Entità'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Nome Legale', entity.legalName),
              _buildDetailRow('Codice Identificativo', entity.identifierCode),
              _buildDetailRow('Email', entity.email),
              _buildDetailRow('Telefono', entity.phone),
              _buildDetailRow('PEC', entity.pec),
              _buildDetailRow('Sito Web', entity.website),
              _buildDetailRow(
                'Rappresentante Legale',
                entity.legalRapresentative,
              ),
              const SizedBox(height: 16),
              const Text(
                'Indirizzo Operativo:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(entity.displayAddress),
              const SizedBox(height: 8),
              const Text(
                'Sede Legale:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(entity.displayHeadquarters),
              const SizedBox(height: 16),
              _buildDetailRow('Stato', entity.statusDisplayName),
              _buildDetailRow(
                'Data Creazione',
                entity.createdAt.toString().split(' ')[0],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Chiudi'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value ?? 'Non specificato')),
        ],
      ),
    );
  }

  void _showCreateEntityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const LegalEntityFormDialog(),
    ).then((_) => _loadLegalEntities());
  }

  void _showEditEntityDialog(LegalEntity entity) {
    showDialog(
      context: context,
      builder: (context) => LegalEntityFormDialog(entity: entity),
    ).then((_) => _loadLegalEntities());
  }

  Future<void> _approveEntity(LegalEntity entity) async {
    final authProvider = context.read<AuthProvider>();
    final adminId = authProvider.currentUser?.idUser;

    if (adminId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Errore: utente non autenticato')),
      );
      return;
    }

    final success = await context
        .read<LegalEntityProvider>()
        .approveLegalEntity(entity.idLegalEntity);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entità approvata con successo')),
      );
      _loadLegalEntities();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Errore nell\'approvazione dell\'entità')),
      );
    }
  }

  void _showRejectDialog(LegalEntity entity) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rifiuta Entità'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Inserisci il motivo del rifiuto:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Motivo del rifiuto...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () async {
              final authProvider = context.read<AuthProvider>();
              final adminId = authProvider.currentUser?.idUser;

              if (adminId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Errore: utente non autenticato'),
                  ),
                );
                return;
              }

              final success = await context
                  .read<LegalEntityProvider>()
                  .rejectLegalEntity(
                    entity.idLegalEntity,
                    reasonController.text,
                  );

              Navigator.of(context).pop();

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Entità rifiutata con successo'),
                  ),
                );
                _loadLegalEntities();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Errore nel rifiuto dell\'entità'),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Rifiuta'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(LegalEntity entity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina Entità'),
        content: Text(
          'Sei sicuro di voler eliminare l\'entità "${entity.legalName ?? 'senza nome'}"? Questa azione non può essere annullata.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () async {
              final provider = context.read<LegalEntityProvider>();
              final success = await provider.deleteLegalEntity(
                entity.idLegalEntity,
              );

              Navigator.of(context).pop();

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Entità eliminata con successo'),
                  ),
                );
                // Ricarica la lista
                await provider.refreshLegalEntities();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Errore nell\'eliminazione dell\'entità'),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }
}

// Dialog per creare/modificare entità legale
class LegalEntityFormDialog extends StatefulWidget {
  final LegalEntity? entity;

  const LegalEntityFormDialog({super.key, this.entity});

  @override
  State<LegalEntityFormDialog> createState() => _LegalEntityFormDialogState();
}

class _LegalEntityFormDialogState extends State<LegalEntityFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = <String, TextEditingController>{};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final fields = [
      'status',
      'legal_name',
      'identifier_code',
      'operational_address',
      'operational_city',
      'operational_postal_code',
      'operational_state',
      'operational_country',
      'headquarter_address',
      'headquarter_city',
      'headquarter_postal_code',
      'headquarter_state',
      'headquarter_country',
      'legal_rapresentative',
      'email',
      'phone',
      'pec',
      'website',
    ];

    for (final field in fields) {
      _controllers[field] = TextEditingController();

      // Se stiamo modificando, riempi i campi con i valori esistenti
      if (widget.entity != null) {
        String? value;
        switch (field) {
          case 'status':
            value = widget.entity!.status.toString().split('.').last;
            break;
          case 'legal_name':
            value = widget.entity!.legalName;
            break;
          case 'identifier_code':
            value = widget.entity!.identifierCode;
            break;
          case 'operational_address':
            value = widget.entity!.operationalAddress;
            break;
          case 'operational_city':
            value = widget.entity!.operationalCity;
            break;
          case 'operational_postal_code':
            value = widget.entity!.operationalPostalCode;
            break;
          case 'operational_state':
            value = widget.entity!.operationalState;
            break;
          case 'operational_country':
            value = widget.entity!.operationalCountry;
            break;
          case 'headquarter_address':
            value = widget.entity!.headquarterAddress;
            break;
          case 'headquarter_city':
            value = widget.entity!.headquarterCity;
            break;
          case 'headquarter_postal_code':
            value = widget.entity!.headquarterPostalCode;
            break;
          case 'headquarter_state':
            value = widget.entity!.headquarterState;
            break;
          case 'headquarter_country':
            value = widget.entity!.headquarterCountry;
            break;
          case 'legal_rapresentative':
            value = widget.entity!.legalRapresentative;
            break;
          case 'email':
            value = widget.entity!.email;
            break;
          case 'phone':
            value = widget.entity!.phone;
            break;
          case 'pec':
            value = widget.entity!.pec;
            break;
          case 'website':
            value = widget.entity!.website;
            break;
        }
        _controllers[field]!.text = value ?? '';
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.entity != null;

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  isEditing ? 'Modifica Entità Legale' : 'Nuova Entità Legale',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const Divider(),

            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Informazioni Generali
                      const Text(
                        'Informazioni Generali',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _controllers['legal_name'],
                              labelText: 'Nome Legale *',
                              hintText:
                                  'Inserisci il nome legale dell\'azienda',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Il nome legale è obbligatorio';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller: _controllers['identifier_code'],
                              labelText: 'Codice Identificativo *',
                              hintText: 'P.IVA, Codice Fiscale, etc.',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Il codice identificativo è obbligatorio';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Informazioni di Contatto
                      const Text(
                        'Informazioni di Contatto',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _controllers['email'],
                              labelText: 'Email',
                              hintText: 'email@azienda.com',
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller: _controllers['phone'],
                              labelText: 'Telefono',
                              hintText: '+39 123 456 7890',
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _controllers['pec'],
                              labelText: 'PEC',
                              hintText: 'pec@azienda.legalmail.it',
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller: _controllers['website'],
                              labelText: 'Sito Web',
                              hintText: 'https://www.azienda.com',
                              keyboardType: TextInputType.url,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      CustomTextField(
                        controller: _controllers['legal_rapresentative'],
                        labelText: 'Rappresentante Legale',
                        hintText: 'Nome e cognome del rappresentante legale',
                      ),

                      const SizedBox(height: 24),

                      // Indirizzo Operativo
                      const Text(
                        'Indirizzo Operativo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        controller: _controllers['operational_address'],
                        labelText: 'Indirizzo',
                        hintText: 'Via/Piazza, numero civico',
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: CustomTextField(
                              controller: _controllers['operational_city'],
                              labelText: 'Città',
                              hintText: 'Roma',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller:
                                  _controllers['operational_postal_code'],
                              labelText: 'CAP',
                              hintText: '00100',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _controllers['operational_state'],
                              labelText: 'Provincia',
                              hintText: 'RM',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller: _controllers['operational_country'],
                              labelText: 'Paese',
                              hintText: 'Italia',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Sede Legale
                      const Text(
                        'Sede Legale',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        controller: _controllers['headquarter_address'],
                        labelText: 'Indirizzo',
                        hintText: 'Via/Piazza, numero civico',
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: CustomTextField(
                              controller: _controllers['headquarter_city'],
                              labelText: 'Città',
                              hintText: 'Milano',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller:
                                  _controllers['headquarter_postal_code'],
                              labelText: 'CAP',
                              hintText: '20100',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _controllers['headquarter_state'],
                              labelText: 'Provincia',
                              hintText: 'MI',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller: _controllers['headquarter_country'],
                              labelText: 'Paese',
                              hintText: 'Italia',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Divider(),

            // Pulsanti di azione
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annulla'),
                ),
                const SizedBox(width: 16),
                CustomButton(
                  text: isEditing ? 'Salva Modifiche' : 'Crea Entità',
                  onPressed: _saveEntity,
                  isLoading: context.watch<LegalEntityProvider>().isLoading,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveEntity() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<LegalEntityProvider>();
    final entityData = <String, dynamic>{};

    // Raccogli i dati dal form
    _controllers.forEach((key, controller) {
      if (controller.text.isNotEmpty) {
        entityData[key] = controller.text;
      }
    });

    // Assicurati che il campo status sia sempre presente per le nuove entità
    if (widget.entity == null && !entityData.containsKey('status')) {
      entityData['status'] = 'pending';
    }

    bool success;
    if (widget.entity != null) {
      // Modifica entità esistente
      final provider = context.read<LegalEntityProvider>();
      success =
          await provider.updateLegalEntity(
            id: widget.entity!.idLegalEntity,
            entityData: entityData,
          ) !=
          null;
    } else {
      // Crea nuova entità
      success = await provider.createLegalEntity(entityData) != null;
    }

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.entity != null
                ? 'Entità modificata con successo'
                : 'Entità creata con successo',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Errore nel salvataggio dell\'entità')),
      );
    }
  }
}
