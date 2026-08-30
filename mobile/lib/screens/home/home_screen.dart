import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/scheme_provider.dart';
import '../../providers/partner_provider.dart';
import '../../providers/application_provider.dart';
import '../auth/login_screen.dart';
import 'dashboard_screen.dart';
import '../financial/calculator_screen.dart';
import '../partners/partner_locator_screen.dart';
import '../applications/applications_screen.dart';
import '../home/scheme_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _DashboardTab(),
    const SchemeListScreen(),
    const PartnerLocatorScreen(),
    const ApplicationsScreen(),
    const CalculatorScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.category), label: 'Schemes'),
          NavigationDestination(icon: Icon(Icons.location_on), label: 'Partners'),
          NavigationDestination(icon: Icon(Icons.description), label: 'Apps'),
          NavigationDestination(icon: Icon(Icons.calculate), label: 'Calc'),
        ],
      ),
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
            // Greeting
            Text(
              'Welcome, ${auth.user?.name ?? 'User'}!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Find schemes, calculate loans, and track applications',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),

            // Stats cards
            Row(
              children: [
                _StatCard(
                  title: 'Schemes',
                  value: '${schemes.schemes.length}',
                  icon: Icons.category,
                  color: Colors.blue,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  title: 'Applications',
                  value: '${apps.applications.length}',
                  icon: Icons.description,
                  color: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Quick Actions
            Text('Quick Actions', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
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
                  title: 'Get Matched',
                  subtitle: 'Find best scheme',
                  icon: Icons.auto_awesome,
                  color: const Color(0xFF6366F1),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SchemeListScreen())),
                ),
                _QuickAction(
                  title: 'Calculator',
                  subtitle: 'EMI & amortization',
                  icon: Icons.calculate,
                  color: const Color(0xFF10B981),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalculatorScreen())),
                ),
                _QuickAction(
                  title: 'Find Partners',
                  subtitle: 'Nearby locations',
                  icon: Icons.location_on,
                  color: const Color(0xFFF59E0B),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PartnerLocatorScreen())),
                ),
                _QuickAction(
                  title: 'My Applications',
                  subtitle: 'Track status',
                  icon: Icons.track_changes,
                  color: const Color(0xFFEF4444),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ApplicationsScreen())),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent applications
            if (apps.applications.isNotEmpty) ...[
              Text('Recent Applications', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
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
              label: const Text('Logout'),
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
