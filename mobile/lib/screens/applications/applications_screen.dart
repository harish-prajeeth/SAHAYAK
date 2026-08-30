import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/application_provider.dart';
import '../../models/application.dart';
import 'application_detail_screen.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});
  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ApplicationProvider>(context, listen: false);
    if (provider.applications.isEmpty) provider.loadApplications();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ApplicationProvider>(context);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('My Applications', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.applications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.description_outlined, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 12),
                            Text('No applications yet', style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => provider.loadApplications(),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: provider.applications.length,
                          itemBuilder: (context, index) {
                            final app = provider.applications[index];
                            return _ApplicationCard(
                              application: app,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => ApplicationDetailScreen(application: app)),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final Application application;
  final VoidCallback onTap;
  const _ApplicationCard({required this.application, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _statusColor(application.status).withOpacity(0.1),
                    child: Icon(_statusIcon(application.status), color: _statusColor(application.status), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(application.schemeName ?? 'Application #${application.id}',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        if (application.partnerName != null)
                          Text(application.partnerName!, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(application.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(application.statusLabel,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _statusColor(application.status))),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Details row
              Row(
                children: [
                  if (application.projectType != null)
                    _InfoTag(label: application.projectType!),
                  if (application.loanAmountFormatted != null) ...[
                    const SizedBox(width: 8),
                    _InfoTag(label: application.loanAmountFormatted!),
                  ],
                  if (application.projectCostFormatted != null) ...[
                    const SizedBox(width: 8),
                    _InfoTag(label: application.projectCostFormatted!),
                  ],
                ],
              ),

              // Progress bar
              if (application.status != 'draft') ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: _statusProgress(application.status),
                        backgroundColor: Colors.grey[200],
                        color: _statusColor(application.status),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(_statusProgressLabel(application.status), style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  double _statusProgress(String status) {
    switch (status) {
      case 'draft': return 0.1;
      case 'submitted': return 0.3;
      case 'under_review': return 0.5;
      case 'approved': return 0.7;
      case 'rejected': return 0.5;
      case 'disbursed': return 1.0;
      default: return 0.0;
    }
  }

  String _statusProgressLabel(String status) {
    switch (status) {
      case 'draft': return '1/9';
      case 'submitted': return '2/9';
      case 'under_review': return '5/9';
      case 'approved': return '7/9';
      case 'rejected': return 'Stopped';
      case 'disbursed': return '9/9';
      default: return '';
    }
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

class _InfoTag extends StatelessWidget {
  final String label;
  const _InfoTag({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: const TextStyle(fontSize: 11)),
    );
  }
}
