import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../theme/app_theme.dart';
import '../../widgets/neon_button.dart';
import '../../widgets/glass_card.dart';
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
              expandedHeight: 200,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  AppConfig.appName,
                  style: TextStyle(
                    color: AppTheme.primaryBlack,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
                  child: Center(
                    child: Icon(
                      Icons.verified_user,
                      size: 80,
                      color: AppTheme.pureWhite,
                    ),
                  ),
                ),
              ),
              actions: [
                const SizedBox(width: 4),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/cv-list'),
                  child: Text(
                    AppLocalizations.of(context).getString('public_cvs'),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/legal-entity/pricing'),
                  child: Text(
                    AppLocalizations.of(context).getString('pricing'),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: Text(
                    AppLocalizations.of(context).getString('login'),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),

            // Hero Section
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)
                          .getString('professional_certification_platform'),
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: AppTheme.primaryBlack,
                                fontWeight: FontWeight.bold,
                              ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)
                          .getString('streamline_business_verification'),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.primaryBlack,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // CTA Buttons
                    Row(
                      children: [
                        Expanded(
                          child: NeonButton(
                            text: AppLocalizations.of(context)
                                .getString('view_pricing'),
                            onPressed: () => Navigator.pushNamed(
                              context,
                              '/legal-entity/pricing',
                            ),
                            neonColor: AppTheme.accentGreen,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: NeonButton(
                            text: AppLocalizations.of(context)
                                .getString('register_company'),
                            onPressed: () => Navigator.pushNamed(
                              context,
                              '/legal-entity/register',
                            ),
                            isOutlined: true,
                            neonColor: AppTheme.accentBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: NeonButton(
                            text: AppLocalizations.of(context)
                                .getString('explore_cvs'),
                            onPressed: () {
                              Navigator.pushNamed(context, '/cv-list');
                            },
                            icon: Icons.description,
                            isOutlined: true,
                            neonColor: AppTheme.accentPurple,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: NeonButton(
                            text: AppLocalizations.of(context)
                                .getString('pricing'),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/legal-entity/pricing',
                              );
                            },
                            icon: Icons.price_check,
                            isOutlined: true,
                            neonColor: AppTheme.accentOrange,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

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
                                      color: AppTheme.primaryBlack,
                                    ),
                                  ),
                                  backgroundColor: AppTheme.glassDark,
                                ),
                              );
                            },
                            icon: Icons.verified_user,
                            isOutlined: true,
                            neonColor: AppTheme.accentPurple,
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
                            neonColor: AppTheme.accentBlue,
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
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).getString('key_features'),
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppTheme.primaryBlack,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 24),

                    _buildFeatureCard(
                      icon: Icons.verified_user,
                      title: AppLocalizations.of(context)
                          .getString('identity_verification'),
                      description: AppLocalizations.of(context)
                          .getString('secure_reliable_verification'),
                    ),
                    const SizedBox(height: 16),

                    _buildFeatureCard(
                      icon: Icons.business,
                      title: AppLocalizations.of(context)
                          .getString('legal_entity_management'),
                      description: AppLocalizations.of(context)
                          .getString('comprehensive_management'),
                    ),
                    const SizedBox(height: 16),

                    _buildFeatureCard(
                      icon: Icons.security,
                      title: AppLocalizations.of(context)
                          .getString('secure_platform'),
                      description: AppLocalizations.of(context)
                          .getString('enterprise_grade_security'),
                    ),
                    const SizedBox(height: 16),

                    _buildFeatureCard(
                      icon: Icons.analytics,
                      title: AppLocalizations.of(context)
                          .getString('analytics_reporting'),
                      description: AppLocalizations.of(context)
                          .getString('advanced_analytics'),
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(24),
                color: Colors.white,
                child: Column(
                  children: [
                    Text(
                      '© 2024 ${AppConfig.appName}. ${AppLocalizations.of(context).getString('all_rights_reserved')}',
                      style: TextStyle(
                        color: AppTheme.primaryBlack,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context).getString(
                        'professional_certification_platform_footer',
                      ),
                      style: TextStyle(
                        color: AppTheme.primaryBlack,
                        fontSize: 12,
                      ),
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
        return GlassCard(
          isHoverable: true,
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.pureWhite, size: 30),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppTheme.primaryBlack,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.primaryBlack,
                              ),
                    ),
                    if (actionText != null && onAction != null) ...[
                      const SizedBox(height: 12),
                      NeonButton(
                        text: actionText,
                        onPressed: onAction,
                        isOutlined: true,
                        neonColor: AppTheme.accentBlue,
                        height: 36,
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