import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../activos/activos_screen.dart';
import '../activos/activos_provider.dart';
import '../visitas/mapa_visitas_screen.dart';
import '../visitas/historial_screen.dart';
import '../logistica/ruta_dia_screen.dart';
import '../logistica/confirmar_entregas_screen.dart';
import '../auth/auth_provider.dart';
import '../ventas/gestion_comercial_screen.dart';
import '../ventas/agenda_comercial_screen.dart';
import '../seguimiento/seguimiento_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../admin/admin_users_screen.dart';
import '../admin/admin_map_screen.dart';
import '../admin/admin_inventory_screen.dart';
import '../../core/theme_provider.dart';
import 'dashboard_provider.dart';

class DashboardLayout extends ConsumerStatefulWidget {
  const DashboardLayout({super.key});

  @override
  ConsumerState<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends ConsumerState<DashboardLayout> {
  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      if (previous?.user?.role != next.user?.role) {
        ref.read(dashboardProvider.notifier).setIndex(0);
      }
    });

    final _selectedIndex = ref.watch(dashboardProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final activos = ref.watch(activosProvider);
    final isConnected = user?.isConnected ?? true;
    final isTransportista = user?.role == UserRole.transportista;
    final isVendedor = user?.role == UserRole.vendedor;
    final isAdmin = user?.role == UserRole.admin;

    final List<Widget> screens = isAdmin
        ? [
            const AdminDashboardScreen(),
            const AdminUsersScreen(),
            const AdminMapScreen(),
            const AdminInventoryScreen(),
            const HistorialScreen(),
          ]
        : isTransportista
        ? [
            const RutaDiaScreen(),
            const ConfirmarEntregasScreen(),
            const HistorialScreen(),
          ]
        : isVendedor
            ? [
                const ActivosScreen(),
                const GestionComercialScreen(),
                const SeguimientoScreen(),
                const AgendaComercialScreen(),
                const HistorialScreen(),
              ]
            : [
                const ActivosScreen(),
                const MapaVisitasScreen(),
                const HistorialScreen(),
              ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          drawer: isMobile
              ? Drawer(
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  backgroundColor: theme.cardColor,
                  child: _buildSidebar(user, isConnected, activos.length),
                )
              : null,
          body: Row(
            children: [
              if (!isMobile) _buildSidebar(user, isConnected, activos.length),
              if (!isMobile) VerticalDivider(width: 1, thickness: 1, color: theme.dividerColor),
              // Contenido Principal
              Expanded(
                child: Column(
                  children: [
                    // Custom Header
                    Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      color: const Color(0xFF162F38),
                      child: Row(
                        children: [
                          if (isMobile)
                            Builder(
                              builder: (context) => IconButton(
                                icon: const Icon(Icons.menu, color: Colors.white, size: 22),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => Scaffold.of(context).openDrawer(),
                              ),
                            ),
                          const SizedBox(width: 8),
                          // Logo Area
                          Expanded(
                            flex: 2,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF007982),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(Icons.ac_unit, color: Colors.white, size: 16),
                                ),
                                if (constraints.maxWidth > 600) ...[
                                  const SizedBox(width: 8),
                                  const Flexible(
                                    child: Text(
                                      'ZeroCONTROL',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // Actions Area
                          Expanded(
                            flex: 5,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Connection Capsule
                                if (constraints.maxWidth > 400)
                                  GestureDetector(
                                    onTap: () {
                                      ref.read(authProvider.notifier).toggleConnection();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF243E48),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.circle,
                                              size: 8,
                                              color: isConnected ? const Color(0xFF64FFDA) : Colors.red),
                                          const SizedBox(width: 6),
                                          const Text(
                                            'Conectado',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                if (constraints.maxWidth > 400) const SizedBox(width: 8),
                                const Icon(Icons.notifications_none, color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                // User Info & Avatar
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (constraints.maxWidth > 500)
                                      Flexible(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              user?.name ?? 'Usuario',
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () => _showRoleSelector(context, ref, user?.role),
                                              child: Text(
                                                user?.roleDisplayName ?? '',
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Color(0xFF64FFDA),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                  decoration: TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    const SizedBox(width: 8),
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: const Color(0xFF546E7A),
                                      child: Text(
                                        user?.name.substring(0, 1).toUpperCase() ?? 'U',
                                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(child: screens[_selectedIndex]),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRoleSelector(BuildContext context, WidgetRef ref, UserRole? currentRole) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar rol operativo', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: UserRole.values.map((role) {
            final isSelected = role == currentRole;
            String label = '';
            if (role == UserRole.tecnico) label = 'Técnico';
            if (role == UserRole.vendedor) label = 'Vendedor';
            if (role == UserRole.transportista) label = 'Transportista';
            if (role == UserRole.admin) label = 'Administrador';

            return ListTile(
              leading: Icon(
                role == UserRole.tecnico ? Icons.build_outlined : 
                role == UserRole.vendedor ? Icons.people_outline : 
                role == UserRole.transportista ? Icons.local_shipping_outlined :
                Icons.admin_panel_settings_outlined,
                color: isSelected ? const Color(0xFF007982) : Colors.grey,
              ),
              title: Text(label, style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF007982) : Colors.black87,
              )),
              trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF007982)) : null,
              onTap: () {
                ref.read(authProvider.notifier).changeRole(role);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Rol cambiado a $label')),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSidebar(UserProfile? user, bool isConnected, int activosCount) {
    final selectedIndex = ref.watch(dashboardProvider);
    final isTransportista = user?.role == UserRole.transportista;
    final isAdmin = user?.role == UserRole.admin;
    final isVendedor = user?.role == UserRole.vendedor;
    
    final activosCompletados = ref.watch(activosProvider).where((a) => a.status == 'Completada').length;
    final activosPendientes = ref.watch(activosProvider).where((a) => a.status != 'Completada').length;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 280,
      color: theme.cardColor,
      child: Column(
        children: [
          const SizedBox(height: 32),
          // Logo (Foto 2 style)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF007982),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.ac_unit, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                const Text(
                  'ZeroCONTROL',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF007982),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Perfil Card (Foto 2 style)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFEDF8F9),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF007982),
                  child: Text(
                    (user != null && user.name.isNotEmpty) ? user.name.substring(0, 1).toUpperCase() : 'U',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Usuario',
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 16, 
                          color: isDark ? Colors.white : const Color(0xFF1E3A44)
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      GestureDetector(
                        onTap: () => _showRoleSelector(context, ref, user?.role),
                        child: Text(
                          user?.roleDisplayName ?? '',
                          style: const TextStyle(
                            color: Color(0xFF007982),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Menu Items based on Role
          if (isAdmin) ...[
            _SidebarItem(
              icon: Icons.dashboard_outlined,
              label: 'Dashboard Global',
              isSelected: selectedIndex == 0,
              onTap: () {
                ref.read(dashboardProvider.notifier).setIndex(0);
                if (Scaffold.of(context).hasDrawer && Scaffold.of(context).isDrawerOpen) Navigator.pop(context);
              },
            ),
            _SidebarItem(
              icon: Icons.people_alt_outlined,
              label: 'Gestión Usuarios',
              isSelected: selectedIndex == 1,
              badge: ref.watch(authProvider).registeredUsers.length.toString(),
              onTap: () {
                ref.read(dashboardProvider.notifier).setIndex(1);
                if (Scaffold.of(context).hasDrawer && Scaffold.of(context).isDrawerOpen) Navigator.pop(context);
              },
            ),
            _SidebarItem(
              icon: Icons.map_outlined,
              label: 'Mapa Maestro',
              isSelected: selectedIndex == 2,
              onTap: () {
                ref.read(dashboardProvider.notifier).setIndex(2);
                if (Scaffold.of(context).hasDrawer && Scaffold.of(context).isDrawerOpen) Navigator.pop(context);
              },
            ),
            _SidebarItem(
              icon: Icons.inventory_2_outlined,
              label: 'Inventario Maestro',
              isSelected: selectedIndex == 3,
              badge: activosCount.toString(),
              onTap: () {
                ref.read(dashboardProvider.notifier).setIndex(3);
                if (Scaffold.of(context).hasDrawer && Scaffold.of(context).isDrawerOpen) Navigator.pop(context);
              },
            ),
          ] else if (isTransportista) ...[
            _SidebarItem(
              icon: Icons.local_shipping_outlined,
              label: 'Ruta del día',
              isSelected: selectedIndex == 0,
              badge: activosPendientes.toString(),
              onTap: () {
                ref.read(dashboardProvider.notifier).setIndex(0);
                if (Scaffold.of(context).hasDrawer && Scaffold.of(context).isDrawerOpen) Navigator.pop(context);
              },
            ),
            _SidebarItem(
              icon: Icons.assignment_turned_in_outlined,
              label: 'Confirmar entregas',
              isSelected: selectedIndex == 1,
              onTap: () {
                ref.read(dashboardProvider.notifier).setIndex(1);
                if (Scaffold.of(context).hasDrawer && Scaffold.of(context).isDrawerOpen) Navigator.pop(context);
              },
            ),
            _SidebarItem(
              icon: Icons.history,
              label: 'Historial',
              isSelected: selectedIndex == 2,
              badge: activosCompletados > 0 ? activosCompletados.toString() : null,
              onTap: () {
                ref.read(dashboardProvider.notifier).setIndex(2);
                if (Scaffold.of(context).hasDrawer && Scaffold.of(context).isDrawerOpen) Navigator.pop(context);
              },
            ),
          ] else if (user?.role == UserRole.vendedor) ...[
            _SidebarItem(
              icon: Icons.people_alt_outlined,
              label: 'Mis clientes',
              isSelected: selectedIndex == 0,
              badge: "10",
              onTap: () {
                ref.read(dashboardProvider.notifier).setIndex(0);
                if (Scaffold.of(context).hasDrawer && Scaffold.of(context).isDrawerOpen) Navigator.pop(context);
              },
            ),
            _SidebarItem(
              icon: Icons.inventory_2_outlined,
              label: 'Vender',
              isSelected: selectedIndex == 1,
              onTap: () {
                ref.read(dashboardProvider.notifier).setIndex(1);
                if (Scaffold.of(context).hasDrawer && Scaffold.of(context).isDrawerOpen) Navigator.pop(context);
              },
            ),
            _SidebarItem(
              icon: Icons.share_location_outlined,
              label: 'Seguimiento',
              isSelected: selectedIndex == 2,
              onTap: () {
                ref.read(dashboardProvider.notifier).setIndex(2);
                if (Scaffold.of(context).hasDrawer && Scaffold.of(context).isDrawerOpen) Navigator.pop(context);
              },
            ),
            _SidebarItem(
              icon: Icons.assignment_turned_in_outlined,
              label: 'Agenda comercial',
              isSelected: selectedIndex == 3,
              onTap: () {
                ref.read(dashboardProvider.notifier).setIndex(3);
                if (Scaffold.of(context).hasDrawer && Scaffold.of(context).isDrawerOpen) Navigator.pop(context);
              },
            ),
            _SidebarItem(
              icon: Icons.history,
              label: 'Historial',
              isSelected: selectedIndex == 4,
              onTap: () {
                ref.read(dashboardProvider.notifier).setIndex(4);
                if (Scaffold.of(context).hasDrawer && Scaffold.of(context).isDrawerOpen) Navigator.pop(context);
              },
            ),
          ] else ...[
            _SidebarItem(
              icon: Icons.inventory_2_outlined,
              label: 'Mis activos',
              isSelected: selectedIndex == 0,
              badge: activosCount.toString(),
              onTap: () {
                ref.read(dashboardProvider.notifier).setIndex(0);
                if (Scaffold.of(context).hasDrawer && Scaffold.of(context).isDrawerOpen) Navigator.pop(context);
              },
            ),
            _SidebarItem(
              icon: Icons.location_on_outlined,
              label: 'Mapa de visitas',
              isSelected: selectedIndex == 1,
              onTap: () {
                ref.read(dashboardProvider.notifier).setIndex(1);
                if (Scaffold.of(context).hasDrawer && Scaffold.of(context).isDrawerOpen) Navigator.pop(context);
              },
            ),
            _SidebarItem(
              icon: Icons.history,
              label: 'Historial',
              isSelected: selectedIndex == 2,
              onTap: () {
                ref.read(dashboardProvider.notifier).setIndex(2);
                if (Scaffold.of(context).hasDrawer && Scaffold.of(context).isDrawerOpen) Navigator.pop(context);
              },
            ),
          ],
          const Spacer(),
          // Logout Item
          _SidebarItem(
            icon: Icons.logout,
            label: 'Cerrar sesión',
            isSelected: false,
            onTap: () {
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
          ),
          const SizedBox(height: 8),
          // Connection Card (Online/Offline)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(isConnected ? Icons.cloud_outlined : Icons.cloud_off_outlined,
                      color: const Color(0xFF546E7A), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isConnected ? 'Modo online activo' : 'Modo offline activo',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A44),
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          isConnected ? 'Sincronizado' : 'Pendiente de sincronizar',
                          style: const TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // User Session Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 12),
                const Text(
                  'SESIÓN ACTIVA:',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'hola1234@gmail.com',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF007982)),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          // Help Center & Theme Toggle
          Padding(
            padding: const EdgeInsets.only(bottom: 24, right: 16),
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                leading: Icon(Icons.help_outline, color: isDark ? Colors.white70 : Colors.grey, size: 22),
                title: Text(
                  'Centro de ayuda',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : const Color(0xFF546E7A), 
                    fontSize: 14, 
                    fontWeight: FontWeight.w500
                  ),
                ),
                trailing: IconButton(
                  onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
                  icon: Icon(
                    ref.watch(themeProvider) == ThemeMode.dark 
                      ? Icons.light_mode_outlined 
                      : Icons.dark_mode_outlined,
                    color: const Color(0xFF64FFDA),
                  ),
                ),
                onTap: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final String? badge;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE0F2F1) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(color: const Color(0xFF007982), width: 1.5)
                : null,
          ),
          child: Row(
            children: [
              Icon(icon,
                  size: 24,
                  color: isSelected ? const Color(0xFF007982) : const Color(0xFF546E7A)),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? const Color(0xFF007982) : const Color(0xFF546E7A),
                    fontSize: 15,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : const Color(0xFFF1F3F4),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFF007982) : Colors.grey,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
