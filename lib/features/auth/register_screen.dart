import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _pinController = TextEditingController();
  UserRole _selectedRole = UserRole.admin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF007982)),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Center(
              child: Column(
                children: [
                  Icon(Icons.person_add_outlined, size: 80, color: Color(0xFF007982)),
                  SizedBox(height: 16),
                  Text(
                    'Crear cuenta',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A44),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Únete a ZeroCONTROL para gestionar\nactivos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
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
                  const Text('Nombre completo', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Tu nombre',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Correo Gmail', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      hintText: 'usuario@gmail.com',
                      prefixIcon: Icon(Icons.mail_outline),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Contraseña', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _pinController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'Ingresa tu contraseña',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Tipo de usuario', style: TextStyle(fontWeight: FontWeight.bold)),
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
                          onTap: () => setState(() => _selectedRole = role),
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFE0F2F1) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF007982) : Colors.grey.shade300,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(icon, color: isSelected ? const Color(0xFF007982) : Colors.grey, size: 24),
                                const SizedBox(height: 8),
                                Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? const Color(0xFF007982) : Colors.grey,
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
                  ElevatedButton(
                    onPressed: () async {
                      final name = _nameController.text.trim();
                      final email = _emailController.text.trim();
                      final pin = _pinController.text.trim();

                      if (name.isEmpty || email.isEmpty || pin.isEmpty) {
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

                      final success = await ref.read(authProvider.notifier).register(
                        name,
                        email,
                        _selectedRole,
                        pin,
                      );

                      if (success) {
                        context.go('/splash');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Este email ya está registrado.')),
                        );
                      }
                    },
                    child: const Text('Registrarme ahora'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
