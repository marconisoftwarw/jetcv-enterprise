import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../theme/app_theme.dart';
import '../../widgets/neon_button.dart';
import '../../widgets/glass_card.dart';

class PublicHomeScreen extends StatelessWidget {
  const PublicHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                style: const TextStyle(
                  color: AppTheme.offWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.neonGradient,
                ),
                child: const Center(
                  child: Icon(
                    Icons.verified_user,
                    size: 80,
                    color: AppTheme.primaryBlack,
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/cv-list'),
                child: const Text(
                  'CV Pubblici',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/legal-entity/pricing'),
                child: const Text(
                  'Pricing',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: const Text(
                  'Login',
                  style: TextStyle(color: Colors.white),
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
                    'Professional Certification Platform',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppTheme.offWhite,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Streamline your business verification process with our comprehensive legal entity management system.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.lightGrayText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // CTA Buttons
                  Row(
                    children: [
                      Expanded(
                        child: NeonButton(
                          text: 'View Pricing',
                          onPressed: () => Navigator.pushNamed(
                            context,
                            '/legal-entity/pricing',
                          ),
                          neonColor: AppTheme.neonGreen,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: NeonButton(
                          text: 'Register Company',
                          onPressed: () => Navigator.pushNamed(
                            context,
                            '/legal-entity/register',
                          ),
                          isOutlined: true,
                          neonColor: AppTheme.neonBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: NeonButton(
                          text: 'Esplora CV',
                          onPressed: () {
                            Navigator.pushNamed(context, '/cv-list');
                          },
                          icon: Icons.description,
                          isOutlined: true,
                          neonColor: AppTheme.neonPurple,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: NeonButton(
                          text: 'Pricing',
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/legal-entity/pricing',
                            );
                          },
                          icon: Icons.price_check,
                          isOutlined: true,
                          neonColor: AppTheme.neonOrange,
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
                                  style: TextStyle(color: AppTheme.offWhite),
                                ),
                                backgroundColor: AppTheme.glassDark,
                              ),
                            );
                          },
                          icon: Icons.verified_user,
                          isOutlined: true,
                          neonColor: AppTheme.neonPink,
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
                          neonColor: AppTheme.neonBlue,
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
                    'Key Features',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.offWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildFeatureCard(
                    icon: Icons.verified_user,
                    title: 'Identity Verification',
                    description:
                        'Secure and reliable identity verification for all users.',
                    actionText: 'Learn More',
                    onAction: () {
                      // Navigate to identity verification
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildFeatureCard(
                    icon: Icons.business,
                    title: 'Legal Entity Management',
                    description:
                        'Comprehensive management of legal entities and compliance.',
                    actionText: 'View Pricing',
                    onAction: () {
                      Navigator.pushNamed(context, '/legal-entity/pricing');
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildFeatureCard(
                    icon: Icons.security,
                    title: 'Secure Platform',
                    description:
                        'Enterprise-grade security with blockchain integration.',
                    actionText: 'Learn More',
                    onAction: () {
                      // Navigate to security info
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildFeatureCard(
                    icon: Icons.analytics,
                    title: 'Analytics & Reporting',
                    description:
                        'Advanced analytics and reporting capabilities.',
                    actionText: 'View Demo',
                    onAction: () {
                      // Navigate to analytics demo
                    },
                  ),
                ],
              ),
            ),
          ),

          // Footer
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              color: AppTheme.darkGray,
              child: Column(
                children: [
                  Text(
                    '© 2024 ${AppConfig.appName}. All rights reserved.',
                    style: TextStyle(
                      color: AppTheme.lightGrayText,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Professional certification and verification platform',
                    style: TextStyle(
                      color: AppTheme.mediumGrayText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
                  gradient: AppTheme.neonGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.primaryBlack, size: 30),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.offWhite,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightGrayText,
                      ),
                    ),
                    if (actionText != null && onAction != null) ...[
                      const SizedBox(height: 12),
                      NeonButton(
                        text: actionText,
                        onPressed: onAction,
                        isOutlined: true,
                        neonColor: AppTheme.neonBlue,
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
