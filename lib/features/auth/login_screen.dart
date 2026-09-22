import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  UserRole _selectedRole = UserRole.admin;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF007982),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.ac_unit, color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'ZeroCONTROL',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A44),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'ACCESO OPERACIONAL',
                style: TextStyle(
                  color: Color(0xFF007982),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Tu trabajo en terreno,\nbajo control.',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A44),
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Registra visitas y gestiona tus activos refrigerados desde cualquier lugar.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Correo electrónico',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        GestureDetector(
                          onTap: () {},
                          child: const Text('¿Necesitas ayuda?',
                              style: TextStyle(
                                  color: Color(0xFF007982),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      enabled: !authState.isBlocked,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        hintText: 'usuario@gmail.com',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Contraseña',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passController,
                      obscureText: true,
                      enabled: !authState.isBlocked,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        hintText: 'Ingresa tu contraseña',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => context.push('/forgot-password'),
                        child: const Text(
                          '¿Olvidaste tu contraseña?',
                          style: TextStyle(
                            color: Color(0xFF007982),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    if (authState.loginAttempts > 0 && !authState.isBlocked)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Intentos fallidos: ${authState.loginAttempts}/3',
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tipo de usuario',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        GestureDetector(
                          onTap: () => context.push('/register'),
                          child: const Text('Registrarme',
                              style: TextStyle(
                                  color: Color(0xFF007982),
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: UserRole.values.map((role) {
                          final isSelected = _selectedRole == role;
                          String label = '';
                          IconData icon = Icons.help_outline;
                          
                          if (role == UserRole.tecnico) {
                            label = 'Técnico';
                            icon = Icons.build_outlined;
                          } else if (role == UserRole.vendedor) {
                            label = 'Vendedor';
                            icon = Icons.people_outline;
                          } else if (role == UserRole.transportista) {
                            label = 'Transportista';
                            icon = Icons.local_shipping_outlined;
                          } else if (role == UserRole.admin) {
                            label = 'Administrador';
                            icon = Icons.admin_panel_settings_outlined;
                          }

                          return GestureDetector(
                            onTap: authState.isBlocked ? null : () => setState(() => _selectedRole = role),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              constraints: const BoxConstraints(minWidth: 90),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFE0F2F1) : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF007982) : const Color(0xFFCFD8DC),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(icon,
                                      size: 20, color: isSelected ? const Color(0xFF007982) : Colors.grey),
                                  const SizedBox(height: 4),
                                  Text(
                                    label,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isSelected ? const Color(0xFF007982) : Colors.grey,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (authState.isBlocked)
                      Column(
                        children: [
                          const Text(
                            'Cuenta bloqueada por demasiados intentos.',
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: () {
                              ref.read(authProvider.notifier).restorePassword();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Contraseña restaurada. Puedes intentar de nuevo.')),
                              );
                            },
                            child: const Text('Restaurar contraseña'),
                          ),
                        ],
                      )
                    else
                      ElevatedButton(
                        onPressed: () async {
                          final email = _emailController.text.trim();
                          final pass = _passController.text.trim();
                          
                          if (email.isEmpty || pass.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Por favor, completa todos los campos.')),
                            );
                            return;
                          }

                          if (!email.endsWith('@gmail.com')) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Solo se permiten cuentas de Gmail.')),
                            );
                            return;
                          }

                          final success = await ref.read(authProvider.notifier).login(
                                email,
                                pass,
                              );
                          
                          if (success) {
                            context.go('/splash');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Email o contraseña incorrectos.')),
                            );
                          }
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Iniciar sesión'),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.security, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          'Acceso seguro y protegido por ZeroCONTROL',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    Text(
                      '© 2026 ZeroCONTROL · Operaciones inteligentes en terreno',
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
