import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_provider.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isInitialLoading = true);
    await ref.read(authProvider.notifier).refreshUsers();
    if (mounted) setState(() => _isInitialLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final users = authState.registeredUsers;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Gestión de Usuarios Real', style: TextStyle(color: Color(0xFF1E3A44), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF007982)),
            onPressed: _loadData,
          )
        ],
      ),
      body: _isInitialLoading 
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Color(0xFF007982)),
                SizedBox(height: 20),
                Text('Conectando a MySQL en XAMPP...', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
              ],
            ),
          )
        : users.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_off_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No se encontraron usuarios en MySQL', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Asegúrate de que tus archivos PHP estén en htdocs/zerocontrol', textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ElevatedButton(onPressed: _loadData, child: const Text('Reintentar conexión')),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final u = users[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                  borderOnForeground: true,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF007982).withOpacity(0.1),
                      child: Text(u.name.substring(0, 1).toUpperCase(), style: const TextStyle(color: Color(0xFF007982), fontWeight: FontWeight.bold)),
                    ),
                    title: Text(u.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(u.email, style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFF007982).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text(u.roleDisplayName, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF007982))),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Cambiar Rol',
                          icon: const Icon(Icons.manage_accounts, color: Colors.teal, size: 20),
                          onPressed: () => _showChangeRoleDialog(context, ref, u),
                        ),
                        IconButton(
                          tooltip: 'Cambiar Contraseña',
                          icon: const Icon(Icons.lock_reset, color: Colors.blue, size: 20),
                          onPressed: () => _showChangePasswordDialog(context, ref, u.email),
                        ),
                        IconButton(
                          tooltip: u.isBlocked ? 'Desbloquear' : 'Bloquear',
                          icon: Icon(u.isBlocked ? Icons.lock : Icons.lock_open, 
                              color: u.isBlocked ? Colors.orange : Colors.green, size: 20),
                          onPressed: () async {
                             await ref.read(authProvider.notifier).blockUser(u.email, !u.isBlocked);
                             _loadData();
                          },
                        ),
                        IconButton(
                          tooltip: 'Eliminar Usuario',
                          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                          onPressed: () => _showDeleteConfirmDialog(context, ref, u),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, WidgetRef ref, UserProfile user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar usuario?'),
        content: Text('Esta acción eliminará permanentemente a ${user.name} de la base de datos MySQL.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              await ref.read(authProvider.notifier).deleteUser(user.email);
              if (mounted) Navigator.pop(context);
              _loadData();
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref, String email) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Clave'),
        content: TextField(
          controller: controller, 
          obscureText: true,
          decoration: const InputDecoration(hintText: 'Ingresa la nueva contraseña'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await ref.read(authProvider.notifier).changePasswordAdmin(email, controller.text);
                if (mounted) Navigator.pop(context);
                _loadData();
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showChangeRoleDialog(BuildContext context, WidgetRef ref, UserProfile user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cambiar Rol: ${user.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: UserRole.values.map((role) {
            return ListTile(
              title: Text(role.name.toUpperCase()),
              onTap: () async {
                await ref.read(authProvider.notifier).adminUpdateUserRole(user.email, role);
                if (mounted) Navigator.pop(context);
                _loadData();
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
