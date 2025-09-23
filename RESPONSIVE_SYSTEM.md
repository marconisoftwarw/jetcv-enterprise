# Responsive Design System

This document describes the comprehensive responsive design system implemented in the JetCV Enterprise app. The system ensures that all screens are mobile-responsive and provide an optimal user experience across all device sizes.

## Overview

The responsive system consists of several key components:

1. **ResponsiveLayout** - Main wrapper for all screens
2. **ResponsiveCard** - Responsive card components
3. **ResponsiveBreakpoints** - Breakpoint utilities
4. **ResponsivePadding** - Responsive spacing utilities
5. **ResponsiveText** - Responsive typography
6. **ResponsiveGrid** - Responsive grid layouts

## Breakpoints

The system uses the following breakpoints:

- **Small Mobile**: < 480px
- **Mobile**: 480px - 768px
- **Tablet**: 768px - 1200px
- **Desktop**: 1200px - 1440px
- **Large Desktop**: 1440px+

## Usage

### 1. ResponsiveLayout

Use `ResponsiveLayout` as the main wrapper for all screens:

```dart
ResponsiveLayout(
  showMenu: true,
  selectedIndex: 0,
  onDestinationSelected: (index) {
    // Handle navigation
  },
  title: 'Screen Title',
  actions: [AppBarLanguageDropdown()],
  child: YourScreenContent(),
)
```

### 2. ResponsiveCard

Use `ResponsiveCard` for consistent card styling:

```dart
ResponsiveCard(
  child: Column(
    children: [
      ResponsiveText(
        'Card Title',
        textType: TextType.titleLarge,
      ),
      ResponsiveText(
        'Card content',
        textType: TextType.bodyMedium,
      ),
    ],
  ),
)
```

### 3. ResponsiveBreakpoints

Check current breakpoint:

```dart
if (ResponsiveBreakpoints.isMobile(context)) {
  // Mobile-specific code
} else if (ResponsiveBreakpoints.isTablet(context)) {
  // Tablet-specific code
} else {
  // Desktop-specific code
}
```

### 4. ResponsivePadding

Use responsive padding:

```dart
Container(
  padding: ResponsivePadding.screen(context),
  child: YourContent(),
)
```

### 5. ResponsiveText

Use responsive typography:

```dart
ResponsiveText(
  'Your text',
  textType: TextType.titleLarge,
  style: TextStyle(color: AppTheme.textPrimary),
)
```

### 6. ResponsiveGrid

Use responsive grid layouts:

```dart
ResponsiveGridView(
  children: [
    ResponsiveCard(child: Item1()),
    ResponsiveCard(child: Item2()),
    ResponsiveCard(child: Item3()),
  ],
)
```

## Key Features

### Mobile-First Design
- All components are designed mobile-first
- Progressive enhancement for larger screens
- Touch-friendly interactions

### Consistent Spacing
- Responsive padding and margins
- Consistent spacing across all screen sizes
- Automatic adjustment based on device type

### Typography Scale
- Responsive text sizes
- Consistent font weights and colors
- Optimized readability on all devices

### Grid System
- Automatic column adjustment
- Responsive spacing between items
- Flexible layouts that adapt to screen size

### Navigation
- Collapsible sidebar on mobile
- Hamburger menu for small screens
- Full sidebar on desktop

## Implementation Examples

### Basic Screen Structure

```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      showMenu: true,
      selectedIndex: 0,
      onDestinationSelected: (index) {
        // Handle navigation
      },
      title: 'My Screen',
      child: SingleChildScrollView(
        padding: ResponsivePadding.screen(context),
        child: Column(
          children: [
            ResponsiveText(
              'Welcome to My Screen',
              textType: TextType.titleLarge,
            ),
            SizedBox(height: ResponsiveBreakpoints.isMobile(context) ? 16 : 24),
            ResponsiveCard(
              child: YourContent(),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Responsive Form

```dart
Widget buildForm(BuildContext context) {
  return ResponsiveCard(
    child: ResponsiveBreakpoints.isMobile(context)
        ? Column(
            children: [
              _buildFormField(context, 'First Name'),
              const SizedBox(height: 16),
              _buildFormField(context, 'Last Name'),
            ],
          )
        : Row(
            children: [
              Expanded(child: _buildFormField(context, 'First Name')),
              const SizedBox(width: 16),
              Expanded(child: _buildFormField(context, 'Last Name')),
            ],
          ),
  );
}
```

### Responsive Statistics

```dart
Widget buildStats(BuildContext context) {
  return ResponsiveBreakpoints.isMobile(context)
      ? Column(
          children: [
            _buildStatCard(context, 'Users', '1,234'),
            const SizedBox(height: 16),
            _buildStatCard(context, 'Orders', '567'),
          ],
        )
      : Row(
          children: [
            Expanded(child: _buildStatCard(context, 'Users', '1,234')),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard(context, 'Orders', '567')),
          ],
        );
}
```

## Best Practices

1. **Always use ResponsiveLayout** as the main wrapper
2. **Use ResponsiveBreakpoints** for conditional rendering
3. **Apply ResponsivePadding** for consistent spacing
4. **Use ResponsiveText** for typography
5. **Test on multiple screen sizes** during development
6. **Consider touch targets** on mobile devices
7. **Optimize images** for different screen densities

## Migration Guide

To migrate existing screens to the responsive system:

1. Wrap your screen with `ResponsiveLayout`
2. Replace hardcoded padding with `ResponsivePadding`
3. Replace Text widgets with `ResponsiveText`
4. Use `ResponsiveCard` for consistent card styling
5. Add responsive breakpoints for different layouts
6. Test on various screen sizes

## Example Screen

See `lib/screens/examples/responsive_example_screen.dart` for a comprehensive example of all responsive features.

## Conclusion

The responsive design system ensures that the JetCV Enterprise app provides an optimal user experience across all devices. By following the guidelines and using the provided components, developers can create consistent, mobile-responsive screens that adapt beautifully to any screen size.
