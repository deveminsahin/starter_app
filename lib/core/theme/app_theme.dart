import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:starter_app/core/constants/ui/border_radius_constants.dart';
import 'package:starter_app/core/constants/ui/navigation_constants.dart';
import 'package:starter_app/core/theme/color_palette.dart';
import 'package:starter_app/core/theme/text_styles.dart';
import 'package:starter_app/core/theme/theme_extensions.dart';

/// Application theme configuration using FlexColorScheme and Material Design 3.
///
/// Provides centralized theme management with light and dark theme support.
/// Follows Material Design 3 guidelines and integrates with the app's
/// color palette and typography system.
@singleton
class AppTheme {
  const AppTheme();

  // ==================== Theme Generation ====================

  /// Light theme configuration
  ThemeData get lightTheme {
    return FlexThemeData.light(
      // Color scheme
      colors: const FlexSchemeColor(
        primary: AppColorPalette.primaryLight,
        primaryContainer: AppColorPalette.primaryContainerLight,
        secondary: AppColorPalette.secondaryLight,
        secondaryContainer: AppColorPalette.secondaryContainerLight,
        tertiary: AppColorPalette.tertiaryLight,
        tertiaryContainer: AppColorPalette.tertiaryContainerLight,
        appBarColor: AppColorPalette.surfaceLight,
        error: AppColorPalette.error,
      ),

      // Surface and background configuration
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 7,

      // App bar styling
      appBarOpacity: 0.95,
      appBarElevation: 0,

      // Component themes
      subThemesData: const FlexSubThemesData(
        // Use Material 3
        interactionEffects: true,
        tintedDisabledControls: true,

        // Input decoration
        inputDecoratorRadius: BorderRadiusConstants.medium,
        inputDecoratorSchemeColor: SchemeColor.primary,
        inputDecoratorIsFilled: true,
        inputDecoratorFillColor: AppColorPalette.inputBackgroundLight,
        inputDecoratorBorderType: FlexInputBorderType.outline,

        // Button styling
        elevatedButtonRadius: BorderRadiusConstants.large,
        elevatedButtonSchemeColor: SchemeColor.primary,

        filledButtonRadius: BorderRadiusConstants.large,
        filledButtonSchemeColor: SchemeColor.primary,

        outlinedButtonRadius: BorderRadiusConstants.large,
        outlinedButtonOutlineSchemeColor: SchemeColor.outline,

        textButtonRadius: BorderRadiusConstants.large,

        // Card styling
        cardRadius: BorderRadiusConstants.medium,
        cardElevation: 1,

        // Chip styling
        chipRadius: BorderRadiusConstants.small,
        chipSchemeColor: SchemeColor.primaryContainer,

        // Dialog styling
        dialogRadius: BorderRadiusConstants.xLarge,
        dialogElevation: 6,

        // Navigation bar styling
        navigationBarHeight: NavigationConstants.bottomNavHeight,
        navigationBarIndicatorRadius: BorderRadiusConstants.large,
        navigationBarIndicatorSchemeColor: SchemeColor.secondaryContainer,
        navigationBarSelectedIconSchemeColor: SchemeColor.onSecondaryContainer,
        navigationBarSelectedLabelSchemeColor: SchemeColor.onSurface,

        // Navigation rail styling
        navigationRailIndicatorRadius: BorderRadiusConstants.large,
        navigationRailIndicatorSchemeColor: SchemeColor.secondaryContainer,
        navigationRailSelectedIconSchemeColor: SchemeColor.onSecondaryContainer,

        drawerRadius: 0,

        // FAB styling
        fabRadius: BorderRadiusConstants.large,
        fabUseShape: true,
        fabSchemeColor: SchemeColor.primaryContainer,
      ),

      // Visual density
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      textTheme: AppTextStyles.getTextTheme(),
      primaryTextTheme: AppTextStyles.getTextTheme(),

      // Extensions
      extensions: <ThemeExtension<dynamic>>[
        SemanticColors.light(),
      ],
    ).copyWith(
      // System UI overlay style
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
    );
  }

  /// Dark theme configuration
  ThemeData get darkTheme {
    return FlexThemeData.dark(
      // Color scheme
      colors: const FlexSchemeColor(
        primary: AppColorPalette.primaryDark,
        primaryContainer: AppColorPalette.primaryContainerDark,
        secondary: AppColorPalette.secondaryDark,
        secondaryContainer: AppColorPalette.secondaryContainerDark,
        tertiary: AppColorPalette.tertiaryDark,
        tertiaryContainer: AppColorPalette.tertiaryContainerDark,
        appBarColor: AppColorPalette.surfaceDark,
        error: AppColorPalette.errorLight,
      ),

      // Surface and background configuration
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 13,

      // App bar styling
      appBarOpacity: 0.95,
      appBarElevation: 0,

      // Component themes
      subThemesData: const FlexSubThemesData(
        // Use Material 3
        interactionEffects: true,
        tintedDisabledControls: true,

        // Input decoration
        inputDecoratorRadius: BorderRadiusConstants.medium,
        inputDecoratorSchemeColor: SchemeColor.primary,
        inputDecoratorIsFilled: true,
        inputDecoratorFillColor: AppColorPalette.inputBackgroundDark,
        inputDecoratorBorderType: FlexInputBorderType.outline,

        // Button styling
        elevatedButtonRadius: BorderRadiusConstants.large,
        elevatedButtonSchemeColor: SchemeColor.primary,

        filledButtonRadius: BorderRadiusConstants.large,
        filledButtonSchemeColor: SchemeColor.primary,

        outlinedButtonRadius: BorderRadiusConstants.large,
        outlinedButtonOutlineSchemeColor: SchemeColor.outline,

        textButtonRadius: BorderRadiusConstants.large,

        // Card styling
        cardRadius: BorderRadiusConstants.medium,
        cardElevation: 1,

        // Chip styling
        chipRadius: BorderRadiusConstants.small,
        chipSchemeColor: SchemeColor.primaryContainer,

        // Dialog styling
        dialogRadius: BorderRadiusConstants.xLarge,
        dialogElevation: 6,

        drawerRadius: 0,

        // Navigation bar styling
        navigationBarHeight: NavigationConstants.bottomNavHeight,
        navigationBarIndicatorRadius: BorderRadiusConstants.large,
        navigationBarIndicatorSchemeColor: SchemeColor.secondaryContainer,
        navigationBarSelectedIconSchemeColor: SchemeColor.onSecondaryContainer,
        navigationBarSelectedLabelSchemeColor: SchemeColor.onSurface,

        // Navigation rail styling
        navigationRailIndicatorRadius: BorderRadiusConstants.large,
        navigationRailIndicatorSchemeColor: SchemeColor.secondaryContainer,
        navigationRailSelectedIconSchemeColor: SchemeColor.onSecondaryContainer,

        // FAB styling
        fabRadius: BorderRadiusConstants.large,
        fabUseShape: true,
        fabSchemeColor: SchemeColor.primaryContainer,
      ),

      // Visual density
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      textTheme: AppTextStyles.getTextTheme(),
      primaryTextTheme: AppTextStyles.getTextTheme(),

      // Extensions
      extensions: <ThemeExtension<dynamic>>[
        SemanticColors.dark(),
      ],
    ).copyWith(
      // System UI overlay style
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
    );
  }
}
