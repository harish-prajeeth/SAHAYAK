import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/application_provider.dart';
import '../../models/application.dart';
import '../../utils/theme.dart';
import '../../widgets/common/glass_card.dart';
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

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF101836), AppColors.bg],
          stops: [0.0, 0.35],
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('My Applications',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800)),
                  SizedBox(height: 2),
                  Text('Track your loan journey end-to-end',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            Expanded(
              child: provider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.blue))
                  : provider.applications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.description_outlined,
                                  size: 56,
                                  color: AppColors.textMuted.withOpacity(0.5)),
                              const SizedBox(height: 12),
                              const Text('No applications yet',
                                  style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14)),
                              const SizedBox(height: 4),
                              const Text(
                                  'Submit an application to start tracking',
                                  style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 12)),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          color: AppColors.blue,
                          onRefresh: () => provider.loadApplications(),
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                            itemCount: provider.applications.length,
                            itemBuilder: (context, index) {
                              final app = provider.applications[index];
                              return _ApplicationCard(
                                application: app,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          ApplicationDetailScreen(application: app)),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
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
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GradientIconBadge(
                  icon: _statusIcon(application.status),
                  colors: _statusColors(application.status),
                  size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(application.schemeName ?? 'Application #${application.id}',
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    if (application.partnerName != null)
                      Text(application.partnerName!,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textMuted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(application.status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color:
                          _statusColor(application.status).withOpacity(0.35)),
                ),
                child: Text(application.statusLabel,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _statusColor(application.status))),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Details row
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (application.projectType != null)
                _InfoTag(label: application.projectType!),
              if (application.loanAmountFormatted != null)
                _InfoTag(label: application.loanAmountFormatted!),
              if (application.projectCostFormatted != null)
                _InfoTag(label: application.projectCostFormatted!),
            ],
          ),

          // Progress bar
          if (application.status != 'draft') ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _statusProgress(application.status),
                      backgroundColor: AppColors.surface,
                      color: _statusColor(application.status),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(_statusProgressLabel(application.status),
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted)),
              ],
            ),
          ],
        ],
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
      case 'approved': return AppColors.green;
      case 'rejected': return AppColors.red;
      case 'submitted': return AppColors.blue;
      case 'under_review': return AppColors.orange;
      case 'disbursed': return AppColors.purple;
      default: return AppColors.cyan;
    }
  }

  List<Color> _statusColors(String status) {
    switch (status) {
      case 'approved': return AppGradients.green;
      case 'rejected': return AppGradients.red;
      case 'submitted': return AppGradients.blue;
      case 'under_review': return AppGradients.orange;
      case 'disbursed': return AppGradients.purple;
      default: return AppGradients.cyan;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'approved': return Icons.check_circle_rounded;
      case 'rejected': return Icons.cancel_rounded;
      case 'submitted': return Icons.send_rounded;
      case 'under_review': return Icons.pending_rounded;
      case 'disbursed': return Icons.account_balance_rounded;
      default: return Icons.drafts_rounded;
    }
  }
}

class _InfoTag extends StatelessWidget {
  final String label;
  const _InfoTag({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 11, color: AppColors.textSecondary)),
    );
  }
}
