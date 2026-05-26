import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:litera2/l10n/app_localizations.dart';

import '../core/app_colors.dart';
import '../providers/navigation_provider.dart';
import '../widgets/profile_avatar.dart';
import 'dashboard_page.dart';
import 'explore_page.dart';
import 'library_page.dart';
import 'profile_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    const pages = [
      DashboardPage(),
      ExplorePage(),
      LibraryPage(),
      ProfilePage(),
    ];

    return Consumer<NavigationProvider>(
      builder: (context, nav, _) {
        return Scaffold(
          extendBody: true, // Crucial for floating navbar effect
          body: IndexedStack(
            index: nav.selectedIndex,
            children: pages,
          ),
          bottomNavigationBar: _buildFloatingNavBar(context, nav, l10n, isDark, cs),
        );
      },
    );
  }

  Widget _buildFloatingNavBar(
    BuildContext context, 
    NavigationProvider nav, 
    AppLocalizations l10n, 
    bool isDark, 
    ColorScheme cs
  ) {
    return Container(
      height: 75,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 25),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navBackgroundDark : AppColors.navBackground,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.3 : 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: NavigationBar(
          selectedIndex: nav.selectedIndex,
          onDestinationSelected: nav.setIndex,
          backgroundColor: Colors.transparent,
          elevation: 0,
          indicatorColor: Colors.white.withValues(alpha: 0.15),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: l10n.dashboardTitle,
            ),
            NavigationDestination(
              icon: const Icon(Icons.explore_outlined),
              selectedIcon: const Icon(Icons.explore_rounded),
              label: l10n.exploreTitle,
            ),
            NavigationDestination(
              icon: const Icon(Icons.bookmark_outline_rounded),
              selectedIcon: const Icon(Icons.bookmark_rounded),
              label: l10n.myCollection,
            ),
            NavigationDestination(
              icon: const Padding(
                padding: EdgeInsets.all(2),
                child: SmallProfileAvatar(radius: 11),
              ),
              selectedIcon: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const SmallProfileAvatar(radius: 11),
              ),
              label: l10n.profileTitle,
            ),
          ],
        ),
      ),
    );
  }
}
