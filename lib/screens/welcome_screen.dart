import 'package:flutter/material.dart';
import '../models/user_role.dart';
import '../widgets/cgo_logo.dart';
import 'login_screen.dart';

/// Screen implementing SRS Figure 8: Mobile Welcome Page
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _onSelectRole(BuildContext context, UserRole role) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LoginScreen(selectedRole: role),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),

              // ── Top CGO SECURE TRANSIT Circular Emblem (Figure 8) ───
              const Center(
                child: CgoLogo(size: 130),
              ),

              const SizedBox(height: 36),

              // ── Title & Subtitle ─────────────────────────────────────
              const Text(
                'Welcome Back',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select your role to continue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 36),

              // ── Card 1: Truck Driver (Figure 8) ──────────────────────
              _buildRoleCard(
                context: context,
                role: UserRole.driver,
                title: 'Truck Driver',
                subtitle: 'Access navigation and trip details',
                icon: Icons.local_shipping_outlined,
                onTap: () => _onSelectRole(context, UserRole.driver),
              ),

              const SizedBox(height: 16),

              // ── Card 2: Container Owner (Figure 8) ───────────────────
              _buildRoleCard(
                context: context,
                role: UserRole.owner,
                title: 'Container Owner',
                subtitle: 'Monitor and track your containers',
                icon: Icons.all_inbox_rounded,
                onTap: () => _onSelectRole(context, UserRole.owner),
              ),

              const SizedBox(height: 16),

              // ── Card 3: Customs Inspector (SRS Field App & User Request) ─
              _buildRoleCard(
                context: context,
                role: UserRole.inspector,
                title: 'Customs Inspector',
                subtitle: 'Verify seals, check containers & smart locks',
                icon: Icons.verified_user_outlined,
                onTap: () => _onSelectRole(context, UserRole.inspector),
              ),

              const SizedBox(height: 40),

              // Footer branding
              Text(
                'Sri Lanka Customs • SecureTrack SL',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required UserRole role,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          child: Row(
            children: [
              // Icon container with soft blue tint
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF), // soft blue
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF2563EB),
                  size: 28,
                ),
              ),
              const SizedBox(width: 18),
              // Text column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
