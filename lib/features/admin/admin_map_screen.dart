import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_provider.dart';

class AdminMapScreen extends ConsumerWidget {
  const AdminMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final users = authState.registeredUsers;
    
    // Filtrar usuarios con ubicación (o asignar una aleatoria para el prototipo)
    final usersWithLocation = users.map((u) {
      if (u.lat == null) {
        // Simulación: Si no tiene GPS, le damos una posición fija cerca del "centro" del mapa
        return u.copyWith(
          lat: 0.5 + (users.indexOf(u) * 0.1), 
          lng: 0.5 + (users.indexOf(u) * 0.05)
        );
      }
      return u;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // Background "Map" (Simulated)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://static.vecteezy.com/system/resources/previews/000/664/225/original/street-map-of-a-city-vector.jpg'),
                fit: BoxFit.cover,
                opacity: 0.3,
              ),
            ),
          ),
          
          // Map Markers Reales basados en la lista de usuarios
          ...usersWithLocation.map((u) {
            // Convertimos coordenadas 0.0-1.0 a porcentajes de pantalla para el prototipo
            final top = (u.lat ?? 0.5) * MediaQuery.of(context).size.height;
            final left = (u.lng ?? 0.5) * MediaQuery.of(context).size.width;
            
            return _MapMarker(
              top: top % (MediaQuery.of(context).size.height - 100), 
              left: left % (MediaQuery.of(context).size.width - 200), 
              name: u.name, 
              status: u.isConnected ? 'Online' : 'Offline', 
              color: _getRoleColor(u.role)
            );
          }).toList(),
          
          // Control Panel Overlay
          Positioned(
            top: 32,
            left: 32,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('MONITOREO GPS', style: TextStyle(color: Color(0xFF007982), fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Flota en Tiempo Real', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _MapStat(label: 'Total Usuarios', value: '${users.length}', color: Colors.green),
                  _MapStat(label: 'Conectados', value: '${users.where((u) => u.isConnected).length}', color: Colors.blue),
                  _MapStat(label: 'Vendedores', value: '${users.where((u) => u.role == UserRole.vendedor).length}', color: Colors.orange),
                  const Divider(height: 32),
                  SizedBox(
                    width: 200,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar operario...',
                        prefixIcon: const Icon(Icons.search, size: 18),
                        filled: true,
                        fillColor: const Color(0xFFF8F9FA),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin: return Colors.purple;
      case UserRole.vendedor: return Colors.orange;
      case UserRole.transportista: return Colors.blue;
      case UserRole.tecnico: return const Color(0xFF007982);
    }
  }
}

class _MapMarker extends StatelessWidget {
  final double top;
  final double left;
  final String name;
  final String status;
  final Color color;

  const _MapMarker({required this.top, required this.left, required this.name, required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
            ),
            child: Column(
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Icon(Icons.location_on, color: color, size: 32),
        ],
      ),
    );
  }
}

class _MapStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MapStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
