import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/certification.dart';
import '../../services/certification_service.dart';
import '../../providers/auth_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/neon_button.dart';
import '../../widgets/glass_card.dart';
import '../../theme/app_theme.dart';
import '../../config/app_config.dart';
import 'create_certification_screen.dart';

class CertificationListScreen extends StatefulWidget {
  const CertificationListScreen({super.key});

  @override
  State<CertificationListScreen> createState() =>
      _CertificationListScreenState();
}

class _CertificationListScreenState extends State<CertificationListScreen> {
  final CertificationService _certificationService = CertificationService();
  List<Certification> _certifications = [];
  bool _isLoading = true;
  String _searchQuery = '';
  CertificationStatus? _statusFilter;

  @override
  void initState() {
    super.initState();
    _loadCertifications();
  }

  Future<void> _loadCertifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final currentUser = authProvider.currentUser;

      if (currentUser != null) {
        final certifications = await _certificationService.getCertifications(
          userId: currentUser.idUser,
        );

        setState(() {
          _certifications = certifications;
        });
      }
    } catch (e) {
      print('Error loading certifications: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Certification> get _filteredCertifications {
    List<Certification> filtered = _certifications;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (cert) =>
                cert.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                cert.code.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                cert.description.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    // Filter by status
    if (_statusFilter != null) {
      filtered = filtered
          .where((cert) => cert.status == _statusFilter)
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.getString('certifications')),
        backgroundColor: Color(AppConfig.primaryColorValue),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/create-certification');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: l10n.getString('search'),
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

                const SizedBox(height: 16),

                // Filter Row
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<CertificationStatus>(
                        value: _statusFilter,
                        decoration: InputDecoration(
                          labelText: l10n.getString('filter'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: null,
                            child: Text('Tutti gli stati'),
                          ),
                          ...CertificationStatus.values.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(status.toString().split('.').last),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _statusFilter = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    NeonButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/create-certification');
                      },
                      text: 'Nuova',
                      icon: Icons.add,
                      neonColor: AppTheme.accentGreen,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Certifications List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCertifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified_user,
                          size: 64,
                          color: AppTheme.lightGray,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nessuna certificazione trovata',
                          style: TextStyle(
                            color: AppTheme.lightGray,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Inizia creando la tua prima certificazione',
                          style: TextStyle(
                            color: AppTheme.mediumGray,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                        NeonButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/create-certification',
                            );
                          },
                          text: 'Crea Certificazione',
                          icon: Icons.add,
                          neonColor: AppTheme.accentGreen,
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadCertifications,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredCertifications.length,
                      itemBuilder: (context, index) {
                        final certification = _filteredCertifications[index];
                        return _buildCertificationCard(certification);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificationCard(Certification certification) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        certification.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        certification.code,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(certification.status),
              ],
            ),

            const SizedBox(height: 12),

            // Details
            Text(
              certification.description,
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Info Row
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  '${certification.createdAt.day}/${certification.createdAt.month}/${certification.createdAt.year}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(Icons.location_on, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    certification.location,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            if (certification.isOffline || !certification.isSynchronized) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    certification.isOffline
                        ? Icons.offline_bolt
                        : Icons.sync_problem,
                    size: 16,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    certification.isOffline
                        ? 'Modalità Offline'
                        : 'In Attesa di Sincronizzazione',
                    style: const TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),

            // Actions
            Row(
              children: [
                Expanded(
                  child: NeonButton(
                    onPressed: () => _viewCertificationDetails(certification),
                    text: 'Dettagli',
                    icon: Icons.visibility,
                    isOutlined: true,
                                          neonColor: AppTheme.accentBlue,
                  ),
                ),
                const SizedBox(width: 12),
                if (certification.isDraft) ...[
                  Expanded(
                    child: NeonButton(
                      onPressed: () => _editCertification(certification),
                      text: 'Modifica',
                      icon: Icons.edit,
                      neonColor: AppTheme.accentGreen,
                    ),
                  ),
                ],
                if (!certification.isSynchronized) ...[
                  Expanded(
                    child: NeonButton(
                      onPressed: () => _syncCertification(certification),
                      text: 'Sincronizza',
                      icon: Icons.sync,
                      neonColor: AppTheme.accentPurple,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(CertificationStatus status) {
    Color color;
    String text;

    switch (status) {
      case CertificationStatus.draft:
        color = AppTheme.lightGray;
        text = 'Bozza';
        break;
      case CertificationStatus.submitted:
        color = AppTheme.accentBlue;
        text = 'Inviata';
        break;
      case CertificationStatus.approved:
        color = AppTheme.accentGreen;
        text = 'Approvata';
        break;
      case CertificationStatus.rejected:
        color = AppTheme.accentOrange;
        text = 'Rifiutata';
        break;
      case CertificationStatus.expired:
        color = AppTheme.accentOrange;
        text = 'Scaduta';
        break;
      case CertificationStatus.revoked:
        color = AppTheme.accentOrange;
        text = 'Revocata';
        break;
      case CertificationStatus.closed:
        color = AppTheme.lightGray;
        text = 'Chiusa';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _viewCertificationDetails(Certification certification) {
    // Navigate to certification details
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(certification.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Codice: ${certification.code}'),
            Text('Tipo: ${certification.type}'),
            Text('Stato: ${certification.statusDisplayName}'),
            Text('Descrizione: ${certification.description}'),
            Text('Luogo: ${certification.location}'),
            Text('Data: ${certification.createdAt}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Chiudi'),
          ),
        ],
      ),
    );
  }

  void _editCertification(Certification certification) {
    // Navigate to edit certification
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateCertificationScreen(),
        // Pass certification data for editing
      ),
    );
  }

  Future<void> _syncCertification(Certification certification) async {
    try {
      final success = await _certificationService.syncCertification(
        certification.idCertification,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Certificazione sincronizzata con successo'),
            backgroundColor: Colors.green,
          ),
        );
        _loadCertifications();
      } else {
        throw Exception('Sync failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore nella sincronizzazione: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
