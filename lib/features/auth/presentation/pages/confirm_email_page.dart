import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class ConfirmEmailPage extends StatefulWidget {
  const ConfirmEmailPage({
    super.key,
    required this.email,
    required this.password, // <-- Add this
  });

  final String email;
  final String password; // <-- Add this

  @override
  State<ConfirmEmailPage> createState() => _ConfirmEmailPageState();
}

class _ConfirmEmailPageState extends State<ConfirmEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final isSuccess = await authProvider.confirmEmail(
      email: widget.email,
      otp: _otpController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    if (isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account verified! Logging you in...')),
      );

      // SILENTLY LOG THEM IN right here
      await authProvider.login(
        email: widget.email,
        password: widget.password,
      );

      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final authState = context.watch<AuthProvider>();
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Email')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surface,
              colorScheme.surface.withValues(alpha: 0.95),
              colorScheme.primary.withValues(alpha: 0.08),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Verify your account',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enter the 6-digit code sent to ${widget.email}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withValues(alpha: 0.74),
                                ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  letterSpacing: 8,
                                  fontWeight: FontWeight.w700,
                                ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'OTP Code',
                              hintText: '123456',
                            ),
                            validator: (value) {
                              final otp = (value ?? '').trim();
                              if (otp.length != 6) {
                                return 'Please enter the 6-digit OTP code';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 22),
                          ElevatedButton(
                            onPressed: isLoading ? null : _verifyAccount,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                            ),
                            child: isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: colorScheme.onPrimary,
                                    ),
                                  )
                                : const Text('Verify Account'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
