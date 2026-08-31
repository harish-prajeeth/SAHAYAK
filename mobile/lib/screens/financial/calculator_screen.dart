import 'package:flutter/material.dart';
import '../../api/api_service.dart';

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
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Quarterly EQI Calculator',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('NSFDC moratorium-adjusted quarterly installment calculator',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              const SizedBox(height: 16),

              // Info Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.blue[600]),
                      const SizedBox(width: 6),
                      Text('How it works', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800], fontSize: 12)),
                    ]),
                    const SizedBox(height: 4),
                    Text(
                      'During moratorium, interest accrues quarterly and capitalizes into principal. '
                      'After moratorium, you repay the accumulated amount in equal quarterly installments (EQI).',
                      style: TextStyle(color: Colors.blue[700], fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Preset buttons
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _PresetChip(label: 'Micro Finance', onTap: () => _applyPreset('110000', '6.5', '36', '3')),
                  _PresetChip(label: 'Term Loan', onTap: () => _applyPreset('300000', '8.0', '84', '6')),
                  _PresetChip(label: 'Education (2yr)', onTap: () => _applyPreset('1000000', '6.5', '144', '0', 2)),
                  _PresetChip(label: 'Example (₹1L)', onTap: () => _applyPreset('100000', '8.0', '36', '3')),
                ],
              ),
              const SizedBox(height: 16),

              // Input fields
              TextFormField(
                controller: _principalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Loan Amount (₹)',
                  prefixIcon: Icon(Icons.currency_rupee),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || double.tryParse(v) == null) ? 'Enter valid amount' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _rateController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Annual Interest Rate (%)',
                  prefixIcon: Icon(Icons.percent),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || double.tryParse(v) == null) ? 'Enter valid rate' : null,
              ),
              const SizedBox(height: 12),
              // Course Duration (for Educational Loans)
              DropdownButtonFormField<int>
                value: _courseDurationYears,
                decoration: const InputDecoration(
                  labelText: 'Course Duration (Education Loans only)',
                  prefixIcon: Icon(Icons.school),
                  border: OutlineInputBorder(),
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
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Moratorium = Course (${_courseDurationYears}yr) + 1yr grace = $_computedMoratQuarters quarters ($_computedMoratoriumMonths months)',
                    style: TextStyle(color: Colors.blue[600], fontSize: 11),
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tenureController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Tenure (months)',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || int.tryParse(v) == null) ? 'Required' : null,
                    ),
                  ),
                  if (!_isEducationLoan) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _moratoriumController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Moratorium (months)',
                          prefixIcon: const Icon(Icons.pause),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || int.tryParse(v) == null) ? 'Required' : null,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _isLoading ? null : _calculate,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Calculate EQI', style: TextStyle(fontWeight: FontWeight.bold)),
              ),

              // Results
              if (_result != null) ...[
                const SizedBox(height: 24),
                _buildResultsCard(),
              ],
            ],
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

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Primary EQI highlight
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[700]!, Colors.blue[500]!],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('Quarterly EQI', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('₹${eqi.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    '$repaymentQuarters quarterly payments after $moratoriumQuarters quarter moratorium',
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text('Quarterly Rate: ${quarterlyRate.toStringAsFixed(2)}%', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Summary grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.2,
              children: [
                _ResultItem(label: 'Total Payment', value: '₹${totalPayment.toStringAsFixed(0)}'),
                _ResultItem(label: 'Total Interest', value: '₹${totalInterest.toStringAsFixed(0)}'),
                _ResultItem(label: 'Moratorium Interest', value: '₹${moratoriumInterest.toStringAsFixed(0)}', color: Colors.amber),
                _ResultItem(label: 'Accumulated Principal', value: '₹${accumulated.toStringAsFixed(0)}', color: Colors.blue),
              ],
            ),

            // Payment breakdown bar
            const SizedBox(height: 20),
            const Text('Payment Breakdown', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: totalPayment > 0 ? (double.parse(_principalController.text) / totalPayment) : 0,
                minHeight: 14,
                backgroundColor: Colors.orange[100],
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [Container(width: 12, height: 12, color: Colors.blue), const SizedBox(width: 4), const Text('Principal', style: TextStyle(fontSize: 12))]),
                Row(children: [Container(width: 12, height: 12, color: Colors.orange[100]!), const SizedBox(width: 4), const Text('Interest', style: TextStyle(fontSize: 12))]),
              ],
            ),

            // Quarterly Schedule
            if (r['quarterlySchedule'] != null && (r['quarterlySchedule'] as List).isNotEmpty) ...[
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Quarterly Schedule', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('${(r['quarterlySchedule'] as List).length} quarters', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              ...((r['quarterlySchedule'] as List).take(16).map((q) {
                final isMoratorium = q['phase'] == 'moratorium';
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isMoratorium ? Colors.amber[50] : Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text('Q${q['quarter']}', style: const TextStyle(fontWeight: FontWeight.bold, width: 36)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isMoratorium ? Colors.amber[100] : Colors.green[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(isMoratorium ? 'Morat.' : 'Repay.', style: TextStyle(fontSize: 10, color: isMoratorium ? Colors.amber[800] : Colors.green[800])),
                      ),
                      const SizedBox(width: 8),
                      if (!isMoratorium) Text('₹${(q['eqi'] ?? 0).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (isMoratorium) Text('Cap: ₹${(q['capitalizedInterest'] ?? 0).toStringAsFixed(0)}', style: TextStyle(color: Colors.amber[700], fontSize: 12)),
                      const Spacer(),
                      Text('₹${(q['balance'] ?? 0).toStringAsFixed(0)}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ],
                  ),
                );
              })),
              if ((r['quarterlySchedule'] as List).length > 16)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('... and ${r['quarterlySchedule'].length - 16} more quarters', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ),
            ],

            // Yearly summary
            if (r['yearlySummary'] != null && (r['yearlySummary'] as List).isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text('Yearly Summary', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...((r['yearlySummary'] as List).map((y) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text('Year ${y['year']}', style: const TextStyle(fontWeight: FontWeight.bold, width: 70)),
                    Expanded(child: Text('₹${(y['principalPaid'] ?? 0).toStringAsFixed(0)} principal')),
                    Expanded(child: Text('₹${(y['interestPaid'] ?? 0).toStringAsFixed(0)} interest')),
                    Text('₹${(y['endingBalance'] ?? 0).toStringAsFixed(0)}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ))),
            ],

            // Interest rate source
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Interest Rate Mechanism', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey[700])),
                  const SizedBox(height: 4),
                  Text(
                    'NSFDC charges 2.5% from SCAs/CAs, which charge 6.5% from beneficiaries.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 10),
                  ),
                  Text(
                    'Source: NSFDC Official Website (www.nsfdc.nic.in)',
                    style: TextStyle(color: Colors.grey[500], fontSize: 10, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ],
        ),
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
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
        ],
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PresetChip({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      onPressed: onTap,
      backgroundColor: Colors.blue[50],
      side: BorderSide(color: Colors.blue[200]!),
    );
  }
}
