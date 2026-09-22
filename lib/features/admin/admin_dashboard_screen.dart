import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ventas/ventas_provider.dart';
import '../logistica/entregas_provider.dart';
import '../auth/auth_provider.dart';
import 'report_generator.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchar datos reales de los proveedores
    final ventasState = ref.watch(ventasProvider);
    final entregas = ref.watch(entregasProvider);
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Calcular métricas reales
    final totalVentasNum = ventasState.ventas.fold<double>(0, (sum, v) {
      // Extraer número del string de precio (ej: "$1.200.000" -> 1200000)
      final priceStr = v.price.replaceAll(RegExp(r'[^0-9]'), '');
      return sum + (double.tryParse(priceStr) ?? 0);
    });

    final totalEntregas = entregas.length;
    final entregasCompletadas = entregas.where((e) => e.status == EntregaStatus.completada).length;
    final efectividad = totalEntregas > 0 
        ? (entregasCompletadas / totalEntregas * 100).toStringAsFixed(1) 
        : "0.0";

    final personalActivo = authState.registeredUsers.length;
    final enRuta = entregas.where((e) => e.status == EntregaStatus.enRuta).length;
    final vendedores = authState.registeredUsers.where((u) => u.role == UserRole.vendedor).length;

    // Formatear moneda de forma segura
    final rawTotal = totalVentasNum.toInt().toString();
    final totalVentasStr = "\$${rawTotal.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[0]}.')}";

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CONTROL DE OPERACIÓN',
              style: TextStyle(
                color: Color(0xFF007982),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Dashboard Global',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E3A44),
              ),
            ),
            const SizedBox(height: 32),
            
            // Stats Row
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                if (isMobile) {
                  return Column(
                    children: [
                      _StatCard(
                        title: 'Ventas Totales',
                        value: totalVentasStr,
                        subtitle: '${ventasState.ventas.length} pedidos registrados',
                        icon: Icons.monetization_on_outlined,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 16),
                      _StatCard(
                        title: 'Entregas Hoy',
                        value: '$entregasCompletadas / $totalEntregas',
                        subtitle: '$efectividad% efectividad',
                        icon: Icons.local_shipping_outlined,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      _StatCard(
                        title: 'Personal Activo',
                        value: '$personalActivo',
                        subtitle: '$enRuta en ruta, $vendedores ventas',
                        icon: Icons.people_alt_outlined,
                        color: Colors.orange,
                      ),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Ventas Totales',
                        value: totalVentasStr,
                        subtitle: '${ventasState.ventas.length} pedidos registrados',
                        icon: Icons.monetization_on_outlined,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _StatCard(
                        title: 'Entregas Hoy',
                        value: '$entregasCompletadas / $totalEntregas',
                        subtitle: '$efectividad% efectividad',
                        icon: Icons.local_shipping_outlined,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _StatCard(
                        title: 'Personal Activo',
                        value: '$personalActivo',
                        subtitle: '$enRuta en ruta, $vendedores ventas',
                        icon: Icons.people_alt_outlined,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // Charts Area (Simulated)
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 800;
                
                final chartChildren = [
                  Container(
                    height: 400,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Rendimiento Semanal',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color),
                            ),
                            const Icon(Icons.more_horiz, color: Colors.grey),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _Bar(height: 120, label: 'L'),
                            _Bar(height: 180, label: 'M'),
                            _Bar(height: 150, label: 'X', isSelected: true),
                            _Bar(height: 220, label: 'J'),
                            _Bar(height: 190, label: 'V'),
                            _Bar(height: 80, label: 'S'),
                            _Bar(height: 40, label: 'D'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24, width: 24),
                  Container(
                    height: 400,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Distribución de Flota',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color),
                        ),
                        const SizedBox(height: 32),
                        const _PieItem(label: 'Logística', percentage: 50, color: Color(0xFF007982)),
                        const _PieItem(label: 'Comercial', percentage: 30, color: Colors.orange),
                        const _PieItem(label: 'Mantenimiento', percentage: 20, color: Colors.blue),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () => _showExportOptions(context, ref, ventasState, entregas, totalVentasNum),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF007982),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Exportar Reporte Global', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ];

                if (isMobile) {
                  return Column(
                    children: [
                      chartChildren[0],
                      const SizedBox(height: 24),
                      chartChildren[2],
                    ],
                  );
                }
                
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: chartChildren[0]),
                    const SizedBox(width: 24),
                    Expanded(child: chartChildren[2]),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showExportOptions(BuildContext context, WidgetRef ref, dynamic ventasState, dynamic entregas, double totalVentas) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Formato de exportación',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3A44)),
            ),
            const SizedBox(height: 8),
            const Text('Elige el formato del reporte que quieres descargar.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: _ExportOption(
                    icon: Icons.table_chart_outlined,
                    label: 'Excel (.xlsx)',
                    color: Colors.green,
                    onTap: () {
                      Navigator.pop(context);
                      ReportGenerator.generateReport(
                        context: context,
                        ventas: ventasState.ventas,
                        entregas: entregas,
                        totalVentas: totalVentas,
                        format: ReportFormat.excel,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ExportOption(
                    icon: Icons.picture_as_pdf_outlined,
                    label: 'PDF (.pdf)',
                    color: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      ReportGenerator.generateReport(
                        context: context,
                        ventas: ventasState.ventas,
                        entregas: entregas,
                        totalVentas: totalVentas,
                        format: ReportFormat.pdf,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ExportOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ExportOption({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double height;
  final String label;
  final bool isSelected;
  const _Bar({required this.height, required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 30,
          height: height,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF007982) : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _PieItem extends StatelessWidget {
  final String label;
  final int percentage;
  final Color color;
  const _PieItem({required this.label, required this.percentage, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: theme.textTheme.bodyMedium?.color)),
          const Spacer(),
          Text('$percentage%', style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
        ],
      ),
    );
  }
}
