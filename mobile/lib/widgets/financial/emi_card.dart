import 'package:flutter/material.dart';

class EmiCard extends StatelessWidget {
  final double emi;
  final double totalPayment;
  final double totalInterest;
  final int effectiveTenure;
  final int moratoriumMonths;

  const EmiCard({
    super.key,
    required this.emi,
    required this.totalPayment,
    required this.totalInterest,
    required this.effectiveTenure,
    this.moratoriumMonths = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // EMI highlight
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('Monthly EMI', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('₹${emi.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Summary row
            Row(
              children: [
                _ResultItem(label: 'Total Payment', value: '₹${totalPayment.toStringAsFixed(0)}'),
                _ResultItem(label: 'Total Interest', value: '₹${totalInterest.toStringAsFixed(0)}'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _ResultItem(label: 'Tenure', value: '$effectiveTenure months'),
                _ResultItem(label: 'Moratorium', value: '$moratoriumMonths months'),
              ],
            ),

            // Payment bar
            const SizedBox(height: 16),
            const Text('Principal vs Interest', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: totalPayment > 0 ? (totalPayment - totalInterest) / totalPayment : 0,
                minHeight: 10,
                backgroundColor: Colors.orange[100],
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [Container(width: 10, height: 10, color: Colors.blue), const SizedBox(width: 4), const Text('Principal', style: TextStyle(fontSize: 11))]),
                Row(children: [Container(width: 10, height: 10, color: Colors.orange[100]!), const SizedBox(width: 4), const Text('Interest', style: TextStyle(fontSize: 11))]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultItem extends StatelessWidget {
  final String label, value;
  const _ResultItem({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
