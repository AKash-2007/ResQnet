import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/network/api_client.dart';
import '../../../core/config/app_config.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../view_models/auth_view_model.dart';
import '../../navigation/main_scaffold.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedGender = 'Female';
  bool _agreedToTerms = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms of Service & Privacy Policy.'),
        ),
      );
      return;
    }

    final authVm = context.read<AuthViewModel>();
    final success = await authVm.register(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      gender: _selectedGender,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainScaffold()),
        (route) => false,
      );
    } else if (authVm.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authVm.errorMessage!),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _showServerConfigDialog() async {
    final controller = TextEditingController(text: AppConfig.activeHost);
    String? testStatus;
    bool isTesting = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.dns_outlined, color: Colors.blue),
              SizedBox(width: 8),
              Text('Server Configuration', style: TextStyle(fontSize: 18)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choose your connection type:\n'
                  '• On 5G/Mobile Data? Use Public Tunnel\n'
                  '• On same Wi-Fi as PC? Use Wi-Fi Phone\n'
                  '• Android Emulator? Use Emulator',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.cloud_outlined, size: 16),
                      label: const Text('5G / Mobile Data'),
                      onPressed: () {
                        setDialogState(() {
                          controller.text = AppConfig.cloudflareHost;
                          testStatus = null;
                        });
                      },
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.wifi, size: 16),
                      label: const Text('Wi-Fi Phone'),
                      onPressed: () {
                        setDialogState(() {
                          controller.text = AppConfig.defaultLanHost;
                          testStatus = null;
                        });
                      },
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.laptop, size: 16),
                      label: const Text('Emulator'),
                      onPressed: () {
                        setDialogState(() {
                          controller.text = AppConfig.emulatorHost;
                          testStatus = null;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Backend Host:Port',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                if (testStatus != null)
                  Text(
                    testStatus!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: testStatus!.startsWith('Connected') ? Colors.green : Colors.red,
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isTesting
                  ? null
                  : () async {
                      setDialogState(() {
                        isTesting = true;
                        testStatus = 'Testing connection...';
                      });
                      final ok = await ApiClient().testConnection(controller.text.trim());
                      setDialogState(() {
                        isTesting = false;
                        testStatus = ok
                            ? 'Connected to FastAPI backend!'
                            : 'Could not connect. Is backend running?';
                      });
                    },
              child: const Text('Test Connection'),
            ),
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                context.read<AuthViewModel>().setServerHost(controller.text.trim());
                Navigator.of(ctx).pop();
                setState(() {});
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authVm = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.signUp),
        actions: [
          IconButton(
            tooltip: 'Server Settings',
            icon: const Icon(Icons.dns_outlined),
            onPressed: _showServerConfigDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.createAccount,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Join the ResQnet community emergency response team.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Active Server Banner
                  Center(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _showServerConfigDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.wifi, size: 14, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 6),
                            Text(
                              'Server: ${AppConfig.activeHost}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.edit, size: 12, color: Theme.of(context).colorScheme.primary),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Full Name
                  TextFormField(
                    controller: _fullNameController,
                    decoration: InputDecoration(
                      labelText: l10n.fullName,
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: l10n.email,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Gender Selection
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: InputDecoration(
                      labelText: l10n.gender,
                      prefixIcon: const Icon(Icons.wc_outlined),
                    ),
                    items: [
                      DropdownMenuItem(value: 'Female', child: Text(l10n.female)),
                      DropdownMenuItem(value: 'Male', child: Text(l10n.male)),
                      DropdownMenuItem(value: 'Other', child: Text(l10n.other)),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedGender = val);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: l10n.password,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: l10n.confirmPassword,
                      prefixIcon: const Icon(Icons.lock_reset_outlined),
                    ),
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Terms & Privacy Checkbox
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _agreedToTerms,
                    onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
                    title: Text(
                      l10n.agreeTerms,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const SizedBox(height: 16),

                  // Submit Button
                  ElevatedButton(
                    onPressed: authVm.isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: authVm.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(l10n.createAccount),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
