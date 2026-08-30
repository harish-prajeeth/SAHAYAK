import 'package:flutter/material.dart';
import '../../models/partner.dart';

class PartnerCard extends StatelessWidget {
  final Partner partner;
  final VoidCallback? onTap;

  const PartnerCard({super.key, required this.partner, this.onTap});

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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(partner.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(partner.typeLabel, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  if (partner.distance != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(partner.distanceFormatted, style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                    ),
                ],
              ),
              if (partner.address != null) ...[
                const SizedBox(height: 8),
                Row(children: [
                  Icon(Icons.place, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Expanded(child: Text(partner.address!, style: const TextStyle(fontSize: 12))),
                ]),
              ],
              if (partner.phone != null) ...[
                const SizedBox(height: 4),
                Row(children: [
                  Icon(Icons.phone, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(partner.phone!, style: const TextStyle(fontSize: 12)),
                ]),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  _EligibilityBadge(
                    label: 'Fund: ${partner.fundUtilization.toStringAsFixed(0)}%',
                    good: partner.fundUtilization >= 80,
                  ),
                  const SizedBox(width: 8),
                  _EligibilityBadge(
                    label: 'NPA: ${partner.npaRate.toStringAsFixed(1)}%',
                    good: partner.npaRate < 10,
                  ),
                  const SizedBox(width: 8),
                  _EligibilityBadge(
                    label: partner.isEligible ? '✅ Eligible' : '❌ Not Eligible',
                    good: partner.isEligible,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EligibilityBadge extends StatelessWidget {
  final String label;
  final bool good;
  const _EligibilityBadge({required this.label, required this.good});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: good ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: good ? Colors.green[700] : Colors.red[700])),
    );
  }
}
