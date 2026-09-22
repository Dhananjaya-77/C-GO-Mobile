import 'package:flutter/material.dart';
import '../models/user_role.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import '../widgets/biometric_auth_dialog.dart';
import '../widgets/cgo_logo.dart';
import 'driver/driver_dashboard_screen.dart';
import 'inspector/inspector_dashboard_screen.dart';
import 'owner/container_owner_dashboard.dart';
import 'welcome_screen.dart';

/// Highly attractive and functional Login Screen
/// Implements SRS Figure 9 with modern UI, quick demo roles, recent logins,
/// and biometric quick-sign-in support.
class LoginScreen extends StatefulWidget {
  final UserRole selectedRole;

  const LoginScreen({
    super.key,
    this.selectedRole = UserRole.driver,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;
  bool _saveRecentLogins = true;
  bool _saveBiometrics = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: _getDefaultEmailForRole(widget.selectedRole));
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _getDefaultEmailForRole(UserRole role) {
    switch (role) {
      case UserRole.driver:
        return 'dhananjaya1@gmail.com';
      case UserRole.inspector:
        return 'dhananjaya2@gmail.com';
      case UserRole.owner:
        return 'dhananjaya3@gmail.com';
    }
  }

  String get _roleTitle {
    switch (widget.selectedRole) {
      case UserRole.driver:
        return 'Driver Login';
      case UserRole.inspector:
        return 'Inspector Login';
      case UserRole.owner:
        return 'Container Owner Login';
    }
  }

  Color get _roleAccentColor {
    switch (widget.selectedRole) {
      case UserRole.driver:
        return const Color(0xFF1E3A8A); // Deep Blue
      case UserRole.inspector:
        return const Color(0xFF0F766E); // Customs Teal / Emerald
      case UserRole.owner:
        return const Color(0xFF7C2D12); // Deep Amber / Brown
    }
  }

  void _onSelectRecentLogin(LoginRecord record) {
    setState(() {
      _emailController.text = record.email;
      _passwordController.clear(); // Do not fill password
    });
  }

  void _login() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;
    final auth = AuthService.instance;

    // Check authorization first
    if (!auth.isAuthorizedEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Access restricted. Unauthorized account.')),
            ],
          ),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    // Save recent login if requested
    if (_saveRecentLogins) {
      auth.recordLogin(email);
    }

    // Save login with biometrics if selected and supported
    if (_saveBiometrics && BiometricService.instance.isBiometricSupported) {
      BiometricService.instance.saveLoginCredential(
        email: email,
        password: password,
        roleName: _roleTitle,
        enrolledOnDevice: true,
      );
    }

