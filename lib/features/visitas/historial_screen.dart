import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../activos/activos_provider.dart';
import '../logistica/entregas_provider.dart';
import '../auth/auth_provider.dart';
import '../ventas/ventas_provider.dart';

class HistorialScreen extends ConsumerWidget {
  const HistorialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isTransportista = user?.role == UserRole.transportista;
    final isVendedor = user?.role == UserRole.vendedor;

    final activos = ref.watch(activosProvider);
    final entregas = ref.watch(entregasProvider);
    final ventasState = ref.watch(ventasProvider);

    final completadasActivos = activos.where((a) => a.status == 'Completada').toList();
    final completadasEntregas = entregas.where((e) => e.status == EntregaStatus.completada).toList();
    final completadasVentas = ventasState.ventas.where((v) => v.status == 'Completada').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('REGISTROS HISTÓRICOS',
              style: TextStyle(
                  color: Color(0xFF007982),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1)),
          const SizedBox(height: 8),
          Text(isVendedor ? 'Historial de ventas' : 'Historial de visitas',
              style: const TextStyle(
                  fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF1E3A44))),
          const SizedBox(height: 4),
          Text(isVendedor ? 'Registro de todas las ventas finalizadas.' : 'Registro de todas las actividades finalizadas en terreno.',
              style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 32),
          if (completadasActivos.isEmpty && completadasEntregas.isEmpty && completadasVentas.isEmpty)
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 64),
                  Icon(Icons.history, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('No hay registros completados aún',
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            )
          else ...[
            if (isVendedor && completadasVentas.isNotEmpty) ...[
              const Text('VENTAS FINALIZADAS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 16),
              _buildVentasHistory(completadasVentas),
              const SizedBox(height: 32),
            ],
            if (completadasEntregas.isNotEmpty) ...[
              const Text('ENTREGAS REALIZADAS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 16),
              _buildEntregasHistory(completadasEntregas),
              const SizedBox(height: 32),
            ],
            if (completadasActivos.isNotEmpty) ...[
              const Text('VISITAS TÉCNICAS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 16),
              _buildActivosHistory(completadasActivos),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildEntregasHistory(List<Entrega> entregas) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entregas.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = entregas[index];
        final fechaStr = item.fechaConfirmacion != null 
            ? DateFormat('dd/MM/yyyy HH:mm').format(item.fechaConfirmacion!)
            : 'Hoy';

        return _HistoryItem(
          id: item.id,
          title: 'Entrega a ${item.cliente}',
          subtitle: item.direccion,
          date: fechaStr,
          icon: Icons.local_shipping_outlined,
          color: Colors.blue,
        );
      },
    );
  }

  Widget _buildVentasHistory(List<Venta> ventas) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ventas.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = ventas[index];
        final fechaStr = DateFormat('dd/MM/yyyy HH:mm').format(item.fecha);

        return _HistoryItem(
          id: item.id,
          title: 'Venta: ${item.productoNombre}',
          subtitle: 'Cliente: ${item.clienteNombre}',
          date: fechaStr,
          icon: Icons.shopping_bag_outlined,
          color: Colors.teal,
        );
      },
    );
  }

  Widget _buildActivosHistory(List<Activo> activos) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activos.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = activos[index];
        final fechaStr = item.fechaVisita != null 
            ? DateFormat('dd/MM/yyyy HH:mm').format(item.fechaVisita!)
            : 'Fecha no disponible';

        return _HistoryItem(
          id: item.id,
          title: item.name,
          subtitle: item.location,
          date: fechaStr,
          icon: Icons.check_circle_outline,
          color: Colors.green,
        );
      },
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final String id;
  final String title;
  final String subtitle;
  final String date;
  final IconData icon;
  final Color color;

  const _HistoryItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(id,
                        style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                    Text(date,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A44),
                        fontSize: 16)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        color: Color(0xFF546E7A), fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
