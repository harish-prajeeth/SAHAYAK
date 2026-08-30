import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/scheme_provider.dart';
import '../../models/scheme.dart';
import '../../utils/i18n.dart';

class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  List<int> _selectedSchemeIds = [];

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<SchemeProvider>(context, listen: false);
    if (provider.schemes.isEmpty) provider.loadSchemes();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SchemeProvider>(context);
    final lang = Provider.of<LanguageManager>(context);
    final schemes = provider.schemes.map((s) => Scheme.fromJson(s)).toList();
    final selectedSchemes = schemes.where((s) => _selectedSchemeIds.contains(s.id)).toList();

    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lang.t('compare.title'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(lang.t('compare.select_schemes'),
                  style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                const SizedBox(height: 8),

                // Scheme selector chips
                if (provider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: schemes.map((scheme) {
                      final isSelected = _selectedSchemeIds.contains(scheme.id);
                      return FilterChip(
                        label: Text('${scheme.code} - ${scheme.name}',
                          style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : null)),
                        selected: isSelected,
                        selectedColor: Theme.of(context).colorScheme.primary,
                        checkmarkColor: Colors.white,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              if (_selectedSchemeIds.length < 4) {
                                _selectedSchemeIds.add(scheme.id);
                              }
                            } else {
                              _selectedSchemeIds.remove(scheme.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),

          // Comparison Table
          Expanded(
            child: selectedSchemes.length < 2
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.compare_arrows, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text('Select at least 2 schemes to compare',
                          style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  )
                : _buildComparisonTable(selectedSchemes, lang),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonTable(List<Scheme> schemes, LanguageManager lang) {
    final rows = [
      _CompareRow(label: lang.t('compare.max_loan'), values: schemes.map((s) => s.maxLoanFormatted).toList(), highlight: true),
      _CompareRow(label: lang.t('compare.interest_rate'), values: schemes.map((s) => s.rateFormatted).toList(), highlight: true),
      _CompareRow(label: lang.t('compare.max_tenure'), values: schemes.map((s) => s.tenureFormatted).toList()),
      _CompareRow(label: lang.t('compare.moratorium'), values: schemes.map((s) => '${s.moratoriumMonths} months').toList()),
      _CompareRow(label: 'Project Cost Range', values: schemes.map((s) => 'Up to ${s.maxCostFormatted}').toList()),
      _CompareRow(label: lang.t('compare.channels'), values: schemes.map((s) => s.channelTypes.join(', ')).toList()),
    ];

    final colWidth = (MediaQuery.of(context).size.width - 120) / schemes.length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Table(
            columnWidths: {
              0: const FixedColumnWidth(110),
              for (int i = 0; i < schemes.length; i++)
                i + 1: FixedColumnWidth(colWidth < 120 ? 120 : colWidth),
            },
            border: TableBorder.all(color: Colors.grey[200]!, width: 1),
            children: [
              // Header row with scheme names
              TableRow(
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
                children: [
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('Feature', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  ...schemes.map((s) => Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Text(s.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                          textAlign: TextAlign.center),
                        const SizedBox(height: 2),
                        Text(s.code, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10)),
                      ],
                    ),
                  )),
                ],
              ),

              // Data rows
              ...rows.asMap().entries.map((entry) {
                final row = entry.value;
                final isEven = entry.key % 2 == 0;
                return TableRow(
                  decoration: BoxDecoration(color: isEven ? Colors.grey[50] : Colors.white),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(row.label,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: Colors.grey[700],
                        )),
                    ),
                    ...row.values.map((val) => Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(val,
                        style: TextStyle(
                          fontWeight: row.highlight ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                          color: row.highlight ? Theme.of(context).colorScheme.primary : Colors.black87,
                        ),
                        textAlign: TextAlign.center),
                    )),
                  ],
                );
              }),

              // Scheme name row at bottom for easy reading
              TableRow(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text('Scheme', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey[700])),
                  ),
                  ...schemes.map((s) => Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(s.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      textAlign: TextAlign.center),
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompareRow {
  final String label;
  final List<String> values;
  final bool highlight;

  _CompareRow({required this.label, required this.values, this.highlight = false});
}
