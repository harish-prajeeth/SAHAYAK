import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/scheme_provider.dart';
import '../../models/scheme.dart';
import '../../utils/i18n.dart';
import '../../utils/theme.dart';

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

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF101836), AppColors.bg],
          stops: [0.0, 0.3],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ---- Header ----
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lang.t('compare.title'),
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(lang.t('compare.select_schemes'),
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                  const SizedBox(height: 12),

                  // Scheme selector chips
                  if (provider.isLoading)
                    const Center(
                        child: CircularProgressIndicator(color: AppColors.blue))
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: schemes.map((scheme) {
                        final isSelected = _selectedSchemeIds.contains(scheme.id);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedSchemeIds.remove(scheme.id);
                              } else if (_selectedSchemeIds.length < 4) {
                                _selectedSchemeIds.add(scheme.id);
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 13, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? AppGradients.of(AppGradients.blue)
                                  : null,
                              color: isSelected ? null : AppColors.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : AppColors.border),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color:
                                            AppColors.royal.withOpacity(0.35),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text('${scheme.code} · ${scheme.name}',
                              style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textSecondary)),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),

            // ---- Comparison Table ----
            Expanded(
              child: selectedSchemes.length < 2
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.compare_arrows_rounded,
                              size: 56,
                              color: AppColors.textMuted.withOpacity(0.5)),
                          const SizedBox(height: 12),
                          const Text('Select at least 2 schemes to compare',
                            style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    )
                  : _buildComparisonTable(selectedSchemes, lang),
            ),
          ],
        ),
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
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Table(
              columnWidths: {
                0: const FixedColumnWidth(110),
                for (int i = 0; i < schemes.length; i++)
                  i + 1: FixedColumnWidth(colWidth < 120 ? 120 : colWidth),
              },
              border: TableBorder.all(color: AppColors.border, width: 1),
              children: [
                // Header row with scheme names
                TableRow(
                  decoration: const BoxDecoration(gradient: AppGradients.aurora),
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('Feature',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12)),
                    ),
                    ...schemes.map((s) => Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Text(s.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 2),
                          Text(s.code,
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.75),
                                  fontSize: 10)),
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
                    decoration: BoxDecoration(
                        color: isEven
                            ? AppColors.surface
                            : AppColors.card),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(row.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          )),
                      ),
                      ...row.values.map((val) => Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(val,
                          style: TextStyle(
                            fontWeight: row.highlight
                                ? FontWeight.w800
                                : FontWeight.w500,
                            fontSize: 12,
                            color: row.highlight
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center),
                      )),
                    ],
                  );
                }),

                // Scheme name row at bottom
                TableRow(
                  decoration: BoxDecoration(
                    color: AppColors.blue.withOpacity(0.1),
                  ),
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('Scheme',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                              color: AppColors.textSecondary)),
                    ),
                    ...schemes.map((s) => Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(s.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          color: AppColors.blue,
                        ),
                        textAlign: TextAlign.center),
                    )),
                  ],
                ),
              ],
            ),
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
