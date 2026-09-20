import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/application_provider.dart';
import '../../models/application.dart';
import '../../utils/theme.dart';
import '../../widgets/common/glass_card.dart';

class ApplicationDetailScreen extends StatefulWidget {
  final Application application;
  const ApplicationDetailScreen({super.key, required this.application});
  @override
  State<ApplicationDetailScreen> createState() => _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ApplicationProvider>(context, listen: false);
    provider.getApplicationStatus(widget.application.id);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ApplicationProvider>(context);
    final app = widget.application;

    return Scaffold(
      appBar: AppBar(
        title: Text('Application #${app.id}'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _statusColor(app.status).withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _statusColor(app.status).withOpacity(0.4)),
            ),
            child: Text(app.statusLabel,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: _statusColor(app.status))),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.blue,
        onRefresh: () => provider.getApplicationStatus(app.id),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Application info card
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GradientIconBadge(
                          icon: Icons.description_rounded,
                          colors: AppGradients.blue,
                          size: 38),
                      const SizedBox(width: 12),
                      const Text('Application Details',
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _InfoRow(label: 'Scheme', value: app.schemeName ?? 'N/A'),
                  _InfoRow(label: 'Project Type', value: app.projectType ?? 'N/A'),
                  _InfoRow(label: 'Project Cost', value: app.projectCostFormatted ?? 'N/A'),
                  _InfoRow(label: 'Loan Amount', value: app.loanAmountFormatted ?? 'N/A'),
                  _InfoRow(label: 'Partner', value: app.partnerName ?? 'N/A'),
                  _InfoRow(label: 'Created', value: app.createdAt.toString().substring(0, 16)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 9-Step Disbursement Chain
            GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Disbursement Chain',
                            style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 16)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.blue.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.blue.withOpacity(0.35)),
                          ),
                          child: Text('${_completedStages(provider.disbursementStages)}/9',
                              style: const TextStyle(
                                  color: AppColors.blue,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    ..._buildDisbursementTimeline(context, provider.disbursementStages),
                  ],
                ),
              ),
            ),

            // Rejection info (if applicable)
            if (app.status == 'rejected') ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.red.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [
                      Icon(Icons.error_rounded, color: AppColors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Rejection Details',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.red,
                              fontSize: 15)),
                    ]),
                    const SizedBox(height: 12),
                    if (app.rejectionCategory != null)
                      _InfoRow(label: 'Category', value: app.rejectionCategory!.toUpperCase()),
                    if (app.rejectionReason != null)
                      Text(app.rejectionReason!,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
                    if (app.remediationSteps != null) ...[
                      const SizedBox(height: 12),
                      const Text('Remediation Steps:',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text(app.remediationSteps!,
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.5)),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  int _completedStages(List<DisbursementStage> stages) {
    return stages.where((s) => s.completed).length;
  }

  List<Widget> _buildDisbursementTimeline(BuildContext context, List<DisbursementStage> fetchedStages) {
    final chainSteps = DisbursementStage.chainSteps;

    return List.generate(chainSteps.length, (index) {
      final step = chainSteps[index];
      final fetchedStage = fetchedStages.isNotEmpty && index < fetchedStages.length ? fetchedStages[index] : null;
      final isCompleted = fetchedStage?.completed ?? false;
      final isCurrent = fetchedStage?.current ?? false;
      final isLast = index == chainSteps.length - 1;

      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline connector
            SizedBox(
              width: 40,
              child: Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? AppColors.green
                          : isCurrent
                              ? AppColors.blue
                              : AppColors.surface,
                      border: Border.all(
                          color: isCompleted
                              ? Colors.transparent
                              : isCurrent
                                  ? Colors.transparent
                                  : AppColors.border,
                          width: 1.5),
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                  color: AppColors.blue.withOpacity(0.5),
                                  blurRadius: 10)
                            ]
                          : null,
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 15)
                        : isCurrent
                            ? const SizedBox(
                                width: 12, height: 12,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text('${index + 1}',
                                style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: isCompleted
                            ? AppColors.green.withOpacity(0.4)
                            : AppColors.border,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Step info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step['name']!,
                      style: TextStyle(
                        fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
                        color: isCompleted
                            ? AppColors.green
                            : isCurrent
                                ? AppColors.textPrimary
                                : AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                    Text(step['desc']!,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textMuted)),
                    if (fetchedStage?.notes != null && fetchedStage!.notes!.isNotEmpty)
                      Text(fetchedStage.notes!,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                              fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
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
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13)),
        ],
      ),
    );
  }
}
