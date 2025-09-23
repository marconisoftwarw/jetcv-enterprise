import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'responsive_layout.dart';

/// A responsive card widget that adapts to different screen sizes
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final double? elevation;
  final bool enableResponsivePadding;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.boxShadow,
    this.border,
    this.elevation,
    this.enableResponsivePadding = true,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);
    final isTablet = ResponsiveBreakpoints.isTablet(context);
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);

    return Container(
      margin: margin ?? EdgeInsets.zero,
      padding: enableResponsivePadding
          ? padding ?? ResponsivePadding.card(context)
          : padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.pureWhite,
        borderRadius:
            borderRadius ?? BorderRadius.circular(ResponsiveBreakpoints.isMobile(context) ? 12 : 16),
        boxShadow:
            boxShadow ?? _getDefaultShadow(isMobile, isTablet, isDesktop),
        border: border ?? Border.all(color: AppTheme.borderGray, width: 1),
      ),
      child: child,
    );
  }

  List<BoxShadow> _getDefaultShadow(
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    if (isMobile) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 4,
          spreadRadius: 0,
          offset: const Offset(0, 2),
        ),
      ];
    } else if (isTablet) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 8,
          spreadRadius: 0,
          offset: const Offset(0, 4),
        ),
      ];
    } else {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 12,
          spreadRadius: 0,
          offset: const Offset(0, 6),
        ),
      ];
    }
  }
}

/// A responsive grid view that adapts to different screen sizes
class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final int? maxColumns;
  final double? childAspectRatio;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;

  const ResponsiveGridView({
    super.key,
    required this.children,
    this.maxColumns,
    this.childAspectRatio,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
    this.padding,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final columns = maxColumns ?? ResponsiveGrid.getColumns(context);
    final aspectRatio =
        childAspectRatio ?? ResponsiveGrid.getChildAspectRatio(context);
    final crossSpacing =
        crossAxisSpacing ?? ResponsiveGrid.getCrossAxisSpacing(context);
    final mainSpacing =
        mainAxisSpacing ?? ResponsiveGrid.getMainAxisSpacing(context);

    return GridView.builder(
      padding: padding ?? ResponsivePadding.screen(context),
      physics: physics,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: crossSpacing,
        mainAxisSpacing: mainSpacing,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// A responsive list view that adapts to different screen sizes
class ResponsiveListView extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final Axis scrollDirection;

  const ResponsiveListView({
    super.key,
    required this.children,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.scrollDirection = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: padding ?? ResponsivePadding.screen(context),
      physics: physics,
      shrinkWrap: shrinkWrap,
      scrollDirection: scrollDirection,
      children: children,
    );
  }
}

/// A responsive container that adapts to different screen sizes
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final Alignment? alignment;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.boxShadow,
    this.border,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    final containerMaxWidth =
        maxWidth ?? (ResponsiveBreakpoints.isMobile(context) ? double.infinity : (ResponsiveBreakpoints.isTablet(context) ? 600 : 800));
    final containerPadding = padding ?? ResponsivePadding.screen(context);
    final containerBorderRadius =
        borderRadius ?? BorderRadius.circular(ResponsiveBreakpoints.isMobile(context) ? 12 : 16);

    return Container(
      margin: margin,
      padding: containerPadding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: containerBorderRadius,
        boxShadow: boxShadow,
        border: border,
      ),
      alignment: alignment,
      constraints: BoxConstraints(maxWidth: containerMaxWidth),
      child: child,
    );
  }
}

