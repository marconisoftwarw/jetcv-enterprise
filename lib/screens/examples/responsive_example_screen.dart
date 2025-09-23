import 'package:flutter/material.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/responsive_card.dart';
import '../../theme/app_theme.dart';

/// Example screen demonstrating all responsive features
class ResponsiveExampleScreen extends StatelessWidget {
  const ResponsiveExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      showMenu: true,
      selectedIndex: 0,
      onDestinationSelected: (index) {
        // Handle navigation
      },
      title: 'Responsive Example',
      child: SingleChildScrollView(
        padding: ResponsivePadding.screen(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeader(context),

            SizedBox(height: ResponsiveBreakpoints.isMobile(context) ? 24 : 32),

            // Responsive Grid Example
            _buildResponsiveGrid(context),

            SizedBox(height: ResponsiveBreakpoints.isMobile(context) ? 24 : 32),

            // Responsive Cards Example
            _buildResponsiveCards(context),

            SizedBox(height: ResponsiveBreakpoints.isMobile(context) ? 24 : 32),

            // Responsive Text Example
            _buildResponsiveText(context),

            SizedBox(height: ResponsiveBreakpoints.isMobile(context) ? 24 : 32),

            // Responsive Form Example
            _buildResponsiveForm(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ResponsiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'Responsive Design System',
            textType: TextType.titleLarge,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveBreakpoints.isMobile(context) ? 8 : 12),
          ResponsiveText(
            'This screen demonstrates all the responsive features available in the app. The layout automatically adapts to different screen sizes.',
            textType: TextType.bodyLarge,
            style: TextStyle(color: AppTheme.textGray),
          ),
          SizedBox(height: ResponsiveBreakpoints.isMobile(context) ? 16 : 24),
          _buildBreakpointInfo(context),
        ],
      ),
    );
  }

  Widget _buildBreakpointInfo(BuildContext context) {
    return ResponsiveCard(
      backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'Current Breakpoint',
            textType: TextType.titleMedium,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryBlue,
            ),
          ),
          SizedBox(height: ResponsiveBreakpoints.isMobile(context) ? 8 : 12),
          ResponsiveText(
            _getBreakpointDescription(context),
            textType: TextType.bodyMedium,
            style: TextStyle(color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }

  String _getBreakpointDescription(BuildContext context) {
    if (ResponsiveBreakpoints.isSmallMobile(context)) {
      return 'Small Mobile (< 480px) - Optimized for small phones';
    } else if (ResponsiveBreakpoints.isMobile(context)) {
      return 'Mobile (480px - 768px) - Standard mobile layout';
    } else if (ResponsiveBreakpoints.isTablet(context)) {
      return 'Tablet (768px - 1200px) - Tablet-optimized layout';
    } else if (ResponsiveBreakpoints.isDesktop(context)) {
      return 'Desktop (1200px+) - Full desktop experience';
    } else {
      return 'Large Desktop (1440px+) - Large screen optimization';
    }
  }

  Widget _buildResponsiveGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          'Responsive Grid',
          textType: TextType.titleLarge,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: ResponsiveBreakpoints.isMobile(context) ? 16 : 20),
        ResponsiveGridView(
          children: List.generate(6, (index) {
            return ResponsiveCard(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star,
                    size: ResponsiveBreakpoints.isMobile(context) ? 24 : 32,
                    color: AppTheme.primaryBlue,
                  ),
                  SizedBox(
                    height: ResponsiveBreakpoints.isMobile(context) ? 8 : 12,
                  ),
                  ResponsiveText(
                    'Item ${index + 1}',
                    textType: TextType.titleMedium,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveBreakpoints.isMobile(context) ? 4 : 8,
                  ),
                  ResponsiveText(
                    'Description for item ${index + 1}',
                    textType: TextType.bodyMedium,
                    style: TextStyle(color: AppTheme.textGray),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildResponsiveCards(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          'Responsive Cards',
          textType: TextType.titleLarge,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: ResponsiveBreakpoints.isMobile(context) ? 16 : 20),
        ResponsiveBreakpoints.isMobile(context)
            ? Column(
                children: [
                  _buildFeatureCard(
                    context,
                    'Mobile First',
                    'Designed with mobile users in mind',
                    Icons.phone_android,
                    AppTheme.primaryBlue,
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureCard(
                    context,
                    'Touch Friendly',
                    'Optimized for touch interactions',
                    Icons.touch_app,
                    AppTheme.successGreen,
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureCard(
                    context,
                    'Fast Loading',
                    'Optimized for mobile networks',
                    Icons.speed,
                    AppTheme.purple,
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: _buildFeatureCard(
                      context,
                      'Mobile First',
                      'Designed with mobile users in mind',
                      Icons.phone_android,
                      AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFeatureCard(
                      context,
                      'Touch Friendly',
                      'Optimized for touch interactions',
                      Icons.touch_app,
                      AppTheme.successGreen,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFeatureCard(
                      context,
                      'Fast Loading',
                      'Optimized for mobile networks',
                      Icons.speed,
                      AppTheme.purple,
                    ),
                  ),
                ],
              ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return ResponsiveCard(
      child: Column(
        children: [
          Container(
            width: ResponsiveBreakpoints.isMobile(context) ? 48 : 64,
            height: ResponsiveBreakpoints.isMobile(context) ? 48 : 64,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(
                ResponsiveBreakpoints.isMobile(context) ? 12 : 16,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: ResponsiveBreakpoints.isMobile(context) ? 24 : 32,
            ),
          ),
          SizedBox(height: ResponsiveBreakpoints.isMobile(context) ? 12 : 16),
          ResponsiveText(
            title,
            textType: TextType.titleMedium,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveBreakpoints.isMobile(context) ? 4 : 8),
          ResponsiveText(
            description,
            textType: TextType.bodyMedium,
            style: TextStyle(color: AppTheme.textGray),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveText(BuildContext context) {
    return ResponsiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'Responsive Typography',
            textType: TextType.titleLarge,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveBreakpoints.isMobile(context) ? 16 : 20),
          ResponsiveText(
            'Title Large - Perfect for headings',
            textType: TextType.titleLarge,
            style: TextStyle(color: AppTheme.textPrimary),
          ),
          SizedBox(height: ResponsiveBreakpoints.isMobile(context) ? 8 : 12),
          ResponsiveText(
            'Title Medium - Great for subheadings',
            textType: TextType.titleMedium,
            style: TextStyle(color: AppTheme.textPrimary),
          ),
          SizedBox(height: ResponsiveBreakpoints.isMobile(context) ? 8 : 12),
          ResponsiveText(
            'Body Large - Perfect for important content',
            textType: TextType.bodyLarge,
            style: TextStyle(color: AppTheme.textPrimary),
          ),
          SizedBox(height: ResponsiveBreakpoints.isMobile(context) ? 8 : 12),
          ResponsiveText(
            'Body Medium - Ideal for regular text content',
            textType: TextType.bodyMedium,
            style: TextStyle(color: AppTheme.textGray),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveForm(BuildContext context) {
    return ResponsiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'Responsive Form',
            textType: TextType.titleLarge,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveBreakpoints.isMobile(context) ? 16 : 20),
          ResponsiveBreakpoints.isMobile(context)
              ? Column(
                  children: [
                    _buildFormField(context, 'First Name'),
                    const SizedBox(height: 16),
                    _buildFormField(context, 'Last Name'),
                    const SizedBox(height: 16),
                    _buildFormField(context, 'Email'),
                    const SizedBox(height: 16),
                    _buildFormField(context, 'Phone'),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: _buildFormField(context, 'First Name')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildFormField(context, 'Last Name')),
                  ],
                ),
          if (!ResponsiveBreakpoints.isMobile(context)) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildFormField(context, 'Email')),
                const SizedBox(width: 16),
                Expanded(child: _buildFormField(context, 'Phone')),
              ],
            ),
          ],
          SizedBox(height: ResponsiveBreakpoints.isMobile(context) ? 24 : 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: AppTheme.pureWhite,
                padding: EdgeInsets.symmetric(
                  vertical: ResponsiveBreakpoints.isMobile(context) ? 12 : 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveBreakpoints.isMobile(context) ? 8 : 12,
                  ),
                ),
              ),
              child: ResponsiveText(
                'Submit Form',
                textType: TextType.titleMedium,
                style: TextStyle(
                  color: AppTheme.pureWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(BuildContext context, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          label,
          textType: TextType.bodyMedium,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: ResponsiveBreakpoints.isMobile(context) ? 4 : 8),
        TextField(
          decoration: InputDecoration(
            hintText: 'Enter $label',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveBreakpoints.isMobile(context) ? 8 : 12,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveBreakpoints.isMobile(context) ? 12 : 16,
              vertical: ResponsiveBreakpoints.isMobile(context) ? 12 : 16,
            ),
          ),
        ),
      ],
    );
  }
}
