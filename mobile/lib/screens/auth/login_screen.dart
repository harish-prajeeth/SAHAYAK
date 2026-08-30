import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _aadhaarController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  final List<Map<String, String>> _demoAccounts = [
    {'aadhaar': 'demo1', 'name': 'Priya Sharma', 'desc': 'Tailoring business, ₹2.5L'},
    {'aadhaar': 'demo2', 'name': 'Ravi Kumar', 'desc': 'Education loan, ₹8L'},
    {'aadhaar': 'demo3', 'name': 'Anita Devi', 'desc': 'Agriculture, ₹3.5L'},
    {'aadhaar': 'demo4', 'name': 'Suresh Patel', 'desc': 'New business, ₹4.5L'},
  ];

  @override
  void dispose() {
    _aadhaarController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.login(_aadhaarController.text.trim());
      if (auth.user == null) {
        setState(() => _error = 'User not found. Try a demo account.');
      }
    } catch (e) {
      setState(() => _error = 'Login failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // Logo
                Icon(Icons.shield, size: 64, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 16),
                Text('Surakshit', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Priority Sector Lending Platform', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 40),

                // Aadhaar input
                TextFormField(
                  controller: _aadhaarController,
                  decoration: const InputDecoration(
                    labelText: 'Aadhaar Number / Demo ID',
                    prefixIcon: Icon(Icons.badge),
                    hintText: 'e.g. demo1, demo2, demo3, demo4',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 8),

                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                  ),

                // Login button
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Login'),
                ),
                const SizedBox(height: 24),

                // Demo accounts
                Text('Demo Accounts', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ..._demoAccounts.map((acc) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(child: Text(acc['name']![0])),
                    title: Text(acc['name']!),
                    subtitle: Text(acc['desc']!),
                    trailing: const Icon(Icons.login, size: 20),
                    onTap: () {
                      _aadhaarController.text = acc['aadhaar']!;
                      _login();
                    },
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
