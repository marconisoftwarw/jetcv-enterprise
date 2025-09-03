import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlack.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppTheme.offWhite.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.verified_user,
                  size: 120,
                  color: AppTheme.pureWhite,
                ),
              ),

              const SizedBox(height: 32),

              // App Name
              Text(
                AppConfig.appName,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.pureWhite,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // App Tagline
              Text(
                'Professional Certification Platform',
                style: TextStyle(
                  fontSize: 18,
                  color: AppTheme.offWhite.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 64),

              // Loading Indicator
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlack.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.pureWhite),
                  strokeWidth: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
