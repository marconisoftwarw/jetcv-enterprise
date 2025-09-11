import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../theme/app_theme.dart';
import '../../widgets/neon_button.dart';
import '../../widgets/enterprise_card.dart';
import '../../widgets/page_with_floating_language.dart';
import '../../l10n/app_localizations.dart';

class PublicHomeScreen extends StatelessWidget {
  const PublicHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageWithFloatingLanguage(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 240,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: AppTheme.pureWhite,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  AppConfig.appName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppTheme.pureWhite.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.pureWhite.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 20,
                                spreadRadius: 0,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.verified_user,
                            size: 50,
                            color: AppTheme.pureWhite,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Enterprise Certification Platform',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppTheme.pureWhite,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/cv-list'),
                  child: Text(
                    AppLocalizations.of(context).getString('public_cvs'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.pureWhite,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/legal-entity/pricing'),
                  child: Text(
                    AppLocalizations.of(context).getString('pricing'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.pureWhite,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: Text(
                    AppLocalizations.of(context).getString('login'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.pureWhite,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),

            // Hero Section
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    // Main heading
                    Text(
                      AppLocalizations.of(
                        context,
                      ).getString('professional_certification_platform'),
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(
                        context,
                      ).getString('streamline_business_verification'),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textGray,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // Main CTA Buttons
                    Row(
                      children: [
                        Expanded(
                          child: NeonButton(
                            text: AppLocalizations.of(
                              context,
                            ).getString('view_pricing'),
                            onPressed: () => Navigator.pushNamed(
                              context,
                              '/legal-entity/pricing',
                            ),
                            neonColor: AppTheme.successGreen,
                            height: 56,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: NeonButton(
                            text: AppLocalizations.of(
                              context,
                            ).getString('register_company'),
                            onPressed: () => Navigator.pushNamed(
                              context,
                              '/legal-entity/register',
                            ),
                            isOutlined: true,
                            neonColor: AppTheme.primaryBlue,
                            height: 56,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Secondary actions
                    Row(
                      children: [
                        Expanded(
                          child: NeonButton(
                            text: AppLocalizations.of(
                              context,
                            ).getString('explore_cvs'),
                            onPressed: () {
                              Navigator.pushNamed(context, '/cv-list');
                            },
                            icon: Icons.description,
                            isOutlined: true,
                            neonColor: AppTheme.purple,
                            height: 48,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: NeonButton(
                            text: AppLocalizations.of(
                              context,
                            ).getString('pricing'),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/legal-entity/pricing',
                              );
                            },
                            icon: Icons.price_check,
                            isOutlined: true,
                            neonColor: AppTheme.warningOrange,
                            height: 48,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Additional actions
                    Row(
                      children: [
                        Expanded(
                          child: NeonButton(
                            text: 'Create Certification',
                            onPressed: () {
                              // For public users, redirect to login/registration
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Please login to create certifications',
                                    style: TextStyle(
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  backgroundColor: AppTheme.pureWhite,
                                ),
                              );
                            },
                            icon: Icons.verified_user,
                            isOutlined: true,
                            neonColor: AppTheme.purple,
                            height: 48,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: NeonButton(
                            text: 'Registra Azienda',
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/legal-entity/register',
                              );
                            },
                            icon: Icons.business,
                            isOutlined: true,
                            neonColor: AppTheme.primaryBlue,
                            height: 48,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Features Section
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).getString('key_features'),
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                    ),
                    const SizedBox(height: 32),

                    _buildFeatureCard(
                      icon: Icons.verified_user,
                      title: AppLocalizations.of(
                        context,
                      ).getString('identity_verification'),
                      description: AppLocalizations.of(
                        context,
                      ).getString('secure_reliable_verification'),
                    ),
                    const SizedBox(height: 20),

                    _buildFeatureCard(
                      icon: Icons.business,
                      title: AppLocalizations.of(
                        context,
                      ).getString('legal_entity_management'),
                      description: AppLocalizations.of(
                        context,
                      ).getString('comprehensive_management'),
                    ),
                    const SizedBox(height: 20),

                    _buildFeatureCard(
                      icon: Icons.security,
                      title: AppLocalizations.of(
                        context,
                      ).getString('secure_platform'),
                      description: AppLocalizations.of(
                        context,
                      ).getString('enterprise_grade_security'),
                    ),
                    const SizedBox(height: 20),

                    _buildFeatureCard(
                      icon: Icons.analytics,
                      title: AppLocalizations.of(
                        context,
                      ).getString('analytics_reporting'),
                      description: AppLocalizations.of(
                        context,
                      ).getString('advanced_analytics'),
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppTheme.pureWhite,
                  border: Border(
                    top: BorderSide(color: AppTheme.borderGray, width: 1),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '© 2024 ${AppConfig.appName}. ${AppLocalizations.of(context).getString('all_rights_reserved')}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textGray,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(
                        context,
                      ).getString('professional_certification_platform_footer'),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppTheme.textGray),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Builder(
      builder: (context) {
        return EnterpriseCard(
          isHoverable: true,
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                      blurRadius: 8,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: AppTheme.pureWhite, size: 32),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textGray,
                        height: 1.5,
                      ),
                    ),
                    if (actionText != null && onAction != null) ...[
                      const SizedBox(height: 16),
                      NeonButton(
                        text: actionText,
                        onPressed: onAction,
                        isOutlined: true,
                        neonColor: AppTheme.primaryBlue,
                        height: 40,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
