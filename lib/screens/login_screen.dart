import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/auth_service.dart';
import 'driver/driver_dashboard_screen.dart';
import 'inspector/inspector_dashboard_screen.dart';
import 'owner/container_owner_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberLogin = true;

  @override
  void initState() {
    super.initState();
    final last = AuthService.instance.lastLogin;
    if (last != null) {
      _emailController.text = last.email;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim().toLowerCase();
      final password = _passwordController.text;

      final auth = AuthService.instance;
      // Only authorized accounts can access dashboards
      if (!auth.isAuthorizedEmail(email)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Access restricted. Unauthorized account.'),
            backgroundColor: AppTheme.tamperRed,
          ),
        );
        return;
      }

      final signedIn = auth.signIn(email, password, remember: _rememberLogin);
      if (signedIn) {
        if (email == 'dhananjaya1@gmail.com') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DriverDashboardScreen()),
          );
        } else if (email == 'dhananjaya2@gmail.com') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const InspectorDashboardScreen()),
          );
        } else if (email == 'dhananjaya3@gmail.com') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ContainerOwnerDashboardScreen()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid credentials'),
            backgroundColor: AppTheme.tamperRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService.instance;
    final recentLogins = auth.recentLogins;

    return Scaffold(
      backgroundColor: AppTheme.slate50,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(4),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo_circle.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'C GO',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.navyPrimary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sri Lanka Customs Smart Logistics Security',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Saved Recent Logins Section
                  if (recentLogins.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.history_rounded, size: 16, color: AppTheme.slate700),
                            SizedBox(width: 6),
                            Text(
                              'Recent Logins',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.slate800,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              auth.clearRecentLogins();
                            });
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(50, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Clear', style: TextStyle(fontSize: 11)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...recentLogins.map((record) => _buildRecentLoginCard(record, auth)),
                    const SizedBox(height: 16),
                  ],

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'User Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) => (value == null || value.isEmpty) ? 'Please enter email' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) => (value == null || value.isEmpty) ? 'Please enter password' : null,
                  ),
                  const SizedBox(height: 12),

                  // Remember / Save Login Details Checkbox
                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _rememberLogin,
                          activeColor: AppTheme.customsBlue,
                          onChanged: (val) {
                            setState(() {
                              _rememberLogin = val ?? true;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Save recent login details',
                        style: TextStyle(fontSize: 13, color: AppTheme.slate700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  FilledButton.icon(
                    onPressed: _login,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.customsBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.login_rounded),
                    label: const Text(
                      'Sign In',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentLoginCard(LoginRecord record, AuthService auth) {
    return InkWell(
      onTap: () {
        setState(() {
          _emailController.text = record.email;
          _passwordController.text = '12345';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Auto-filled credentials for ${record.userName} (${record.roleName})'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.slate200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.customsBlue.withValues(alpha: 0.1),
              child: Icon(
                record.roleName.contains('Driver')
                    ? Icons.local_shipping_outlined
                    : record.roleName.contains('Inspector')
                        ? Icons.shield_outlined
                        : Icons.business_outlined,
                size: 20,
                color: AppTheme.customsBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        record.userName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.slate800,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.slate100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          record.roleName,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${record.email} • ${record.formattedTime}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 16, color: Colors.grey),
              tooltip: 'Remove recent login',
              onPressed: () {
                setState(() {
                  auth.removeRecentLogin(record.email);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
