import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../auth/auth_provider.dart';
import '../ventas/ventas_provider.dart';
import 'activos_provider.dart';

class ActivosScreen extends ConsumerWidget {
  const ActivosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final activos = ref.watch(activosProvider);
    final ventasState = ref.watch(ventasProvider);
    final isVendedor = user?.role == UserRole.vendedor;
    
    final now = DateTime.now();
    final headerDate = DateFormat("EEEE dd MMM", 'es').format(now).toUpperCase();
    final monthShort = DateFormat("MMM", 'es').format(now).toUpperCase();
    final dayStr = DateFormat("dd").format(now);
    final yearStr = DateFormat("yyyy").format(now);

    final pendientesCount = isVendedor 
        ? ventasState.ventas.where((v) => v.status == 'Pendiente').length
        : activos.where((a) => a.status != 'Completada').length;
    
    final completadasCount = isVendedor
        ? ventasState.ventas.where((v) => v.status == 'Completada').length
        : activos.where((a) => a.status == 'Completada').length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('MI JORNADA · $headerDate',
                            style: const TextStyle(
                                color: Color(0xFF007982),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                'Hola, ${user?.name ?? 'Matias'}',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: isMobile ? 24 : 32, fontWeight: FontWeight.bold, color: const Color(0xFF1E3A44)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.auto_awesome, color: Color(0xFF1E3A44), size: 24),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isVendedor 
                              ? 'Tienes $pendientesCount compras pendientes para hoy.'
                              : 'Tienes $pendientesCount visitas pendientes para hoy.',
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Date Card
                  if (!isMobile)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(monthShort,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                          Text(dayStr,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3A44))),
                          Text(yearStr, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 32),
              // Summary Cards - Adapt for mobile
              isMobile 
                ? Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryCard(
                                title: isVendedor ? 'Ventas' : 'Activos',
                                value: isVendedor ? ventasState.ventas.length.toString().padLeft(2, '0') : activos.length.toString().padLeft(2, '0'),
                                icon: Icons.inventory_2_outlined,
                                color: Colors.blue),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _SummaryCard(
                                title: 'Pendientes',
                                value: pendientesCount.toString().padLeft(2, '0'),
                                icon: Icons.access_time,
                                color: Colors.orange),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _SummaryCard(
                          title: 'Completadas',
                          value: completadasCount.toString().padLeft(2, '0'),
                          icon: Icons.check_circle_outline,
                          color: Colors.green),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                            title: isVendedor ? 'Ventas' : 'Activos',
                            value: isVendedor ? ventasState.ventas.length.toString().padLeft(2, '0') : activos.length.toString().padLeft(2, '0'),
                            icon: Icons.inventory_2_outlined,
                            color: Colors.blue),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _SummaryCard(
                            title: 'Pendientes',
                            value: pendientesCount.toString().padLeft(2, '0'),
                            icon: Icons.access_time,
                            color: Colors.orange),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _SummaryCard(
                            title: 'Completadas',
                            value: completadasCount.toString().padLeft(2, '0'),
                            icon: Icons.check_circle_outline,
                            color: Colors.green),
                      ),
                    ],
                  ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isVendedor ? 'RESUMEN COMERCIAL' : 'TU RUTA DE HOY',
                            style: const TextStyle(
                                color: Color(0xFF007982), fontSize: 11, fontWeight: FontWeight.bold)),
                        Text(isVendedor ? 'Compras pendientes / completadas' : 'Activos asignados',
                            style: TextStyle(
                                fontSize: isMobile ? 18 : 22, fontWeight: FontWeight.bold, color: const Color(0xFF1E3A44))),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Row(
                      children: [
                        Text('Ver todos',
                            style: TextStyle(color: Color(0xFF007982), fontWeight: FontWeight.bold)),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF007982)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Activos/Ventas Cards - 1 per row on small mobile, 2 otherwise
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: constraints.maxWidth < 450 ? 1 : 2,
                  childAspectRatio: constraints.maxWidth < 450 ? 1.5 : 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: isVendedor ? ventasState.ventas.length : activos.length,
                itemBuilder: (context, index) {
                  if (isVendedor) {
                    final venta = ventasState.ventas[index];
                    return _VentaCard(venta: venta);
                  }
                  final item = activos[index];
                  return _ActivoCard(
                    id: item.id,
                    name: item.name,
                    location: item.location,
                    address: item.address,
                    status: item.status,
                    statusColor: item.statusColor,
                    temp: item.temp,
                  );
                },
              ),
            ],
          ),
        );
      }
    );
  }
}

