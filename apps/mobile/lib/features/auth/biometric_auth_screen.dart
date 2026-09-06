import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import 'auth_provider.dart';

class BiometricAuthScreen extends ConsumerStatefulWidget {
  const BiometricAuthScreen({super.key});

  @override
  ConsumerState<BiometricAuthScreen> createState() => _BiometricAuthScreenState();
}

class _BiometricAuthScreenState extends ConsumerState<BiometricAuthScreen> {
  late final TextEditingController _badgeController;

  @override
  void initState() {
    super.initState();
    final currentBadge = ref.read(authProvider).badgeId;
    _badgeController = TextEditingController(text: currentBadge);
  }

  @override
  void dispose() {
    _badgeController.dispose();
    super.dispose();
  }

  Future<void> _handleAuthenticate() async {
    HapticFeedback.mediumImpact();
    ref.read(authProvider.notifier).updateBadgeId(_badgeController.text);
    final success = await ref.read(authProvider.notifier).authenticateWithBiometrics();

    if (success && mounted) {
      HapticFeedback.heavyImpact();
      context.go('/ndps-checklist');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: DSColors.bgAbyssal,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // ── Header Bar: Defense Authority ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: DSColors.surfaceCarbon,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: DSColors.surfaceBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: DSColors.accentEmerald,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'DEFENSE NODE #01',
                          style: DSTypography.monoSmall.copyWith(
                            color: DSColors.accentEmerald,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'NDPS-ACT-1985',
                    style: DSTypography.monoSmall.copyWith(
                      color: DSColors.textSecondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Shield Emblem & Title ──
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: DSColors.accentEmerald.withOpacity(0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: DSColors.accentEmerald.withOpacity(0.35),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.security_outlined,
                    color: DSColors.accentEmerald,
                    size: 38,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Center(
                child: Text(
                  'DRUGSHIELD',
                  style: DSTypography.headline1.copyWith(
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  'Tactical Field Evidence & Colorimetric Suite',
                  style: DSTypography.body.copyWith(
                    color: DSColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ── Officer Credential Input ──
              Text(
                'OFFICER CREDENTIAL / BADGE ID',
                style: DSTypography.label.copyWith(
                  fontSize: 12,
                  letterSpacing: 1.0,
                  color: DSColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _badgeController,
                style: DSTypography.mono.copyWith(
                  fontSize: 18,
                  color: DSColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.badge_outlined, color: DSColors.hudCyan),
                  hintText: 'e.g. NCB-HYD-0472',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.qr_code_scanner, color: DSColors.hudCyan),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Badge scanner active')),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Hardware KeyStore Security Status Card ──
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: DSColors.surfaceCarbon,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: DSColors.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.lock_outline,
                              color: DSColors.accentEmerald,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'HARDWARE KEYSTORE STATUS',
                              style: DSTypography.label.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: DSColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: DSColors.accentEmerald.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: DSColors.accentEmerald.withOpacity(0.4)),
                          ),
                          child: Text(
                            authState.keyStoreLevel == KeyStoreSecurityLevel.strongBox
                                ? 'STRONGBOX READY'
                                : 'TEE ENCLAVE',
                            style: DSTypography.monoSmall.copyWith(
                              color: DSColors.accentEmerald,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'ECDSA secp256r1 hardware cryptographic signing chip ready. Non-extractable key pairs enforce Indian Evidence Act chain-of-custody compliance.',
                      style: DSTypography.body.copyWith(
                        fontSize: 12,
                        color: DSColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              if (authState.authError != null) ...[
                const SizedBox(height: 12),
                Text(
                  authState.authError!,
                  style: DSTypography.monoSmall.copyWith(color: DSColors.accentCrimson),
                ),
              ],

              const Spacer(),

              // ── Primary Biometric Trigger Button (Thumb-Zone Pinned) ──
              SizedBox(
                height: 58,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: authState.isAuthenticating ? null : _handleAuthenticate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DSColors.accentEmerald,
                    foregroundColor: DSColors.bgAbyssal,
                    elevation: 4,
                    shadowColor: DSColors.accentEmerald.withOpacity(0.4),
                  ),
                  child: authState.isAuthenticating
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: DSColors.bgAbyssal,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('VERIFYING BIOMETRICS...'),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.fingerprint, size: 26),
                            SizedBox(width: 12),
                            Text('BIOMETRIC UNLOCK & SIGN IN'),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 12),

              Center(
                child: Text(
                  'SIH26231 • MIL-STD-1472 Thumb-Zone Compliant',
                  style: DSTypography.monoSmall.copyWith(fontSize: 10),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
