import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/scheme_provider.dart';
import '../../providers/application_provider.dart';
import '../../utils/i18n.dart';
import '../../utils/theme.dart';
import '../../utils/animations.dart';
import '../../widgets/common/glass_card.dart';
import '../auth/login_screen.dart';
import 'scheme_list_screen.dart';
import '../financial/calculator_screen.dart';
import '../partners/partner_locator_screen.dart';
import '../applications/applications_screen.dart';
import '../analytics/analytics_screen.dart';
import '../compare/compare_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const _DashboardTab(),
      const SchemeListScreen(),
      const PartnerLocatorScreen(),
      const ApplicationsScreen(),
      const CalculatorScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageManager>(context);

    return Scaffold(
      body: _screens[_currentIndex],
      extendBody: true,
      bottomNavigationBar: _FloatingNav(
        currentIndex: _currentIndex,
        lang: lang,
        onChanged: (i) => setState(() => _currentIndex = i),
      ),
      drawer: _buildDrawer(context, lang),
    );
  }

  Widget _buildDrawer(BuildContext context, LanguageManager lang) {
    final auth = Provider.of<AuthProvider>(context);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // ---- Gradient user header ----
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(14),
              child: AuroraCard(
                padding: const EdgeInsets.all(18),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.purple.withOpacity(0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Center(
                        child: Text(
                          (auth.user?.name ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 19,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(auth.user?.name ?? 'User',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16)),
                    Text(auth.user?.email ?? '',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ),

            // Navigation items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  _DrawerItem(
                    icon: Icons.analytics_outlined,
                    label: lang.t('nav.analytics'),
                    colors: AppGradients.cyan,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context,
                          SlideFadeRoute(page: const AnalyticsScreen()));
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.compare_arrows_rounded,
                    label: lang.t('nav.compare'),
                    colors: AppGradients.purple,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context, SlideFadeRoute(page: const CompareScreen()));
                    },
                  ),
                  const Divider(height: 24),
                  _DrawerItem(
                    icon: Icons.logout_rounded,
                    label: lang.t('nav.logout'),
                    colors: AppGradients.red,
                    onTap: () async {
                      await auth.logout();
                      if (context.mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const LoginScreen()));
                      }
                    },
                  ),
                ],
              ),
            ),

            // Language Switcher
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Language / மொழி',
                      style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: supportedLanguages.map((option) {
                      final isActive = lang.language == option.code;
                      return GestureDetector(
                        onTap: () => lang.setLanguage(option.code),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: isActive
                                ? AppGradients.of(AppGradients.blue)
                                : null,
                            color: isActive ? null : AppColors.surface,
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(
                                color: isActive
                                    ? Colors.transparent
                                    : AppColors.border),
                          ),
                          child: Text(
                            '${option.flag} ${option.native}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isActive
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isActive
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// FLOATING FROSTED-GLASS NAVIGATION
// ═══════════════════════════════════════════════════════════════
class _FloatingNav extends StatelessWidget {
  final int currentIndex;
  final LanguageManager lang;
  final ValueChanged<int> onChanged;

  const _FloatingNav({
    required this.currentIndex,
    required this.lang,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_outlined, Icons.home_rounded, lang.t('nav.home')),
      (Icons.category_outlined, Icons.category_rounded, lang.t('nav.schemes')),
      (Icons.location_on_outlined, Icons.location_on_rounded, lang.t('nav.partners')),
      (Icons.description_outlined, Icons.description_rounded, lang.t('nav.applications')),
      (Icons.calculate_outlined, Icons.calculate_rounded, lang.t('nav.calculator')),
    ];

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        decoration: BoxDecoration(
          color: AppColors.bgDeep.withOpacity(0.78),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.45),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Padding(
              padding: const EdgeInsets.all(7),
              child: Row(
                children: List.generate(items.length, (i) {
                  final selected = i == currentIndex;
                  final icon = selected ? items[i].$2 : items[i].$1;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (!selected) {
                          HapticFeedback.selectionClick();
                          onChanged(i);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          gradient: selected
                              ? AppGradients.of(AppGradients.blue)
                              : null,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color:
                                        AppColors.royal.withOpacity(0.45),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(icon,
                                size: 19,
                                color: selected
                                    ? Colors.white
                                    : AppColors.textMuted),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 280),
                              curve: Curves.easeOutCubic,
                              child: selected
                                  ? Padding(
                                      padding:
                                          const EdgeInsets.only(left: 6),
                                      child: Text(items[i].$3,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w700)),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> colors;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                GradientIconBadge(icon: icon, colors: colors, size: 34),
                const SizedBox(width: 12),
                Text(label,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// DASHBOARD TAB
// ═══════════════════════════════════════════════════════════════
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final schemes = Provider.of<SchemeProvider>(context);
    final apps = Provider.of<ApplicationProvider>(context);
    final lang = Provider.of<LanguageManager>(context);

    // Load data
    if (schemes.schemes.isEmpty) schemes.loadSchemes();
    if (apps.applications.isEmpty) apps.loadApplications();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF101836), AppColors.bg],
          stops: [0.0, 0.4],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.blue,
          onRefresh: () async {
            await schemes.loadSchemes();
            await apps.loadApplications();
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
            children: [
              // ---- Top bar ----
              StaggerIn(
                index: 0,
                child: Row(
                  children: [
                    Builder(
                      builder: (ctx) => _MenuButton(
                          onTap: () => Scaffold.of(ctx).openDrawer()),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang.t('dashboard.greeting',
                                params: {'name': auth.user?.name ?? 'User'}),
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontSize: 20),
                          ),
                          Text(
                            lang.t('dashboard.subtitle'),
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ---- Living aurora hero ----
              StaggerIn(
                index: 1,
                child: AuroraCard(
                  padding: const EdgeInsets.all(20),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.royal.withOpacity(0.3),
                      blurRadius: 26,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.25)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome_rounded,
                                size: 13, color: Colors.white),
                            SizedBox(width: 5),
                            Text('AI POWERED',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Find the right scheme for your business',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            height: 1.25),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Smart matching with approval probability & EQI calculator',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 12, height: 1.4),
                      ),
                      const SizedBox(height: 14),
                      PressableScale(
                        pressScale: 0.96,
                        onTap: () => Navigator.push(
                            context,
                            SlideFadeRoute(
                                page: const SchemeListScreen())),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.rocket_launch_rounded,
                                  size: 16, color: AppColors.royal),
                              SizedBox(width: 8),
                              Text('Find My Scheme',
                                  style: TextStyle(
                                      color: AppColors.royal,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ---- Stat tiles (animated counters) ----
              StaggerIn(
                index: 2,
                child: Row(
                  children: [
                    _StatTile(
                      title: lang.t('dashboard.active_schemes'),
                      value: schemes.schemes.length,
                      icon: Icons.category_rounded,
                      colors: AppGradients.blue,
                    ),
                    const SizedBox(width: 12),
                    _StatTile(
                      title: lang.t('dashboard.my_applications'),
                      value: apps.applications.length,
                      icon: Icons.description_rounded,
                      colors: AppGradients.green,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // ---- Quick Actions ----
              StaggerIn(
                index: 3,
                child:
                    SectionHeader(title: lang.t('dashboard.quick_actions')),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.45,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _QuickAction(
                    index: 4,
                    title: lang.t('action.get_matched'),
                    subtitle: lang.t('action.find_best_scheme'),
                    icon: Icons.auto_awesome_rounded,
                    colors: AppGradients.indigo,
                    onTap: () => Navigator.push(context,
                        SlideFadeRoute(page: const SchemeListScreen())),
                  ),
                  _QuickAction(
                    index: 5,
                    title: lang.t('action.calculator'),
                    subtitle: lang.t('action.emi_amortization'),
                    icon: Icons.calculate_rounded,
                    colors: AppGradients.green,
                    onTap: () => Navigator.push(context,
                        SlideFadeRoute(page: const CalculatorScreen())),
                  ),
                  _QuickAction(
                    index: 6,
                    title: lang.t('action.find_partners'),
                    subtitle: lang.t('action.nearby_locations'),
                    icon: Icons.location_on_rounded,
                    colors: AppGradients.orange,
                    onTap: () => Navigator.push(context,
                        SlideFadeRoute(page: const PartnerLocatorScreen())),
                  ),
                  _QuickAction(
                    index: 7,
                    title: lang.t('action.my_applications'),
                    subtitle: lang.t('action.track_status'),
                    icon: Icons.track_changes_rounded,
                    colors: AppGradients.red,
                    onTap: () => Navigator.push(context,
                        SlideFadeRoute(page: const ApplicationsScreen())),
                  ),
                  _QuickAction(
                    index: 8,
                    title: lang.t('action.compare_schemes'),
                    subtitle: lang.t('action.side_by_side'),
                    icon: Icons.compare_arrows_rounded,
                    colors: AppGradients.purple,
                    onTap: () => Navigator.push(
                        context, SlideFadeRoute(page: const CompareScreen())),
                  ),
                  _QuickAction(
                    index: 9,
                    title: lang.t('nav.analytics'),
                    subtitle: 'Dashboard',
                    icon: Icons.analytics_rounded,
                    colors: AppGradients.cyan,
                    onTap: () => Navigator.push(context,
                        SlideFadeRoute(page: const AnalyticsScreen())),
                  ),
                ],
              ),

              // ---- Recent applications ----
              if (apps.applications.isNotEmpty) ...[
                const SizedBox(height: 24),
                StaggerIn(
                  index: 10,
                  child: SectionHeader(
                      title: lang.t('recent.applications'),
                      trailing: TextButton(
                        onPressed: () => Navigator.push(
                            context,
                            SlideFadeRoute(
                                page: const ApplicationsScreen())),
                        child: const Text('View All',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.blue)),
                      )),
                ),
                const SizedBox(height: 12),
                ...apps.applications.take(3).toList().asMap().entries.map(
                      (e) => StaggerIn(
                        index: 11 + e.key,
                        child: GlassCard(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          onTap: () => Navigator.push(
                              context,
                              SlideFadeRoute(
                                  page: const ApplicationsScreen())),
                          child: Row(
                            children: [
                              GradientIconBadge(
                                  icon: _statusIcon(e.value.status),
                                  colors: _statusColors(e.value.status),
                                  size: 38),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        e.value.schemeName ??
                                            'Scheme #${e.value.schemeId}',
                                        style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13.5),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 2),
                                    Text(e.value.statusLabel,
                                        style: const TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 12)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded,
                                  size: 18, color: AppColors.textMuted),
                            ],
                          ),
                        ),
                      ),
                    ),
              ],
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _statusColors(String status) {
    switch (status) {
      case 'approved':
        return AppGradients.green;
      case 'rejected':
        return AppGradients.red;
      case 'submitted':
        return AppGradients.blue;
      case 'under_review':
        return AppGradients.orange;
      case 'disbursed':
        return AppGradients.purple;
      default:
        return AppGradients.cyan;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'approved':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      case 'submitted':
        return Icons.send_rounded;
      case 'under_review':
        return Icons.pending_rounded;
      case 'disbursed':
        return Icons.account_balance_rounded;
      default:
        return Icons.drafts_rounded;
    }
  }
}

/// Round glass menu button.
class _MenuButton extends StatelessWidget {
  final VoidCallback onTap;
  const _MenuButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      pressScale: 0.94,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Padding(
          padding: EdgeInsets.all(11),
          child: Icon(Icons.menu_rounded,
              color: AppColors.textPrimary, size: 20),
        ),
      ),
    );
  }
}

/// Stat tile with gradient badge + counting number.
class _StatTile extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final List<Color> colors;

  const _StatTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GradientIconBadge(icon: icon, colors: colors, size: 38),
            const SizedBox(height: 10),
            AnimatedCounter(
              value: value,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800),
            ),
            Text(title,
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 11.5)),
          ],
        ),
      ),
    );
  }
}

/// Quick action glass tile with gradient badge.
class _QuickAction extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;
  final int index;

  const _QuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return StaggerIn(
      index: index,
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GradientIconBadge(icon: icon, colors: colors, size: 36),
            const SizedBox(height: 10),
            Text(title,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text(subtitle,
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 10.5),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