    _navigateToDashboard(email);
  }

  void _navigateToDashboard(String email) {
    Widget destination;
    if (email.contains('1') || email.contains('driver')) {
      destination = const DriverDashboardScreen();
    } else if (email.contains('2') || email.contains('inspect')) {
      destination = const InspectorDashboardScreen();
    } else if (email.contains('3') || email.contains('owner')) {
      destination = const ContainerOwnerDashboardScreen();
    } else if (widget.selectedRole == UserRole.driver) {
      destination = const DriverDashboardScreen();
    } else if (widget.selectedRole == UserRole.inspector) {
      destination = const InspectorDashboardScreen();
    } else {
      destination = const ContainerOwnerDashboardScreen();
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  /// 1st Step: Add fingerprint through ongoing device, get access of ongoing device,
  /// scan fingerprint using device default settings, and bind to username & password
  Future<void> _handleAddFingerprintToAccount() async {
    final bio = BiometricService.instance;
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email and password first to link your fingerprint.'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 1st: Request access of ongoing device default biometric sensor
    bool scanned = await bio.scanFingerprintWithOngoingDevice(
      reason: 'Scan fingerprint using device default settings to link with $email',
    );

    // Interactive fallback if hardware not available on current host
    if (!scanned && mounted) {
      final result = await BiometricAuthDialog.show(
        context,
        email: email,
        userName: bio.getSavedCredential(email)?.userName,
        roleName: _roleTitle,
      );
      scanned = (result == true);
    }

    if (scanned && mounted) {
      setState(() {
        bio.saveLoginCredential(
          email: email,
          password: password,
          roleName: _roleTitle,
          enrolledOnDevice: true,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.fingerprint_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Fingerprint scanned on device and linked to $email!'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF0F766E),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleBiometricAuth({String? targetEmail}) async {
    final bio = BiometricService.instance;
    String email = (targetEmail ?? _emailController.text).trim().toLowerCase();
    if (email.isEmpty) {
      if (bio.defaultCredential != null) {
        email = bio.defaultCredential!.email;
      } else if (AuthService.instance.recentLogins.isNotEmpty) {
        email = AuthService.instance.recentLogins.first.email;
      } else {
        switch (widget.selectedRole) {
          case UserRole.inspector:
            email = 'dhananjaya2@gmail.com';
            break;
          case UserRole.owner:
            email = 'dhananjaya3@gmail.com';
            break;
          case UserRole.driver:
            email = 'dhananjaya1@gmail.com';
            break;
        }
      }
      _emailController.text = email;
    }

    final saved = bio.getSavedCredential(email);

    // If no fingerprint added on device yet for this email and no saved credentials, prompt to add first
    if (saved == null || !saved.enrolledOnDevice) {
      final shouldEnroll = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.fingerprint_rounded, color: Color(0xFF0F766E), size: 24),
              SizedBox(width: 8),
              Flexible(child: Text('Add Fingerprint to Device', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17))),
            ],
          ),
          content: Text(
            '1st, you need to add your fingerprint through this ongoing device.\n\nScan your fingerprint using your device\'s default settings to link it with $email and your password.',
            style: const TextStyle(fontSize: 13.5, color: Color(0xFF334155), height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0F766E)),
              onPressed: () => Navigator.of(ctx).pop(true),
              icon: const Icon(Icons.fingerprint_rounded, size: 18),
              label: const Text('Scan & Add Fingerprint'),
            ),
          ],
        ),
      );

      if (shouldEnroll != true) return;
    }

    // 1st: Request access of ongoing device and scan using device default settings
    bool verified = await bio.scanFingerprintWithOngoingDevice(
      reason: 'Scan fingerprint on ongoing device to sign in as $email',
    );

    // Fallback if hardware prompt not active (e.g. widget test runner / desktop simulator)
    if (!verified && mounted) {
      final result = await BiometricAuthDialog.show(
        context,
        email: email,
        userName: saved?.userName,
        roleName: saved?.roleName ?? _roleTitle,
      );
      verified = (result == true);
    }

    if (verified && mounted) {
      if (_saveBiometrics) {
        bio.saveLoginCredential(
          email: email,
          password: _passwordController.text,
          roleName: _roleTitle,
          enrolledOnDevice: true,
        );
      }
      AuthService.instance.recordLogin(email);
      _navigateToDashboard(email);
    }
  }

  void _quickBiometricLogin() {
    _handleBiometricAuth();
  }

  void _navigateBackToRoleSelection() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.lock_reset_rounded, color: Color(0xFF0E3352)),
            SizedBox(width: 10),
            Text('Reset Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To reset your password or access credentials, please contact the Sri Lanka Customs ICT Helpdesk or your company coordinator.',
              style: TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.4),
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.phone_outlined, size: 18, color: Color(0xFF0E3352)),
                SizedBox(width: 10),
                Text('Hotline: +94 11 222 1900', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.mail_outline_rounded, size: 18, color: Color(0xFF0E3352)),
                SizedBox(width: 10),
                Text('Email: helpdesk@customs.gov.lk', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0E3352),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService.instance;
    final recentLogins = auth.recentLogins;
    final bio = BiometricService.instance;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── TOP NAVIGATION BACK TO ROLES ───────────────────
                    Align(
                      alignment: Alignment.centerLeft,
                      child: InkWell(
                        onTap: _navigateBackToRoleSelection,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.arrow_back_ios_new_rounded, size: 13, color: Color(0xFF334155)),
                              SizedBox(width: 6),
                              Text(
                                'Role Selection',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── TOP BRANDING HEADER ─────────────────────────────
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0E3352).withValues(alpha: 0.15),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const CgoLogo(size: 96),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'C GO',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                              color: Color(0xFF0E3352),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0E3352).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF0E3352).withValues(alpha: 0.18)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified_user_rounded, size: 13, color: Color(0xFF0E3352)),
                                SizedBox(width: 5),
                                Text(
                                  'SRI LANKA CUSTOMS • SECURE TRANSIT',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                    color: Color(0xFF0E3352),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── MAIN CREDENTIAL CARD ────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(22.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Card Title and Subtitle
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _roleTitle,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F172A),
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    const Text(
                                      'Enter your credentials to continue',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _roleAccentColor.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  widget.selectedRole == UserRole.driver
                                      ? Icons.local_shipping_outlined
                                      : widget.selectedRole == UserRole.inspector
                                          ? Icons.shield_outlined
                                          : Icons.domain_rounded,
                                  color: _roleAccentColor,
                                  size: 22,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // ── RECENT LOGINS SECTION (Always visible) ────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.history_rounded, size: 16, color: Color(0xFF0E3352)),
                                  SizedBox(width: 6),
                                  Text(
                                    'Recent Logins',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                ],
                              ),
                              if (recentLogins.isNotEmpty)
                                TextButton(
                                  onPressed: () => setState(() => auth.clearRecentLogins()),
                                  style: TextButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: const Text('Clear', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          if (recentLogins.isNotEmpty)
                            ...recentLogins.take(3).map((record) => _buildRecentLoginCard(record))
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.account_circle_outlined, size: 16, color: Color(0xFF94A3B8)),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'No recent accounts saved yet. Sign in with "Save recent login details" to keep your accounts here.',
                                      style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 16),
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          const SizedBox(height: 16),

                          // ── EMAIL FIELD ─────────────────────────────
                          const Text(
                            'Email Address',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            style: const TextStyle(fontSize: 14.5, color: Color(0xFF0F172A)),
                            decoration: InputDecoration(
                              hintText: 'your.email@example.com',
                              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
                              prefixIcon: const Icon(Icons.alternate_email_rounded, size: 19, color: Color(0xFF64748B)),
                              suffixIcon: _emailController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18, color: Color(0xFF94A3B8)),
                                      onPressed: () => setState(() => _emailController.clear()),
                                    )
                                  : null,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF0E3352), width: 1.8),
                              ),
                            ),
                            validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter your email' : null,
                          ),

                          const SizedBox(height: 16),

                          // ── PASSWORD FIELD ──────────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Password',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF334155),
                                ),
                              ),
                              GestureDetector(
                                onTap: _showForgotPasswordDialog,
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: Color(0xFF2563EB),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _login(),
                            style: const TextStyle(fontSize: 14.5, color: Color(0xFF0F172A)),
                            decoration: InputDecoration(
                              hintText: 'Enter your password',
                              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
                              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 19, color: Color(0xFF64748B)),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: const Color(0xFF94A3B8),
                                  size: 20,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF0E3352), width: 1.8),
                              ),
                            ),
                            validator: (val) => (val == null || val.isEmpty) ? 'Please enter your password' : null,
                          ),

                          const SizedBox(height: 12),

                          // ── SAVE RECENT LOGIN DETAILS CHECKBOX ──────
                          InkWell(
                            onTap: () => setState(() => _saveRecentLogins = !_saveRecentLogins),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: _saveRecentLogins,
                                      activeColor: const Color(0xFF0E3352),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                      onChanged: (val) => setState(() => _saveRecentLogins = val ?? true),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Save recent login details',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      color: Color(0xFF475569),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // ── SAVE LOGIN WITH BIOMETRICS CHECKBOX ──────
                          if (bio.isBiometricSupported) ...[
                            const SizedBox(height: 2),
                            InkWell(
                              onTap: () => setState(() => _saveBiometrics = !_saveBiometrics),
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Checkbox(
                                        value: _saveBiometrics,
                                        activeColor: const Color(0xFF0F766E),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                        onChanged: (val) => setState(() => _saveBiometrics = val ?? true),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Icon(bio.primaryBiometricIcon, size: 16, color: const Color(0xFF0F766E)),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              bio.saveBiometricsLabel,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF0F766E),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],

                          // ── ONGOING DEVICE BIOMETRIC STATUS & ENROLLMENT ──
                          if (bio.isBiometricSupported) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: bio.isFingerprintEnrolledOnDevice(_emailController.text)
                                    ? const Color(0xFFF0FDF4)
                                    : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: bio.isFingerprintEnrolledOnDevice(_emailController.text)
                                      ? const Color(0xFF86EFAC)
                                      : const Color(0xFFCBD5E1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    bio.isFingerprintEnrolledOnDevice(_emailController.text)
                                        ? Icons.verified_user_rounded
                                        : Icons.fingerprint_rounded,
                                    size: 18,
                                    color: bio.isFingerprintEnrolledOnDevice(_emailController.text)
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFF0F766E),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      bio.isFingerprintEnrolledOnDevice(_emailController.text)
                                          ? 'Fingerprint Added on Device (Default Settings)'
                                          : 'Add Fingerprint via Ongoing Device',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: bio.isFingerprintEnrolledOnDevice(_emailController.text)
                                            ? const Color(0xFF15803D)
                                            : const Color(0xFF334155),
                                      ),
                                    ),
                                  ),
                                  if (!bio.isFingerprintEnrolledOnDevice(_emailController.text))
                                    InkWell(
                                      onTap: _handleAddFingerprintToAccount,
                                      borderRadius: BorderRadius.circular(6),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0F766E),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'Scan & Add',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 18),

                          // ── PRIMARY SIGN IN BUTTON ──────────────────
                          ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0E3352),
                              foregroundColor: Colors.white,
                              elevation: 2,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.lock_open_rounded, size: 19, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ── SIGN IN WITH FINGERPRINT & FACE ID BUTTON ────────────
                          if (bio.isBiometricSupported) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: _quickBiometricLogin,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                  side: const BorderSide(color: Color(0xFF0F766E), width: 1.5),
                                  backgroundColor: const Color(0xFFF0FDFA),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.fingerprint_rounded, size: 22, color: Color(0xFF0F766E)),
                                      SizedBox(width: 4),
                                      Text('&', style: TextStyle(color: Color(0xFF0F766E), fontWeight: FontWeight.bold, fontSize: 13)),
                                      SizedBox(width: 4),
                                      Icon(Icons.face_rounded, size: 22, color: Color(0xFF0F766E)),
                                      SizedBox(width: 8),
                                      Text(
                                        'Sign In with Fingerprint & Face ID',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F766E),
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── BACK TO ROLE SELECTION ────────────────────────
                    Center(
                      child: TextButton.icon(
                        key: const ValueKey('back_to_role_selection_button'),
                        onPressed: _navigateBackToRoleSelection,
                        icon: const Icon(Icons.arrow_back_rounded, size: 18, color: Color(0xFF334155)),
                        label: const Text(
                          'Back to Role Selection',
                          style: TextStyle(
                            color: Color(0xFF334155),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ── FOOTER SECURITY BADGE ─────────────────────────
                    const Center(
                      child: Text(
                        '🔒 256-bit AES End-to-End Encryption • Sri Lanka Customs',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentLoginCard(LoginRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        onTap: () => _onSelectRecentLogin(record),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF0E3352).withValues(alpha: 0.1),
                child: const Icon(Icons.person_rounded, size: 18, color: Color(0xFF0E3352)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.userName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      '${record.email} • ${record.timeAgo}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (BiometricService.instance.hasSavedCredential(record.email))
                IconButton(
                  icon: Icon(
                    BiometricService.instance.primaryBiometricIcon,
                    size: 18,
                    color: const Color(0xFF0F766E),
                  ),
                  tooltip: 'Biometric Sign In',
                  onPressed: () => _handleBiometricAuth(targetEmail: record.email),
                ),
              IconButton(
                icon: const Icon(Icons.close, size: 16, color: Color(0xFF94A3B8)),
                tooltip: 'Remove recent login',
                onPressed: () {
                  setState(() {
                    AuthService.instance.removeRecentLogin(record.email);
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
