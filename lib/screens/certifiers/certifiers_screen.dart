import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../models/certifier.dart';
import '../../services/certifier_service.dart';
import '../../providers/legal_entity_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/user_type_service.dart';
import '../../widgets/enterprise_card.dart';
import 'package:provider/provider.dart';

class CertifiersScreen extends StatefulWidget {
  const CertifiersScreen({super.key});

  @override
  State<CertifiersScreen> createState() => _CertifiersScreenState();
}

class _CertifiersScreenState extends State<CertifiersScreen>
    with TickerProviderStateMixin {
  final CertifierService _certifierService = CertifierService();
  List<Certifier> _certifiers = [];
  bool _isLoading = true;
  String? _errorMessage;
  late AnimationController _loadingAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadCertifiers();
  }

  void _initializeAnimations() {
    _loadingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _loadingAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _loadingAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _loadingAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadCertifiers() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isAdmin = authProvider.userType == AppUserType.admin;

      List<Certifier> certifiers;

      if (isAdmin) {
        // Admin vede tutti i certificatori
        print('🔍 Loading all certifiers for admin');
        certifiers = await _certifierService.getAllCertifiers();
      } else {
        // Legal entity vede solo i propri certificatori
        final legalEntityProvider = Provider.of<LegalEntityProvider>(
          context,
          listen: false,
        );
        final selectedLegalEntity = legalEntityProvider.selectedLegalEntity;

        if (selectedLegalEntity == null) {
          setState(() {
            _errorMessage = 'Nessuna legal entity selezionata';
            _isLoading = false;
          });
          return;
        }

        print(
          '🔍 Loading certifiers for legal entity: ${selectedLegalEntity.idLegalEntity}',
        );

        certifiers = await _certifierService.getCertifiersByLegalEntity(
          selectedLegalEntity.idLegalEntity,
        );
      }

      setState(() {
        _certifiers = certifiers;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading certifiers: $e');
      setState(() {
        _errorMessage = 'Errore nel caricamento dei certificatori: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isTablet = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      backgroundColor: AppTheme.lightGrey.withValues(alpha: 0.1),
      appBar: AppBar(
        backgroundColor: AppTheme.pureWhite,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.getString('certifiers'),
          style: TextStyle(
            color: AppTheme.primaryBlack,
            fontWeight: FontWeight.w600,
            fontSize: isTablet ? 20 : 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppTheme.primaryBlue),
            onPressed: _loadCertifiers,
          ),
        ],
      ),
      body: _buildBody(l10n, isTablet),
    );
  }

  Widget _buildBody(AppLocalizations l10n, bool isTablet) {
    if (_isLoading) {
      return _buildModernLoader(isTablet);
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
              child: Text('Riprova'),
            ),
          ],
        ),
      );
    }

    if (_certifiers.isEmpty) {
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
              'Nessun certificatore trovato',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryBlack,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Non ci sono certificatori per questa legal entity',
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

    return ListView.separated(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      itemCount: _certifiers.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: isTablet ? 16 : 12),
      itemBuilder: (context, index) {
        final certifier = _certifiers[index];
        return _buildCertifierCard(certifier, l10n, isTablet);
      },
    );
  }

  Widget _buildModernLoader(bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.lightGrey.withValues(alpha: 0.05),
            AppTheme.lightGrey.withValues(alpha: 0.15),
          ],
        ),
      ),
      child: Center(
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Container principale del loader
                  Container(
                    width: isTablet ? 200 : 160,
                    height: isTablet ? 200 : 160,
                    decoration: BoxDecoration(
                      color: AppTheme.pureWhite,
                      borderRadius: BorderRadius.circular(isTablet ? 32 : 24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                          blurRadius: isTablet ? 50 : 40,
                          offset: const Offset(0, 10),
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: isTablet ? 25 : 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Loader animato con gradiente
                        AnimatedBuilder(
                          animation: _fadeAnimation,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _fadeAnimation.value,
                              child: Container(
                                width: isTablet ? 80 : 60,
                                height: isTablet ? 80 : 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    isTablet ? 40 : 30,
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppTheme.primaryBlue,
                                      AppTheme.primaryBlue.withValues(
                                        alpha: 0.8,
                                      ),
                                      AppTheme.primaryBlue.withValues(
                                        alpha: 0.9,
                                      ),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryBlue.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 15,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Loader principale
                                    SizedBox(
                                      width: isTablet ? 60 : 45,
                                      height: isTablet ? 60 : 45,
                                      child: CircularProgressIndicator(
                                        strokeWidth: isTablet ? 4 : 3,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppTheme.pureWhite,
                                            ),
                                      ),
                                    ),
                                    // Icona centrale
                                    Icon(
                                      Icons.verified_user,
                                      color: AppTheme.pureWhite,
                                      size: isTablet ? 28 : 20,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: isTablet ? 24 : 20),

                        // Testo di caricamento
                        AnimatedBuilder(
                          animation: _fadeAnimation,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _fadeAnimation.value,
                              child: Column(
                                children: [
                                  Text(
                                    'Caricamento certificatori...',
                                    style: TextStyle(
                                      fontSize: isTablet ? 18 : 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryBlack,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(height: isTablet ? 8 : 6),
                                  Text(
                                    'Attendere prego',
                                    style: TextStyle(
                                      fontSize: isTablet ? 14 : 12,
                                      color: AppTheme.textSecondary,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isTablet ? 32 : 24),

                  // Indicatori puntini animati
                  _buildAnimatedDots(isTablet),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedDots(bool isTablet) {
    return AnimatedBuilder(
      animation: _loadingAnimationController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final offset = (index * 0.33);
            final animationValue =
                (_loadingAnimationController.value + offset) % 1.0;
            final opacity =
                (0.3 + (0.7 * (1.0 - (animationValue - 0.5).abs() * 2))).clamp(
                  0.3,
                  1.0,
                );
            final scale =
                (0.7 + (0.3 * (1.0 - (animationValue - 0.5).abs() * 2))).clamp(
                  0.7,
                  1.0,
                );

            return Transform.scale(
              scale: scale,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: isTablet ? 8 : 6),
                width: isTablet ? 14 : 10,
                height: isTablet ? 14 : 10,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: opacity),
                  shape: BoxShape.circle,
                  boxShadow: opacity > 0.7
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.4),
                            blurRadius: isTablet ? 8 : 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildCertifierCard(
    Certifier certifier,
    AppLocalizations l10n,
    bool isTablet,
  ) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAdmin = authProvider.userType == AppUserType.admin;

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
              child: Icon(
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
                  Text(
                    certifier.idUser ?? 'Invito in sospeso',
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryBlack,
                    ),
                  ),
                  if (certifier.role != null) ...[
                    SizedBox(height: 4),
                    Text(
                      certifier.role!,
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: AppTheme.textSecondary,
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
                          certifier.active ? 'Attivo' : 'Inattivo',
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
                            'KYC Verificato',
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
                            'KYC Fallito',
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
              onPressed: () => _showCertifierActions(certifier),
            ),
          ],
        ),
      ),
    );
  }

  void _showCertifierActions(Certifier certifier) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.visibility, color: AppTheme.primaryBlue),
              title: Text('Visualizza dettagli'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to certifier details
              },
            ),
            if (certifier.invitationToken != null) ...[
              ListTile(
                leading: Icon(Icons.send, color: AppTheme.primaryBlue),
                title: Text('Rinvia invito'),
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
              title: Text(certifier.active ? 'Disattiva' : 'Attiva'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Toggle active status
              },
            ),
          ],
        ),
      ),
    );
  }
}
