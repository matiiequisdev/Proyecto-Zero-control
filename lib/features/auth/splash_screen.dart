import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        context.go('/dashboard');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isInitialized = authState.isInitialized;

    if (!isInitialized) {
      return const Scaffold(
        backgroundColor: Color(0xFF007982),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF007982),
      body: Stack(
        children: [
          // Copos de nieve decorativos
          ...List.generate(15, (index) {
            return Positioned(
              top: (index * 60.0) % MediaQuery.of(context).size.height,
              left: (index * 50.0) % MediaQuery.of(context).size.width,
              child: FadeIn(
                delay: Duration(milliseconds: index * 200),
                child: const Icon(Icons.ac_unit, color: Colors.white24, size: 24),
              ),
            );
          }),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ZoomIn(
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                    ),
                    child: const Center(
                      child: Icon(Icons.kitchen, color: Colors.white, size: 70),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                FadeInDown(
                  child: const Text(
                    'INICIANDO SISTEMA DE FRÍO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: Text(
                    user != null 
                      ? 'Preparando entorno para ${user.roleDisplayName.toLowerCase()}...'
                      : 'Cargando sesión...',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FadeInUp(
                  delay: const Duration(milliseconds: 800),
                  child: Text(
                    user != null ? 'Bienvenido, ${user.name}' : 'Iniciando ZeroCONTROL',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
