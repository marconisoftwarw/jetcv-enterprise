import 'package:flutter/material.dart';
import '../../config/app_config.dart';

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
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(AppConfig.primaryColorValue),
                      Color(AppConfig.primaryColorValue).withOpacity(0.8),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.verified_user,
                    size: 80,
                    color: Colors.white,
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
                  const Text(
                    'Professional Certification Platform',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Streamline your business verification process with our comprehensive legal entity management system.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // CTA Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/signup'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(AppConfig.primaryColorValue),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Get Started'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/signup'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Register Company'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Additional Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/cv-list');
                          },
                          icon: const Icon(Icons.description),
                          label: const Text('Esplora CV'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // For public users, redirect to login/registration
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please login to create certifications',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.verified_user),
                          label: const Text('Create Certification'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
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
                  const Text(
                    'Key Features',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                    actionText: 'Get Started',
                    onAction: () {
                      // Navigate to legal entity management
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
              color: Colors.grey[100],
              child: Column(
                children: [
                  Text(
                    '© 2024 ${AppConfig.appName}. All rights reserved.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Professional certification and verification platform',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Color(AppConfig.primaryColorValue).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Color(AppConfig.primaryColorValue),
                size: 30,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  if (actionText != null && onAction != null) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: onAction,
                      child: Text(
                        actionText,
                        style: TextStyle(
                          color: Color(AppConfig.primaryColorValue),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
