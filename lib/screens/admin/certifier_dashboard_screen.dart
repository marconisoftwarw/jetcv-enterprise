import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/certifier_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/certifier.dart';
import '../../theme/app_theme.dart';
import '../../widgets/linkedin_metric_card.dart';
import 'invite_certifier_screen.dart';

class CertifierDashboardScreen extends StatefulWidget {
  const CertifierDashboardScreen({super.key});

  @override
  State<CertifierDashboardScreen> createState() =>
      _CertifierDashboardScreenState();
}

class _CertifierDashboardScreenState extends State<CertifierDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser != null) {
        // TODO: Carica certificatori per la legal entity dell'utente corrente
        context.read<CertifierProvider>().loadAllCertifiers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard Certificatori',
          style: AppTheme.title1.copyWith(color: AppTheme.white),
        ),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: AppTheme.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showInviteCertifierDialog(context),
            icon: const Icon(Icons.person_add),
            tooltip: 'Invita Certificatore',
          ),
        ],
      ),
      body: Consumer<CertifierProvider>(
        builder: (context, certifierProvider, child) {
          if (certifierProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (certifierProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppTheme.errorRed),
                  const SizedBox(height: 16),
                  Text('Errore nel caricamento', style: AppTheme.title2),
                  const SizedBox(height: 8),
                  Text(
                    certifierProvider.errorMessage!,
                    style: AppTheme.body2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => certifierProvider.loadAllCertifiers(),
                    child: const Text('Riprova'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Statistiche
                _buildStatsSection(certifierProvider),
                const SizedBox(height: 24),

                // Filtri
                _buildFiltersSection(certifierProvider),
                const SizedBox(height: 24),

                // Lista certificatori
                _buildCertifiersList(certifierProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsSection(CertifierProvider provider) {
    final stats = provider.stats;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Panoramica', style: AppTheme.title2),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: LinkedInMetricCard(
                title: 'Totale',
                value: stats['total']?.toString() ?? '0',
                icon: Icons.people,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: LinkedInMetricCard(
                title: 'Attivi',
                value: stats['active']?.toString() ?? '0',
                icon: Icons.check_circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: LinkedInMetricCard(
                title: 'Con KYC',
                value: stats['withKyc']?.toString() ?? '0',
                icon: Icons.verified_user,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: LinkedInMetricCard(
                title: 'Inviti Pendenti',
                value: stats['pendingInvitation']?.toString() ?? '0',
                icon: Icons.pending,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFiltersSection(CertifierProvider provider) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filtri', style: AppTheme.title3),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Ruolo',
                    border: OutlineInputBorder(),
                  ),
                  value: provider.filterRole,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Tutti i ruoli'),
                    ),
                    const DropdownMenuItem(
                      value: 'Certificatore',
                      child: Text('Certificatore'),
                    ),
                    const DropdownMenuItem(
                      value: 'Senior Certificatore',
                      child: Text('Senior Certificatore'),
                    ),
                    const DropdownMenuItem(
                      value: 'Lead Certificatore',
                      child: Text('Lead Certificatore'),
                    ),
                  ],
                  onChanged: (value) {
                    provider.setFilters(role: value);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CheckboxListTile(
                  title: const Text('Solo attivi'),
                  value: provider.filterActiveOnly,
                  onChanged: (value) {
                    provider.setFilters(activeOnly: value);
                  },
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => provider.clearFilters(),
                child: const Text('Pulisci Filtri'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCertifiersList(CertifierProvider provider) {
    final certifiers = provider.filteredCertifiers;

    if (certifiers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: AppTheme.primaryBlack),
            const SizedBox(height: 16),
            Text(
              'Nessun certificatore trovato',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryBlack,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Inizia invitando il primo certificatore',
              style: AppTheme.body2,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showInviteCertifierDialog(context),
              child: const Text('Invita Certificatore'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Certificatori (${certifiers.length})',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryBlack,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _showInviteCertifierDialog(context),
              icon: const Icon(Icons.person_add),
              label: const Text('Nuovo'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: certifiers.length,
          itemBuilder: (context, index) {
            final certifier = certifiers[index];
            return _buildCertifierCard(certifier, provider);
          },
        ),
      ],
    );
  }

  Widget _buildCertifierCard(Certifier certifier, CertifierProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: certifier.active
              ? AppTheme.successGreen
              : AppTheme.textSecondary,
          child: Icon(
            certifier.hasUser ? Icons.person : Icons.pending,
            color: AppTheme.white,
          ),
        ),
        title: Text(
          certifier.roleDisplayName,
          style: AppTheme.body1.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryBlack,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Legal Entity: ${certifier.idLegalEntity}',
              style: AppTheme.body2,
            ),
            if (certifier.hasUser)
              Text(
                'Utente: ${certifier.idUser}',
                style: TextStyle(fontSize: 14, color: AppTheme.primaryBlack),
              ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(certifier),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    certifier.statusDisplayName,
                    style: AppTheme.caption.copyWith(color: AppTheme.white),
                  ),
                ),
                if (certifier.hasKyc) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: certifier.isKycPassed
                          ? AppTheme.successGreen
                          : AppTheme.errorRed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      certifier.isKycPassed ? 'KYC OK' : 'KYC KO',
                      style: AppTheme.caption.copyWith(color: AppTheme.white),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) =>
              _handleCertifierAction(value, certifier, provider),
          itemBuilder: (context) => [
            if (certifier.hasInvitationToken)
              const PopupMenuItem(
                value: 'resend',
                child: Text('Rinvia Invito'),
              ),
            if (certifier.active)
              const PopupMenuItem(value: 'deactivate', child: Text('Disattiva'))
            else
              const PopupMenuItem(value: 'activate', child: Text('Attiva')),
            const PopupMenuItem(value: 'edit', child: Text('Modifica')),
            const PopupMenuItem(value: 'delete', child: Text('Elimina')),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(Certifier certifier) {
    if (certifier.hasInvitationToken) return AppTheme.warningOrange;
    if (certifier.active) return AppTheme.successGreen;
    return AppTheme.textSecondary;
  }

  void _handleCertifierAction(
    String action,
    Certifier certifier,
    CertifierProvider provider,
  ) {
    switch (action) {
      case 'resend':
        _resendInvitation(certifier, provider);
        break;
      case 'activate':
        _activateCertifier(certifier, provider);
        break;
      case 'deactivate':
        _deactivateCertifier(certifier, provider);
        break;
      case 'edit':
        _editCertifier(certifier);
        break;
      case 'delete':
        _deleteCertifier(certifier, provider);
        break;
    }
  }

  void _resendInvitation(Certifier certifier, CertifierProvider provider) {
    // TODO: Implementare rinvia invito
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Invito rinviato')));
  }

  void _activateCertifier(Certifier certifier, CertifierProvider provider) {
    final updatedCertifier = certifier.copyWith(active: true);
    provider.updateCertifier(updatedCertifier);
  }

  void _deactivateCertifier(Certifier certifier, CertifierProvider provider) {
    final updatedCertifier = certifier.copyWith(active: false);
    provider.updateCertifier(updatedCertifier);
  }

  void _editCertifier(Certifier certifier) {
    // TODO: Implementare modifica certificatore
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Modifica certificatore')));
  }

  void _deleteCertifier(Certifier certifier, CertifierProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: Text(
          'Sei sicuro di voler eliminare il certificatore "${certifier.roleDisplayName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              provider.deleteCertifier(certifier.idCertifier);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorRed),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }

  void _showInviteCertifierDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const InviteCertifierScreen(),
    );
  }
}
