import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/scheme_provider.dart';
import '../../providers/application_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final schemes = Provider.of<SchemeProvider>(context);
    final apps = Provider.of<ApplicationProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: RefreshIndicator(
        onRefresh: () async {
          await schemes.loadSchemes();
          await apps.loadApplications();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Stats
            Row(
              children: [
                Expanded(child: _StatCard(title: 'Schemes', value: '${schemes.schemes.length}', icon: Icons.category, color: Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(title: 'Applications', value: '${apps.applications.length}', icon: Icons.description, color: Colors.green)),
              ],
            ),
            const SizedBox(height: 20),

            // Quick actions
            Text('Quick Actions', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _ActionCard(
              title: 'Get Scheme Recommendation',
              subtitle: 'Find the best scheme for your needs',
              icon: Icons.auto_awesome,
              color: const Color(0xFF6366F1),
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _ActionCard(
              title: 'Calculate Loan EMI',
              subtitle: 'EMI calculator with moratorium',
              icon: Icons.calculate,
              color: const Color(0xFF10B981),
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _ActionCard(
              title: 'Find Nearby Partners',
              subtitle: 'Locate SCAs, PSBs, RRBs near you',
              icon: Icons.location_on,
              color: const Color(0xFFF59E0B),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.title, required this.value, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionCard({required this.title, required this.subtitle, required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
