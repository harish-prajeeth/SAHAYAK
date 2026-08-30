import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/application_provider.dart';
import '../../models/application.dart';

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
              color: _statusColor(app.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(app.statusLabel, style: TextStyle(fontWeight: FontWeight.bold, color: _statusColor(app.status))),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.getApplicationStatus(app.id),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Application info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Application Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    _InfoRow(label: 'Scheme', value: app.schemeName ?? 'N/A'),
                    _InfoRow(label: 'Project Type', value: app.projectType ?? 'N/A'),
                    _InfoRow(label: 'Project Cost', value: app.projectCostFormatted ?? 'N/A'),
                    _InfoRow(label: 'Loan Amount', value: app.loanAmountFormatted ?? 'N/A'),
                    _InfoRow(label: 'Partner', value: app.partnerName ?? 'N/A'),
                    _InfoRow(label: 'Created', value: app.createdAt.toString().substring(0, 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 9-Step Disbursement Chain
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Disbursement Chain', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('${_completedStages(provider.disbursementStages)}/9', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ..._buildDisbursementTimeline(context, provider.disbursementStages),
                  ],
                ),
              ),
            ),

            // Rejection info (if applicable)
            if (app.status == 'rejected') ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.error, color: Colors.red[700]),
                        const SizedBox(width: 8),
                        Text('Rejection Details', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red[700])),
                      ]),
                      const SizedBox(height: 12),
                      if (app.rejectionCategory != null)
                        _InfoRow(label: 'Category', value: app.rejectionCategory!.toUpperCase()),
                      if (app.rejectionReason != null)
                        Text(app.rejectionReason!, style: const TextStyle(fontSize: 13)),
                      if (app.remediationSteps != null) ...[
                        const SizedBox(height: 12),
                        const Text('Remediation Steps:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(app.remediationSteps!, style: const TextStyle(fontSize: 13)),
                      ],
                    ],
                  ),
                ),
              ),
            ],
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
                          ? Colors.green
                          : isCurrent
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[300],
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : isCurrent
                            ? const SizedBox(
                                width: 12, height: 12,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text('${index + 1}', style: TextStyle(color: Colors.grey[600], fontSize: 12), textAlign: TextAlign.center),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: isCompleted ? Colors.green[200] : Colors.grey[200],
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
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isCompleted ? Colors.green[700] : isCurrent ? Colors.blue[700] : Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                    Text(step['desc']!, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                    if (fetchedStage?.notes != null && fetchedStage!.notes!.isNotEmpty)
                      Text(fetchedStage.notes!, style: TextStyle(fontSize: 11, color: Colors.grey[500], fontStyle: FontStyle.italic)),
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
      case 'approved': return Colors.green;
      case 'rejected': return Colors.red;
      case 'submitted': return Colors.blue;
      case 'under_review': return Colors.orange;
      case 'disbursed': return Colors.purple;
      default: return Colors.grey;
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
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
