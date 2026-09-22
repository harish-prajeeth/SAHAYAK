import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/glass_card.dart';
import '../../utils/theme.dart';
import '../../utils/animations.dart';

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
    {'aadhaar': 'demo1', 'name': 'Priya Sharma', 'desc': 'Tailoring business, ₹2.5L', 'colors': 'blue'},
    {'aadhaar': 'demo2', 'name': 'Ravi Kumar', 'desc': 'Education loan, ₹8L', 'colors': 'purple'},
    {'aadhaar': 'demo3', 'name': 'Anita Devi', 'desc': 'Agriculture, ₹3.5L', 'colors': 'green'},
    {'aadhaar': 'demo4', 'name': 'Suresh Patel', 'desc': 'New business, ₹4.5L', 'colors': 'orange'},
  ];

  List<Color> _avatarColors(String key) {
    switch (key) {
      case 'blue':
        return AppGradients.blue;
      case 'purple':
        return AppGradients.purple;
      case 'green':
        return AppGradients.green;
      case 'orange':
        return AppGradients.orange;
      default:
        return AppGradients.indigo;
    }
  }

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
        setState(() => _error = auth.lastError ?? 'Login failed. Try a demo account.');
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
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF101836), AppColors.bg],
            stops: [0.0, 0.45],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),

                  // ---- Aurora hero (living gradient) ----
                  StaggerIn(
                    index: 0,
                    child: _AuroraHero(onLogin: _login, controller: _aadhaarController),
                  ),
                  const SizedBox(height: 32),

                  // ---- Credential card ----
                  StaggerIn(
                    index: 1,
                    child: GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const GradientIconBadge(
                                icon: Icons.badge_rounded,
                                colors: AppGradients.blue,
                                size: 36),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Aadhaar Access',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                  const Text(
                                      'Sign in with your demo ID',
                                      style: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _aadhaarController,
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5),
                          decoration: const InputDecoration(
                            labelText: 'Aadhaar Number / Demo ID',
                            hintText: 'e.g. demo1, demo2, demo3, demo4',
                            prefixIcon: Icon(Icons.key_rounded, size: 20),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.red.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.red.withOpacity(0.35)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    color: AppColors.red, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(_error!,
                                      style: const TextStyle(
                                          color: AppColors.red, fontSize: 12.5)),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        GradientButton(
                          label: 'Sign In Securely',
                          icon: Icons.shield_moon_rounded,
                          colors: AppGradients.blue,
                          loading: _isLoading,
                          onPressed: _isLoading ? null : _login,
                        ),
                      ],
                    ),
                  ),
                  ),
                  const SizedBox(height: 28),

                  // ---- Demo accounts ----
                  StaggerIn(
                    index: 2,
                    child: Row(
                      children: [
                        const Expanded(child: Divider(color: AppColors.border)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('DEMO ACCOUNTS · ONE-TAP LOGIN',
                              style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.1)),
                        ),
                        const Expanded(child: Divider(color: AppColors.border)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  ..._demoAccounts.map((acc) => StaggerIn(
                        index: 3 + _demoAccounts.indexOf(acc),
                        child: GlassCard(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        onTap: () {
                          _aadhaarController.text = acc['aadhaar']!;
                          _login();
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                gradient: AppGradients.of(
                                    _avatarColors(acc['colors']!)),
                                borderRadius: BorderRadius.circular(13),
                                boxShadow: [
                                  BoxShadow(
                                    color: _avatarColors(acc['colors']!)
                                        .first
                                        .withOpacity(0.35),
                                    blurRadius: 12,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(acc['name']![0],
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(acc['name']!,
                                      style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14)),
                                  const SizedBox(height: 2),
                                  Text(acc['desc']!,
                                      style: const TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(color: AppColors.border),
                              ),
                              child: const Icon(Icons.arrow_forward_rounded,
                                  size: 16, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    )),
                  const SizedBox(height: 16),
                  // Trust footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified_user_rounded,
                          size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        'Bank-grade encryption · Aadhaar-based secure login',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Aurora gradient hero with the Surakshit brand mark.
class _AuroraHero extends StatelessWidget {
  final VoidCallback onLogin;
  final TextEditingController controller;

  const _AuroraHero({required this.onLogin, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AuroraCard(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(26),
      boxShadow: [
        BoxShadow(
          color: AppColors.purple.withOpacity(0.35),
          blurRadius: 30,
          offset: const Offset(0, 12),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.25)),
                ),
                child: const Icon(Icons.shield_rounded,
                    color: Colors.white, size: 26),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.22)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_rounded,
                        size: 13, color: Colors.white),
                    SizedBox(width: 5),
                    Text('NSFDC READY',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Welcome to',
              style: TextStyle(
                  color: Colors.white70, fontSize: 14,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          const Text('Surakshit',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5)),
          const SizedBox(height: 6),
          const Text(
            'AI scheme matching · Financial calculator · Partner discovery',
            style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.4),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _HeroStat('10+', 'Schemes'),
              _heroDivider(),
              _HeroStat('15+', 'Partners'),
              _heroDivider(),
              _HeroStat('22', 'Languages'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroDivider() => Container(
        width: 1,
        height: 26,
        margin: const EdgeInsets.symmetric(horizontal: 14),
        color: Colors.white.withOpacity(0.25),
      );
}

class _HeroStat extends StatelessWidget {
  final String value;
  final String label;
  const _HeroStat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 17)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}
