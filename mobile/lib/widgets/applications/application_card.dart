import 'package:flutter/material.dart';
import '../../models/application.dart';
import '../common/status_badge.dart';

class ApplicationCard extends StatelessWidget {
  final Application application;
  final VoidCallback? onTap;

  const ApplicationCard({super.key, required this.application, this.onTap});

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
                    backgroundColor: StatusBadge.fromStatus(application.status).color?.withOpacity(0.1),
                    child: Icon(_statusIcon(application.status), color: StatusBadge.fromStatus(application.status).color, size: 20),
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
                  StatusBadge.fromStatus(application.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (application.projectType != null) ...[
                    _InfoTag(label: application.projectType!),
                    const SizedBox(width: 8),
                  ],
                  if (application.loanAmountFormatted != null)
                    _InfoTag(label: application.loanAmountFormatted!),
                ],
              ),
              if (application.status != 'draft') ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: _statusProgress(application.status),
                        backgroundColor: Colors.grey[200],
                        color: StatusBadge.fromStatus(application.status).color,
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${_progressStep(application.status)}/9', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
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
      case 'draft': return 0.11;
      case 'submitted': return 0.22;
      case 'under_review': return 0.55;
      case 'approved': return 0.77;
      case 'rejected': return 0.55;
      case 'disbursed': return 1.0;
      default: return 0.0;
    }
  }

  int _progressStep(String status) {
    switch (status) {
      case 'draft': return 1;
      case 'submitted': return 2;
      case 'under_review': return 5;
      case 'approved': return 7;
      case 'rejected': return 5;
      case 'disbursed': return 9;
      default: return 0;
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
