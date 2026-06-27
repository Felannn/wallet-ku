import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/services/deeplink_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/local/secure_storage_datasource.dart';
import '../../../injection/injection_container.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_logo.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _needsBiometricUnlock = false;
  bool _authenticating = false;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthCheckRequested());
  }

  Future<void> _checkBiometric(AuthState state) async {
    if (state is AuthAuthenticated) {
      final isBioEnabled = await sl<SecureStorageDatasource>().getBiometricEnabled();
      final isBioAvailable = await sl<BiometricService>().isBiometricAvailable();
      if (isBioEnabled && isBioAvailable) {
        setState(() {
          _needsBiometricUnlock = true;
        });
        _startBiometricUnlock();
      } else {
        _navigateForward();
      }
    }
  }

  Future<void> _startBiometricUnlock() async {
    setState(() {
      _authenticating = true;
    });
    final success = await sl<BiometricService>().authenticate();
    if (success) {
      _navigateForward();
    } else {
      if (mounted) {
        setState(() {
          _authenticating = false;
        });
      }
    }
  }

  void _navigateForward() {
    final pending = DeeplinkService.consumePending();
    if (pending != null) {
      context.go('/pay', extra: pending);
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _checkBiometric(state);
        } else if (state is AuthUnauthenticated) {
          setState(() {
            _needsBiometricUnlock = false;
          });
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          child: SafeArea(
            child: Stack(
              children: [
                // Decorative circles
                Positioned(
                  top: -120,
                  right: -90,
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 120,
                  left: -100,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.07),
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const Spacer(),
                      const AppLogo(size: 92, light: true),
                      const SizedBox(height: 26),
                      const Text(
                        'Wallet Ku',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_needsBiometricUnlock) ...[
                        const Icon(
                          Icons.fingerprint_rounded,
                          size: 72,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _authenticating
                              ? 'Memverifikasi sidik jari...'
                              : 'Aplikasi Terkunci\nSilakan gunakan sidik jari untuk masuk.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 15,
                            color: Colors.white,
                            height: 1.5,
                          ),
                        ),
                      ] else ...[
                        const Text(
                          'Bayar, transfer, dan kelola uang\ndalam satu aplikasi yang aman.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 15,
                            color: Colors.white,
                            height: 1.5,
                          ),
                        ),
                      ],
                      const Spacer(),
                      if (_needsBiometricUnlock) ...[
                        if (!_authenticating) ...[
                          AppButton(
                            label: 'Buka dengan Sidik Jari',
                            variant: AppButtonVariant.white,
                            onPressed: _startBiometricUnlock,
                          ),
                          const SizedBox(height: 11),
                          TextButton(
                            onPressed: () {
                              context.read<AuthBloc>().add(AuthLogoutRequested());
                            },
                            child: const Text(
                              'Keluar dari Akun',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ] else ...[
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          ),
                        ],
                      ] else ...[
                        Column(
                          children: [
                            AppButton(
                              label: 'Buat Akun Baru',
                              variant: AppButtonVariant.white,
                              onPressed: () => context.push('/register'),
                            ),
                            const SizedBox(height: 11),
                            AppButton(
                              label: 'Masuk ke Akun',
                              variant: AppButtonVariant.outlineWhite,
                              onPressed: () => context.push('/login'),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