class _VentaCard extends ConsumerWidget {
  final Venta venta;
  const _VentaCard({required this.venta});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = venta.status == 'Pendiente' ? Colors.orange : Colors.teal;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
                child: Icon(Icons.shopping_bag_outlined, color: statusColor, size: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 6, color: statusColor),
                    const SizedBox(width: 4),
                    Text(venta.status,
                        style: TextStyle(fontSize: 9, color: statusColor, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(venta.id, style: const TextStyle(color: Colors.grey, fontSize: 9)),
          Text(venta.productoNombre,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E3A44))),
          Text(venta.clienteNombre, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF007982)),
              const SizedBox(width: 2),
              Expanded(child: Text('${venta.comuna}, ${venta.region}', style: const TextStyle(fontSize: 10, overflow: TextOverflow.ellipsis))),
            ],
          ),
          const SizedBox(height: 12),
          if (venta.status == 'Pendiente')
            ElevatedButton(
              onPressed: () => context.go('/sale-workflow?id=${venta.id}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007982),
                minimumSize: const Size(double.infinity, 36),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: const Text('Completar compra', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(color: const Color(0xFFF0F9F9), borderRadius: BorderRadius.circular(6)),
              child: const Center(
                child: Text('Compra finalizada', style: TextStyle(color: Color(0xFF007982), fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E3A44))),
        ],
      ),
    );
  }
}

class _ActivoCard extends StatelessWidget {
  final String id;
  final String name;
  final String location;
  final String address;
  final String status;
  final Color statusColor;
  final String? temp;
  final String? time;

  const _ActivoCard({
    required this.id,
    required this.name,
    required this.location,
    required this.address,
    required this.status,
    required this.statusColor,
    this.temp,
    this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
                child: Icon(Icons.ac_unit, color: statusColor, size: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 6, color: statusColor),
                    const SizedBox(width: 4),
                    Text(status,
                        style: TextStyle(fontSize: 9, color: statusColor, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(id, style: const TextStyle(color: Colors.grey, fontSize: 9)),
          Text(name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E3A44))),
          Text(location, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF007982)),
              const SizedBox(width: 2),
              Expanded(child: Text(address, style: const TextStyle(fontSize: 10, overflow: TextOverflow.ellipsis))),
              Text(temp ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          if (status == 'Completada')
            Consumer(builder: (context, ref, _) {
              final activos = ref.watch(activosProvider);
              final activo = activos.firstWhere((a) => a.id == id);
              return ElevatedButton(
                onPressed: () => _showReportDialog(context, activo),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 36),
                  padding: EdgeInsets.zero,
                  backgroundColor: const Color(0xFFF0F9F9),
                  foregroundColor: const Color(0xFF007982),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Ver reporte técnico',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    SizedBox(width: 4),
                    Icon(Icons.assignment_outlined, size: 12),
                  ],
                ),
              );
            })
          else
            OutlinedButton(
              onPressed: () => context.go('/visit-workflow?id=$id'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 36),
                padding: EdgeInsets.zero,
                side: const BorderSide(color: Color(0xFFE0F2F1)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Registrar visita',
                      style: TextStyle(color: Color(0xFF007982), fontSize: 11, fontWeight: FontWeight.bold)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios, size: 8, color: Color(0xFF007982)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context, Activo activo) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('REPORTE DE VISITA · ${activo.id}',
                      style: const TextStyle(color: Color(0xFF007982), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, size: 20, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 16),
              Text(activo.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E3A44))),
              Text(activo.location, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              _buildReportField('Tipo de visita', activo.tipoVisita ?? 'No especificado'),
              const SizedBox(height: 16),
              _buildReportField('Estado del equipo', activo.estadoEquipo ?? 'No especificado'),
              const SizedBox(height: 16),
              _buildReportField('Observaciones', activo.observacionesTecnico ?? 'Sin observaciones.'),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007982),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Cerrar reporte', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, color: Color(0xFF1E3A44), fontWeight: FontWeight.w500)),
      ],
    );
  }
}
