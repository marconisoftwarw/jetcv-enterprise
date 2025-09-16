import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../models/certifier.dart';
import '../services/certifier_service.dart';
import '../providers/auth_provider.dart';
import '../providers/legal_entity_provider.dart';
import '../services/user_type_service.dart';
import '../widgets/enterprise_card.dart';
import '../widgets/modern_loader.dart';

class CertifiersContent extends StatefulWidget {
  @override
  _CertifiersContentState createState() => _CertifiersContentState();
}

class _CertifiersContentState extends State<CertifiersContent> {
  final CertifierService _certifierService = CertifierService();
  List<CertifierWithUser> _certifiersWithUser = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCertifiers();
  }

  Future<void> _loadCertifiers() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final legalEntityProvider = Provider.of<LegalEntityProvider>(
        context,
        listen: false,
      );
      final isAdmin = authProvider.userType == AppUserType.admin;

      List<CertifierWithUser> certifiersWithUser;

      if (isAdmin) {
        // Admin vede tutti i certificatori con dati utente
        print('🔍 Loading all certifiers with user data for admin');
        certifiersWithUser = await _certifierService
            .getCertifiersWithUserByLegalEntity('all');
      } else {
        // Legal entity vede solo i propri certificatori con dati utente
        final selectedLegalEntity = legalEntityProvider.selectedLegalEntity;

        if (selectedLegalEntity == null) {
          final l10n = AppLocalizations.of(context);
          setState(() {
            _errorMessage = l10n.getString('no_legal_entity_selected');
            _isLoading = false;
          });
          return;
        }

        print(
          '🔍 Loading certifiers with user data for legal entity: ${selectedLegalEntity.idLegalEntity}',
        );

        // Usa la nuova Edge Function per ottenere certificatori con dati utente
        certifiersWithUser = await _certifierService
            .getCertifiersWithUserByLegalEntity(
              selectedLegalEntity.idLegalEntity,
            );
      }

      setState(() {
        _certifiersWithUser = certifiersWithUser;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading certifiers: $e');
      final l10n = AppLocalizations.of(context);
      setState(() {
        _errorMessage = '${l10n.getString('error_loading_certifiers')}: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isTablet = MediaQuery.of(context).size.width > 768;

    if (_isLoading) {
      return ModernLoader(
        title: l10n.getString('loading_certifiers'),
        subtitle: l10n.getString('please_wait'),
        icon: Icons.verified_user,
        isTablet: isTablet,
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: isTablet ? 64 : 48,
              color: AppTheme.errorRed,
            ),
            SizedBox(height: isTablet ? 16 : 12),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: AppTheme.errorRed,
              ),
            ),
            SizedBox(height: isTablet ? 24 : 16),
            ElevatedButton(
              onPressed: _loadCertifiers,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: AppTheme.pureWhite,
              ),
              child: Text(l10n.getString('retry')),
            ),
          ],
        ),
      );
    }

    if (_certifiersWithUser.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: isTablet ? 64 : 48,
              color: AppTheme.textSecondary,
            ),
            SizedBox(height: isTablet ? 16 : 12),
            Text(
              l10n.getString('no_certifiers_found'),
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryBlack,
              ),
            ),
            SizedBox(height: 8),
            Text(
              l10n.getString('no_certifiers_for_entity'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con titolo e pulsante refresh
        Padding(
          padding: EdgeInsets.all(isTablet ? 24 : 16),
          child: Row(
            children: [
              Text(
                l10n.getString('certifiers'),
                style: TextStyle(
                  fontSize: isTablet ? 24 : 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBlack,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.refresh, color: AppTheme.primaryBlue),
                onPressed: _loadCertifiers,
                tooltip: l10n.getString('refresh'),
              ),
            ],
          ),
        ),

        // Lista certificatori
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 24 : 16,
              vertical: isTablet ? 8 : 4,
            ),
            itemCount: _certifiersWithUser.length,
            separatorBuilder: (context, index) =>
                SizedBox(height: isTablet ? 16 : 12),
            itemBuilder: (context, index) {
              final certifierWithUser = _certifiersWithUser[index];
              return _buildCertifierCard(certifierWithUser, l10n, isTablet);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCertifierCard(
    CertifierWithUser certifierWithUser,
    AppLocalizations l10n,
    bool isTablet,
  ) {
    final certifier = certifierWithUser.certifier;
    final user = certifierWithUser.user;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAdmin = authProvider.userType == AppUserType.admin;

    // Debug logging
    print('🔍 Building certifier card:');
    print('   - Certifier ID: ${certifier.idCertifier}');
    print('   - User is null: ${user == null}');
    if (user != null) {
      print('   - User ID: ${user.idUser}');
      print('   - First Name: ${user.firstName}');
      print('   - Last Name: ${user.lastName}');
      print('   - Email: ${user.email}');
    }

    return EnterpriseCard(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        child: Row(
          children: [
            // Avatar
            Container(
              width: isTablet ? 60 : 50,
              height: isTablet ? 60 : 50,
              decoration: BoxDecoration(
                color: certifier.active
                    ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                    : AppTheme.neutralGrey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(isTablet ? 30 : 25),
              ),
              child: user != null
                  ? Center(
                      child: Text(
                        certifierWithUser.initials,
                        style: TextStyle(
                          color: certifier.active
                              ? AppTheme.primaryBlue
                              : AppTheme.textSecondary,
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.person,
                      color: certifier.active
                          ? AppTheme.primaryBlue
                          : AppTheme.textSecondary,
                      size: isTablet ? 28 : 24,
                    ),
            ),
            SizedBox(width: isTablet ? 16 : 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First Name - sempre mostrato
                  if (user != null) ...[
                    Text(
                      user.firstName?.isNotEmpty == true
                          ? user.firstName!
                          : 'N/A',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlack,
                      ),
                    ),
                    // Last Name - sempre mostrato
                    Text(
                      user.lastName?.isNotEmpty == true &&
                              user.lastName != 'N/A'
                          ? user.lastName!
                          : 'N/A',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlack,
                      ),
                    ),
                    // Email - sempre mostrata
                    SizedBox(height: 2),
                    Text(
                      user.email?.isNotEmpty == true ? user.email! : 'N/A',
                      style: TextStyle(
                        fontSize: isTablet ? 13 : 11,
                        color: AppTheme.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Invito in sospeso',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlack,
                      ),
                    ),
                  ],

                  // Data di nascita
                  if (user != null && user.dateOfBirth != null) ...[
                    SizedBox(height: 2),
                    Text(
                      'Nato il ${certifierWithUser.dateOfBirthFormatted}',
                      style: TextStyle(
                        fontSize: isTablet ? 12 : 10,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],

                  // Ruolo
                  if (certifier.role != null) ...[
                    SizedBox(height: 4),
                    Text(
                      certifier.role!,
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],

                  // Città
                  if (user != null && user.city != null) ...[
                    SizedBox(height: 2),
                    Text(
                      user.city!,
                      style: TextStyle(
                        fontSize: isTablet ? 12 : 10,
                        color: AppTheme.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  if (isAdmin) ...[
                    SizedBox(height: 4),
                    Text(
                      'Legal Entity: ${certifier.idLegalEntity}',
                      style: TextStyle(
                        fontSize: isTablet ? 12 : 10,
                        color: AppTheme.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  SizedBox(height: 8),
                  Row(
                    children: [
                      // Status badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 12 : 8,
                          vertical: isTablet ? 6 : 4,
                        ),
                        decoration: BoxDecoration(
                          color: certifier.active
                              ? AppTheme.successGreen.withValues(alpha: 0.1)
                              : AppTheme.neutralGrey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(
                            isTablet ? 16 : 12,
                          ),
                        ),
                        child: Text(
                          certifier.active
                              ? l10n.getString('active')
                              : l10n.getString('inactive'),
                          style: TextStyle(
                            fontSize: isTablet ? 12 : 10,
                            fontWeight: FontWeight.w500,
                            color: certifier.active
                                ? AppTheme.successGreen
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      if (certifier.kycPassed == true) ...[
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 12 : 8,
                            vertical: isTablet ? 6 : 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              isTablet ? 16 : 12,
                            ),
                          ),
                          child: Text(
                            l10n.getString('kyc_verified'),
                            style: TextStyle(
                              fontSize: isTablet ? 12 : 10,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ),
                      ] else if (certifier.kycPassed == false) ...[
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 12 : 8,
                            vertical: isTablet ? 6 : 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.errorRed.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              isTablet ? 16 : 12,
                            ),
                          ),
                          child: Text(
                            l10n.getString('kyc_failed'),
                            style: TextStyle(
                              fontSize: isTablet ? 12 : 10,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.errorRed,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            IconButton(
              icon: Icon(
                Icons.more_vert,
                color: AppTheme.textSecondary,
                size: isTablet ? 24 : 20,
              ),
              onPressed: () => _showCertifierActions(certifierWithUser),
            ),
          ],
        ),
      ),
    );
  }

  void _showCertifierActions(CertifierWithUser certifierWithUser) {
    final certifier = certifierWithUser.certifier;
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.visibility, color: AppTheme.primaryBlue),
                title: Text(l10n.getString('view_details')),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to certifier details
                },
              ),
              if (certifier.invitationToken != null) ...[
                ListTile(
                  leading: Icon(Icons.send, color: AppTheme.primaryBlue),
                  title: Text(l10n.getString('resend_invitation')),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Resend invitation
                  },
                ),
              ],
              ListTile(
                leading: Icon(
                  certifier.active ? Icons.person_off : Icons.person,
                  color: certifier.active
                      ? AppTheme.errorRed
                      : AppTheme.successGreen,
                ),
                title: Text(
                  certifier.active
                      ? l10n.getString('deactivate')
                      : l10n.getString('activate'),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Toggle active status
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
