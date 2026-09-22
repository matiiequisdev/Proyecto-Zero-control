import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../activos/activos_provider.dart';

class AdminInventoryScreen extends ConsumerWidget {
  const AdminInventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activos = ref.watch(activosProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'INVENTARIO CORPORATIVO',
              style: TextStyle(
                color: Color(0xFF007982),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Maestro de Activos',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E3A44)),
            ),
            const SizedBox(height: 32),
            
            // Stats Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                if (isMobile) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _SmallStat(label: 'Total', value: '${activos.length}', color: Colors.blue)),
                          const SizedBox(width: 8),
                          Expanded(child: _SmallStat(label: 'OK', value: '${activos.length - 1}', color: Colors.green)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _SmallStat(label: 'Manten.', value: '1', color: Colors.orange)),
                          const SizedBox(width: 8),
                          Expanded(child: _SmallStat(label: 'Baja', value: '0', color: Colors.red)),
                        ],
                      ),
                    ],
                  );
                }
                return Row(
                  children: [
                    _SmallStat(label: 'Total Activos', value: '${activos.length}', color: Colors.blue),
                    const SizedBox(width: 16),
                    _SmallStat(label: 'Operativos', value: '${activos.length - 1}', color: Colors.green),
                    const SizedBox(width: 16),
                    _SmallStat(label: 'En Mantenimiento', value: '1', color: Colors.orange),
                    const SizedBox(width: 16),
                    _SmallStat(label: 'Baja/Robo', value: '0', color: Colors.red),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
            
            // Assets Table (Master List)
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF0F9F9)),
                        columns: const [
                          DataColumn(label: Text('ID ACTIVO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          DataColumn(label: Text('EQUIPO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          DataColumn(label: Text('PERTENECE A (CLIENTE)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          DataColumn(label: Text('ÚLTIMA MANTENCIÓN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          DataColumn(label: Text('ESTADO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        ],
                        rows: activos.map((a) {
                          final lastMaint = a.fechaVisita != null 
                              ? DateFormat('dd/MM/yyyy HH:mm').format(a.fechaVisita!)
                              : 'Sin registros';
                              
                          return DataRow(cells: [
                            DataCell(Text(a.id, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                            DataCell(Text(a.name, style: TextStyle(fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color))),
                            DataCell(Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(a.location, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E3A44))),
                                Text(a.address, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            )),
                            DataCell(Text(lastMaint, style: TextStyle(color: theme.textTheme.bodyMedium?.color))),
                            DataCell(Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: a.status == 'Completada' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                a.status == 'Completada' ? 'Óptimo' : 'Pendiente', 
                                style: TextStyle(
                                  color: a.status == 'Completada' ? Colors.green : Colors.orange, 
                                  fontSize: 10, 
                                  fontWeight: FontWeight.bold
                                )
                              ),
                            )),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SmallStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
        ],
      ),
    );
  }
}
