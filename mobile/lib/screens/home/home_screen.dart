import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/scheme_provider.dart';
import '../../providers/partner_provider.dart';
import '../../providers/application_provider.dart';
import '../../utils/i18n.dart';
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home), label: lang.t('nav.home')),
          NavigationDestination(icon: const Icon(Icons.category), label: lang.t('nav.schemes')),
          NavigationDestination(icon: const Icon(Icons.location_on), label: lang.t('nav.partners')),
          NavigationDestination(icon: const Icon(Icons.description), label: lang.t('nav.applications')),
          NavigationDestination(icon: const Icon(Icons.calculate), label: lang.t('nav.calculator')),
        ],
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
            // User info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    child: Text(
                      (auth.user?.name ?? 'U')[0],
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(auth.user?.name ?? 'User',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(auth.user?.email ?? '',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),

            // Navigation items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _DrawerItem(
                    icon: Icons.analytics,
                    label: lang.t('nav.analytics'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen()));
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.compare_arrows,
                    label: lang.t('nav.compare'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CompareScreen()));
                    },
                  ),
                  const Divider(),
                  _DrawerItem(
                    icon: Icons.logout,
                    label: lang.t('nav.logout'),
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
                  Text('Language / மொழி', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: supportedLanguages.map((option) {
                      final isActive = lang.language == option.code;
                      return GestureDetector(
                        onTap: () => lang.setLanguage(option.code),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isActive
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${option.flag} ${option.native}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                              color: isActive ? Colors.white : Theme.of(context).colorScheme.primary,
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

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 22),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      onTap: onTap,
      dense: true,
    );
  }
}

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

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await schemes.loadSchemes();
          await apps.loadApplications();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Hamburger menu hint
            Row(
              children: [
                Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                ),
                Expanded(
                  child: Text(
                    lang.t('dashboard.greeting', params: {'name': auth.user?.name ?? 'User'}),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 48),
              child: Text(
                lang.t('dashboard.subtitle'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 20),

            // Stats cards
            Row(
              children: [
                _StatCard(
                  title: lang.t('dashboard.active_schemes'),
                  value: '${schemes.schemes.length}',
                  icon: Icons.category,
                  color: Colors.blue,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  title: lang.t('dashboard.my_applications'),
                  value: '${apps.applications.length}',
                  icon: Icons.description,
                  color: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Quick Actions
            Text(lang.t('dashboard.quick_actions'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.5,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _QuickAction(
                  title: lang.t('action.get_matched'),
                  subtitle: lang.t('action.find_best_scheme'),
                  icon: Icons.auto_awesome,
                  color: const Color(0xFF6366F1),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SchemeListScreen())),
                ),
                _QuickAction(
                  title: lang.t('action.calculator'),
                  subtitle: lang.t('action.emi_amortization'),
                  icon: Icons.calculate,
                  color: const Color(0xFF10B981),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalculatorScreen())),
                ),
                _QuickAction(
                  title: lang.t('action.find_partners'),
                  subtitle: lang.t('action.nearby_locations'),
                  icon: Icons.location_on,
                  color: const Color(0xFFF59E0B),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PartnerLocatorScreen())),
                ),
                _QuickAction(
                  title: lang.t('action.my_applications'),
                  subtitle: lang.t('action.track_status'),
                  icon: Icons.track_changes,
                  color: const Color(0xFFEF4444),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ApplicationsScreen())),
                ),
                _QuickAction(
                  title: lang.t('action.compare_schemes'),
                  subtitle: lang.t('action.side_by_side'),
                  icon: Icons.compare_arrows,
                  color: const Color(0xFF8B5CF6),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CompareScreen())),
                ),
                _QuickAction(
                  title: lang.t('nav.analytics'),
                  subtitle: 'Dashboard',
                  icon: Icons.analytics,
                  color: const Color(0xFF0EA5E9),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen())),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent applications
            if (apps.applications.isNotEmpty) ...[
              Text(lang.t('recent.applications'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...apps.applications.take(3).map((app) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _statusColor(app.status).withOpacity(0.1),
                    child: Icon(_statusIcon(app.status), color: _statusColor(app.status), size: 20),
                  ),
                  title: Text(app.schemeName ?? 'Scheme #${app.schemeId}'),
                  subtitle: Text(app.statusLabel),
                  trailing: const Icon(Icons.chevron_right),
                ),
              )),
            ],

            // Logout
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () async {
                await auth.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
                }
              },
              icon: const Icon(Icons.logout),
              label: Text(lang.t('nav.logout')),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved': return Colors.green;
      case 'rejected': return Colors.red;
      case 'submitted': return Colors.blue;
      case 'under_review': return Colors.orange;
      case 'disbursed': return Colors.purple;
      default: return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'approved': return Icons.check_circle;
      case 'rejected': return Icons.cancel;
      case 'submitted': return Icons.send;
      case 'under_review': return Icons.pending;
      case 'disbursed': return Icons.account_balance;
      default: return Icons.drafts;
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({required this.title, required this.subtitle, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }
}
