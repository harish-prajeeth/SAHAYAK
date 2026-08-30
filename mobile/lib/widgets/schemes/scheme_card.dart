import 'package:flutter/material.dart';
import '../../models/scheme.dart';

class SchemeCard extends StatelessWidget {
  final Scheme scheme;
  final VoidCallback? onTap;

  const SchemeCard({super.key, required this.scheme, this.onTap});

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
                    backgroundColor: _schemeColor(scheme.code).withOpacity(0.1),
                    child: Icon(_schemeIcon(scheme.code), color: _schemeColor(scheme.code), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(scheme.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(scheme.code, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(scheme.rateFormatted, style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (scheme.description != null)
                Text(scheme.description!, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _InfoChip(label: 'Up to ${scheme.maxLoanFormatted}'),
                  _InfoChip(label: scheme.tenureFormatted),
                  _InfoChip(label: '${scheme.moratoriumMonths}mo moratorium'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _schemeColor(String code) {
    switch (code) {
      case 'MFS': return Colors.green;
      case 'TL': return Colors.blue;
      case 'ELS': return Colors.purple;
      case 'AMY': return Colors.orange;
      default: return Colors.grey;
    }
  }

  IconData _schemeIcon(String code) {
    switch (code) {
      case 'MFS': return Icons.account_balance_wallet;
      case 'TL': return Icons.business;
      case 'ELS': return Icons.school;
      case 'AMY': return Icons.store;
      default: return Icons.help_outline;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  const _InfoChip({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: const TextStyle(fontSize: 11)),
    );
  }
}
