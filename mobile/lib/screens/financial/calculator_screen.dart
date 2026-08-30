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
  final _moratoriumController = TextEditingController(text: '0');

  Map<String, dynamic>? _result;
  bool _isLoading = false;

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
        'moratoriumMonths': int.parse(_moratoriumController.text),
      });
      setState(() => _result = result['calculation']);
    } catch (e) {
      setState(() => _result = null);
    } finally {
      setState(() => _isLoading = false);
    }
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
              Text('Loan Calculator', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // Input fields
              TextFormField(
                controller: _principalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Loan Amount (₹)', prefixIcon: Icon(Icons.currency_rupee)),
                validator: (v) => (v == null || double.tryParse(v) == null) ? 'Enter valid amount' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _rateController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Interest Rate (%)', prefixIcon: Icon(Icons.percent)),
                validator: (v) => (v == null || double.tryParse(v) == null) ? 'Enter valid rate' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tenureController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Tenure (months)', prefixIcon: Icon(Icons.calendar_today)),
                      validator: (v) => (v == null || int.tryParse(v) == null) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _moratoriumController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Moratorium', prefixIcon: Icon(Icons.pause)),
                      validator: (v) => (v == null || int.tryParse(v) == null) ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _isLoading ? null : _calculate,
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Calculate EMI'),
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
    final emi = r['emi'] ?? 0;
    final totalPayment = r['totalPayment'] ?? 0;
    final totalInterest = r['totalInterest'] ?? 0;
    final effectiveTenure = r['effectiveTenure'] ?? 0;
    final moratoriumMonths = r['moratoriumMonths'] ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // EMI highlight
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.7)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('Monthly EMI', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('₹${emi.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Summary
            Row(
              children: [
                _ResultItem(label: 'Total Payment', value: '₹${totalPayment.toStringAsFixed(0)}'),
                _ResultItem(label: 'Total Interest', value: '₹${totalInterest.toStringAsFixed(0)}'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _ResultItem(label: 'Effective Tenure', value: '$effectiveTenure months'),
                _ResultItem(label: 'Moratorium', value: '$moratoriumMonths months'),
              ],
            ),

            // EMI to Principal vs Interest bar
            const SizedBox(height: 20),
            const Text('Payment Breakdown', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: totalPayment > 0 ? (double.parse(_principalController.text) / totalPayment) : 0,
                minHeight: 12,
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

            // Yearly summary
            if (r['yearlySummary'] != null && (r['yearlySummary'] as List).isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text('Yearly Summary', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...((r['yearlySummary'] as List).map((y) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text('Year ${y['year']}', style: const TextStyle(fontWeight: FontWeight.bold, width: 60)),
                    Expanded(child: Text('₹${(y['principalPaid'] ?? 0).toStringAsFixed(0)} principal')),
                    Expanded(child: Text('₹${(y['interestPaid'] ?? 0).toStringAsFixed(0)} interest')),
                    Text('₹${(y['endingBalance'] ?? 0).toStringAsFixed(0)}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ))),
            ],
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
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
