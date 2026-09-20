import 'package:flutter/material.dart';
import '../../api/api_service.dart';
import '../../utils/theme.dart';
import '../../utils/animations.dart';
import '../../widgets/common/glass_card.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});
  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _principalController = TextEditingController(text: '100000');
  final _rateController = TextEditingController(text: '8.0');
  final _tenureController = TextEditingController(text: '36');
  final _moratoriumController = TextEditingController(text: '3');

  int _courseDurationYears = 0;
  Map<String, dynamic>? _result;
  bool _isLoading = false;

  bool get _isEducationLoan => _courseDurationYears > 0;
  int get _computedMoratoriumMonths => _isEducationLoan ? (_courseDurationYears * 12) + 12 : int.tryParse(_moratoriumController.text) ?? 0;
  int get _computedMoratQuarters => (_computedMoratoriumMonths / 3).ceil();

  @override
  void dispose() {
    _principalController.dispose();
    _rateController.dispose();
    _tenureController.dispose();
    _moratoriumController.dispose();
    super.dispose();
  }

  Future<void> _calculate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.calculateLoan({
        'principal': double.parse(_principalController.text),
        'interestRate': double.parse(_rateController.text),
        'tenureMonths': int.parse(_tenureController.text),
        'moratoriumMonths': _isEducationLoan ? 0 : int.parse(_moratoriumController.text),
        'courseDurationYears': _courseDurationYears,
      });
      setState(() => _result = result['calculation']);
    } catch (e) {
      setState(() => _result = null);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyPreset(String principal, String rate, String tenure, String moratorium, [int courseDuration = 0]) {
    setState(() {
      _principalController.text = principal;
      _rateController.text = rate;
      _tenureController.text = tenure;
      _moratoriumController.text = moratorium;
      _courseDurationYears = courseDuration;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF101836), AppColors.bg],
          stops: [0.0, 0.35],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Quarterly EQI Calculator',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text('NSFDC moratorium-adjusted quarterly installment calculator',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                const SizedBox(height: 16),

                // ---- Info banner ----
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.blue.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(children: [
                        Icon(Icons.lightbulb_rounded, size: 16, color: AppColors.blue),
                        SizedBox(width: 6),
                        Text('How it works',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.blue,
                                fontSize: 12.5)),
                      ]),
                      const SizedBox(height: 6),
                      Text(
                        'During moratorium, interest accrues quarterly and capitalizes into principal. '
                        'After moratorium, you repay the accumulated amount in equal quarterly installments (EQI).',
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11.5,
                            height: 1.45),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ---- Preset chips ----
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _PresetChip(label: 'Micro Finance', icon: Icons.account_balance_wallet_rounded, onTap: () => _applyPreset('110000', '6.5', '36', '3')),
                    _PresetChip(label: 'Term Loan', icon: Icons.business_rounded, onTap: () => _applyPreset('300000', '8.0', '84', '6')),
                    _PresetChip(label: 'Education (2yr)', icon: Icons.school_rounded, onTap: () => _applyPreset('1000000', '6.5', '144', '0', 2)),
                    _PresetChip(label: 'Example (₹1L)', icon: Icons.calculate_rounded, onTap: () => _applyPreset('100000', '8.0', '36', '3')),
                  ],
                ),
                const SizedBox(height: 18),

                // ---- Input card ----
                GlassCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _principalController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                        decoration: const InputDecoration(
                          labelText: 'Loan Amount (₹)',
                          prefixIcon: Icon(Icons.currency_rupee_rounded, size: 20),
                        ),
                        validator: (v) => (v == null || double.tryParse(v) == null) ? 'Enter valid amount' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _rateController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                        decoration: const InputDecoration(
                          labelText: 'Annual Interest Rate (%)',
                          prefixIcon: Icon(Icons.percent_rounded, size: 20),
                        ),
                        validator: (v) => (v == null || double.tryParse(v) == null) ? 'Enter valid rate' : null,
                      ),
                      const SizedBox(height: 14),
                      // Course Duration (for Educational Loans)
                      DropdownButtonFormField<int>(
                        value: _courseDurationYears,
                        dropdownColor: AppColors.surface,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                        decoration: const InputDecoration(
                          labelText: 'Course Duration (Education Loans only)',
                          prefixIcon: Icon(Icons.school_rounded, size: 20),
                        ),
                        items: const [
                          DropdownMenuItem(value: 0, child: Text('Not an education loan')),
                          DropdownMenuItem(value: 1, child: Text('1 year course')),
                          DropdownMenuItem(value: 2, child: Text('2 year course')),
                          DropdownMenuItem(value: 3, child: Text('3 year course')),
                          DropdownMenuItem(value: 4, child: Text('4 year course (Engineering)')),
                          DropdownMenuItem(value: 5, child: Text('5 year course (Medicine)')),
                        ],
                        onChanged: (v) => setState(() => _courseDurationYears = v ?? 0),
                      ),
                      if (_isEducationLoan)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                            decoration: BoxDecoration(
                              color: AppColors.cyan.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.cyan.withOpacity(0.3)),
                            ),
                            child: Text(
                              'Moratorium = Course (${_courseDurationYears}yr) + 1yr grace = $_computedMoratQuarters quarters ($_computedMoratoriumMonths months)',
                              style: const TextStyle(color: AppColors.cyan, fontSize: 11),
                            ),
                          ),
                        ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _tenureController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                              decoration: const InputDecoration(
                                labelText: 'Tenure (months)',
                                prefixIcon: Icon(Icons.calendar_month_rounded, size: 20),
                              ),
                              validator: (v) => (v == null || int.tryParse(v) == null) ? 'Required' : null,
                            ),
                          ),
                          if (!_isEducationLoan) ...[
                            const SizedBox(width: 14),
                            Expanded(
                              child: TextFormField(
                                controller: _moratoriumController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                                decoration: const InputDecoration(
                                  labelText: 'Moratorium (months)',
                                  prefixIcon: Icon(Icons.pause_circle_rounded, size: 20),
                                ),
                                validator: (v) => (v == null || int.tryParse(v) == null) ? 'Required' : null,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 18),
                      GradientButton(
                        label: 'Calculate EQI',
                        icon: Icons.functions_rounded,
                        colors: AppGradients.aurora.colors,
                        loading: _isLoading,
                        onPressed: _isLoading ? null : _calculate,
                      ),
                    ],
                  ),
                ),

                // ---- Results ----
                if (_result != null) ...[
                  const SizedBox(height: 20),
                  StaggerIn(index: 1, child: _buildResultsCard()),
                ],
                const SizedBox(height: 110),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsCard() {
    final r = _result!;
    final eqi = (r['eqi'] ?? r['emi'] ?? 0).toDouble();
    final totalPayment = (r['totalPayment'] ?? 0).toDouble();
    final totalInterest = (r['totalInterest'] ?? 0).toDouble();
    final moratoriumInterest = (r['moratoriumInterest'] ?? 0).toDouble();
    final accumulated = (r['accumulatedPrincipal'] ?? r['effectivePrincipal'] ?? 0).toDouble();
    final repaymentQuarters = r['repaymentQuarters'] ?? 0;
    final moratoriumQuarters = r['moratoriumQuarters'] ?? 0;
    final quarterlyRate = (r['quarterlyRate'] ?? 0).toDouble();

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- EQI hero (aurora) ----
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppGradients.aurora,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.purple.withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text('Quarterly EQI',
                    style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Text('₹${eqi.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(
                  '$repaymentQuarters quarterly payments after $moratoriumQuarters quarter moratorium',
                  style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Quarterly Rate: ${quarterlyRate.toStringAsFixed(2)}%',
                      style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ---- Summary grid ----
          Row(
            children: [
              Expanded(child: _ResultItem(label: 'Total Payment', value: '₹${totalPayment.toStringAsFixed(0)}', color: AppColors.textPrimary)),
              Expanded(child: _ResultItem(label: 'Total Interest', value: '₹${totalInterest.toStringAsFixed(0)}', color: AppColors.orange)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(child: _ResultItem(label: 'Moratorium Interest', value: '₹${moratoriumInterest.toStringAsFixed(0)}', color: AppColors.amber)),
              Expanded(child: _ResultItem(label: 'Accumulated Principal', value: '₹${accumulated.toStringAsFixed(0)}', color: AppColors.blue)),
            ],
          ),

          // ---- Payment breakdown ----
          const SizedBox(height: 18),
          const Text('Payment Breakdown',
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: totalPayment > 0 ? (double.parse(_principalController.text) / totalPayment) : 0,
              minHeight: 14,
              backgroundColor: AppColors.orange.withOpacity(0.25),
              color: AppColors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Container(width: 12, height: 12, decoration: BoxDecoration(color: AppColors.blue, borderRadius: BorderRadius.circular(3))),
                const SizedBox(width: 6),
                const Text('Principal', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
              ]),
              Row(children: [
                Container(width: 12, height: 12, decoration: BoxDecoration(color: AppColors.orange.withOpacity(0.4), borderRadius: BorderRadius.circular(3))),
                const SizedBox(width: 6),
                const Text('Interest', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
              ]),
            ],
          ),

          // ---- Quarterly schedule ----
          if (r['quarterlySchedule'] != null && (r['quarterlySchedule'] as List).isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Quarterly Schedule',
                    style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
                Text('${(r['quarterlySchedule'] as List).length} quarters',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 10),
            ...((r['quarterlySchedule'] as List).take(16).map((q) {
              final isMoratorium = q['phase'] == 'moratorium';
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 3),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: isMoratorium
                      ? AppColors.amber.withOpacity(0.08)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: isMoratorium
                          ? AppColors.amber.withOpacity(0.25)
                          : AppColors.border),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 34,
                      child: Text('Q${q['quarter']}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              fontSize: 12.5)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: isMoratorium
                            ? AppColors.amber.withOpacity(0.15)
                            : AppColors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(isMoratorium ? 'Morat.' : 'Repay.',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isMoratorium ? AppColors.amber : AppColors.green)),
                    ),
                    const SizedBox(width: 10),
                    if (!isMoratorium)
                      Text('₹${(q['eqi'] ?? 0).toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              fontSize: 12.5)),
                    if (isMoratorium)
                      Text('Cap: ₹${(q['capitalizedInterest'] ?? 0).toStringAsFixed(0)}',
                          style: const TextStyle(color: AppColors.amber, fontSize: 11.5)),
                    const Spacer(),
                    Text('₹${(q['balance'] ?? 0).toStringAsFixed(0)}',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
                  ],
                ),
              );
            })),
            if ((r['quarterlySchedule'] as List).length > 16)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('... and ${r['quarterlySchedule'].length - 16} more quarters',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ),
          ],

          // ---- Yearly summary ----
          if (r['yearlySummary'] != null && (r['yearlySummary'] as List).isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text('Yearly Summary',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 8),
            ...((r['yearlySummary'] as List).map((y) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 70,
                        child: Text('Year ${y['year']}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                fontSize: 12.5)),
                      ),
                      Expanded(
                          child: Text('₹${(y['principalPaid'] ?? 0).toStringAsFixed(0)} principal',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))),
                      Expanded(
                          child: Text('₹${(y['interestPaid'] ?? 0).toStringAsFixed(0)} interest',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))),
                      Text('₹${(y['endingBalance'] ?? 0).toStringAsFixed(0)}',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                ))),
          ],

          // ---- Interest rate source ----
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Interest Rate Mechanism',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                const Text(
                  'NSFDC charges 2.5% from SCAs/CAs, which charge 6.5% from beneficiaries.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 10.5),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Source: NSFDC Official Website (www.nsfdc.nic.in)',
                  style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10.5,
                      fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultItem extends StatelessWidget {
  final String label, value;
  final Color? color;
  const _ResultItem({required this.label, required this.value, this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 14.5, color: color ?? AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _PresetChip({required this.label, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.blue.withOpacity(0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: AppColors.blue),
              const SizedBox(width: 6),
              Text(label,
                  style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
