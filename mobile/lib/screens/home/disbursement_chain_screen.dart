import 'package:flutter/material.dart';
import '../../models/application.dart';
import '../../utils/theme.dart';

class DisbursementChainScreen extends StatelessWidget {
  final List<DisbursementStage> stages;
  final int totalStages;

  const DisbursementChainScreen({
    super.key,
    required this.stages,
    this.totalStages = 9,
  });

  @override
  Widget build(BuildContext context) {
    final chainSteps = DisbursementStage.chainSteps;

    return Scaffold(
      appBar: AppBar(title: const Text('Disbursement Chain')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF101836), AppColors.bg],
            stops: [0.0, 0.3],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: chainSteps.length,
          itemBuilder: (context, index) {
            final step = chainSteps[index];
            final fetched = index < stages.length ? stages[index] : null;
            final isCompleted = fetched?.completed ?? false;
            final isCurrent = fetched?.current ?? false;
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
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted
                                ? AppColors.green
                                : isCurrent
                                    ? AppColors.blue
                                    : AppColors.surface,
                            border: Border.all(
                                color: isCompleted || isCurrent
                                    ? Colors.transparent
                                    : AppColors.border,
                                width: 1.5),
                            boxShadow: isCurrent
                                ? [
                                    BoxShadow(
                                        color: AppColors.blue.withOpacity(0.5),
                                        blurRadius: 12)
                                  ]
                                : null,
                          ),
                          child: isCompleted
                              ? const Icon(Icons.check_rounded, color: Colors.white, size: 17)
                              : isCurrent
                                  ? const SizedBox(
                                      width: 14, height: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : Text('${index + 1}',
                                      style: const TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 12.5,
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
                  const SizedBox(width: 16),

                  // Step content
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 24),
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
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(step['desc']!,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textMuted)),
                          if (fetched?.notes != null && fetched!.notes!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(fetched.notes!,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                    fontStyle: FontStyle.italic)),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
