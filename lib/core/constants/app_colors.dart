import 'package:flutter/material.dart';

/// Design tokens extracted from the Stitch project (ID: 12152695354512754997)
/// Fonts: Manrope (body/headlines) + JetBrains Mono (labels/currency)
/// Color system: Material 3 teal-based palette
class AppColors {
  AppColors._();

  // ─── Light Mode Colors ──────────────────────────────────────────────────────
  static const Color lightPrimary = Color(0xFF00685F);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFF008378);
  static const Color lightOnPrimaryContainer = Color(0xFFF4FFFC);
  static const Color lightPrimaryFixed = Color(0xFF89F5E7);
  static const Color lightPrimaryFixedDim = Color(0xFF6BD8CB);
  static const Color lightInversePrimary = Color(0xFF6BD8CB);

  static const Color lightSecondary = Color(0xFF006A63);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightSecondaryContainer = Color(0xFF99EFE5);
  static const Color lightOnSecondaryContainer = Color(0xFF006F67);
  static const Color lightSecondaryFixed = Color(0xFF9CF2E8);
  static const Color lightSecondaryFixedDim = Color(0xFF80D5CB);

  static const Color lightTertiary = Color(0xFF00685C);
  static const Color lightOnTertiary = Color(0xFFFFFFFF);
  static const Color lightTertiaryContainer = Color(0xFF008375);
  static const Color lightOnTertiaryContainer = Color(0xFFF4FFFB);

  static const Color lightError = Color(0xFFBA1A1A);
  static const Color lightOnError = Color(0xFFFFFFFF);
  static const Color lightErrorContainer = Color(0xFFFFDAD6);
  static const Color lightOnErrorContainer = Color(0xFF93000A);

  static const Color lightBackground = Color(0xFFFAF8FF);
  static const Color lightOnBackground = Color(0xFF131B2E);
  static const Color lightSurface = Color(0xFFFAF8FF);
  static const Color lightOnSurface = Color(0xFF131B2E);
  static const Color lightSurfaceVariant = Color(0xFFDAE2FD);
  static const Color lightOnSurfaceVariant = Color(0xFF3D4947);
  static const Color lightSurfaceTint = Color(0xFF006A61);
  static const Color lightInverseSurface = Color(0xFF283044);
  static const Color lightInverseOnSurface = Color(0xFFEEF0FF);

  static const Color lightSurfaceBright = Color(0xFFFAF8FF);
  static const Color lightSurfaceDim = Color(0xFFD2D9F4);
  static const Color lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainerLow = Color(0xFFF2F3FF);
  static const Color lightSurfaceContainer = Color(0xFFEAEDFF);
  static const Color lightSurfaceContainerHigh = Color(0xFFE2E7FF);
  static const Color lightSurfaceContainerHighest = Color(0xFFDAE2FD);

  static const Color lightOutline = Color(0xFF6D7A77);
  static const Color lightOutlineVariant = Color(0xFFBCC9C6);

  // ─── Dark Mode Colors ───────────────────────────────────────────────────────
  static const Color darkPrimary = Color(0xFF4FDBC8);
  static const Color darkOnPrimary = Color(0xFF003731);
  static const Color darkPrimaryContainer = Color(0xFF14B8A6);
  static const Color darkOnPrimaryContainer = Color(0xFF00423B);
  static const Color darkPrimaryFixed = Color(0xFF71F8E4);
  static const Color darkPrimaryFixedDim = Color(0xFF4FDBC8);
  static const Color darkInversePrimary = Color(0xFF006B5F);

  static const Color darkSecondary = Color(0xFF44E2CD);
  static const Color darkOnSecondary = Color(0xFF003731);
  static const Color darkSecondaryContainer = Color(0xFF03C6B2);
  static const Color darkOnSecondaryContainer = Color(0xFF004D44);
  static const Color darkSecondaryFixed = Color(0xFF62FAE3);
  static const Color darkSecondaryFixedDim = Color(0xFF3CDDC7);

  static const Color darkTertiary = Color(0xFFFFB95F);
  static const Color darkOnTertiary = Color(0xFF472A00);
  static const Color darkTertiaryContainer = Color(0xFFE49200);
  static const Color darkOnTertiaryContainer = Color(0xFF543300);

  static const Color darkError = Color(0xFFFFB4AB);
  static const Color darkOnError = Color(0xFF690005);
  static const Color darkErrorContainer = Color(0xFF93000A);
  static const Color darkOnErrorContainer = Color(0xFFFFDAD6);

  static const Color darkBackground = Color(0xFF0B1326);
  static const Color darkOnBackground = Color(0xFFDAE2FD);
  static const Color darkSurface = Color(0xFF0B1326);
  static const Color darkOnSurface = Color(0xFFDAE2FD);
  static const Color darkSurfaceVariant = Color(0xFF2D3449);
  static const Color darkOnSurfaceVariant = Color(0xFFBBCAC6);
  static const Color darkSurfaceTint = Color(0xFF4FDBC8);
  static const Color darkInverseSurface = Color(0xFFDAE2FD);
  static const Color darkInverseOnSurface = Color(0xFF283044);

  static const Color darkSurfaceBright = Color(0xFF31394D);
  static const Color darkSurfaceDim = Color(0xFF0B1326);
  static const Color darkSurfaceContainerLowest = Color(0xFF060E20);
  static const Color darkSurfaceContainerLow = Color(0xFF131B2E);
  static const Color darkSurfaceContainer = Color(0xFF171F33);
  static const Color darkSurfaceContainerHigh = Color(0xFF222A3D);
  static const Color darkSurfaceContainerHighest = Color(0xFF2D3449);

  static const Color darkOutline = Color(0xFF859490);
  static const Color darkOutlineVariant = Color(0xFF3C4947);

  // ─── Category Colors ────────────────────────────────────────────────────────
  static const Color categoryFood = Color(0xFFF97316);      // orange-500
  static const Color categoryFoodBg = Color(0x1AF97316);
  static const Color categoryTransport = Color(0xFF3B82F6); // blue-500
  static const Color categoryTransportBg = Color(0x1A3B82F6);
  static const Color categoryShopping = Color(0xFFA855F7);  // purple-500
  static const Color categoryShoppingBg = Color(0x1AA855F7);
  static const Color categoryBills = Color(0xFFF43F5E);     // rose-500
  static const Color categoryBillsBg = Color(0x1AF43F5E);
  static const Color categoryEntertainment = Color(0xFFF59E0B); // amber-500
  static const Color categoryEntertainmentBg = Color(0x1AF59E0B);
  static const Color categoryHealth = Color(0xFF22C55E);    // green-500
  static const Color categoryHealthBg = Color(0x1A22C55E);
  static const Color categoryEducation = Color(0xFF06B6D4); // cyan-500
  static const Color categoryEducationBg = Color(0x1A06B6D4);
  static const Color categoryOther = Color(0xFF8B5CF6);     // violet-500
  static const Color categoryOtherBg = Color(0x1A8B5CF6);

  // ─── Functional Colors ──────────────────────────────────────────────────────
  static const Color incomeGreen = Color(0xFF10B981);
  static const Color expenseRed = Color(0xFFEF4444);
}
