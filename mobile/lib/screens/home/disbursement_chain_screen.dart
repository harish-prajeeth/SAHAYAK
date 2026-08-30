import 'package:flutter/material.dart';
import '../../models/application.dart';

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
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
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
                              ? Colors.green
                              : isCurrent
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey[300],
                        ),
                        child: isCompleted
                            ? const Icon(Icons.check, color: Colors.white, size: 18)
                            : isCurrent
                                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : Text('${index + 1}', style: TextStyle(color: Colors.grey[600], fontSize: 13), textAlign: TextAlign.center),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(width: 2, color: isCompleted ? Colors.green[200] : Colors.grey[200]),
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
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                            color: isCompleted ? Colors.green[700] : isCurrent ? Colors.blue[700] : Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(step['desc']!, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                        if (fetched?.notes != null && fetched!.notes!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(fetched.notes!, style: TextStyle(fontSize: 12, color: Colors.grey[500], fontStyle: FontStyle.italic)),
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
    );
  }
}
