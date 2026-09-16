import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'entregas_provider.dart';

class ConfirmarEntregasScreen extends ConsumerWidget {
  const ConfirmarEntregasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entregas = ref.watch(entregasProvider);
    final pendientes = entregas.where((e) => e.status != EntregaStatus.completada).toList();
    final enRuta = entregas.where((e) => e.status == EntregaStatus.enRuta).length;
    final confirmadas = entregas.where((e) => e.status == EntregaStatus.completada).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 700;
          
          return SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('OPERACIÓN LOGÍSTICA',
                              style: TextStyle(
                                  color: Color(0xFF007982),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1)),
                          const SizedBox(height: 8),
                          Text('Confirmación de entregas',
                              style: TextStyle(
                                  fontSize: isMobile ? 24 : 36,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E3A44))),
                          const SizedBox(height: 4),
                          const Text('Gestiona tu ruta y confirma cada entrega en terreno.',
                              style: TextStyle(color: Colors.grey, fontSize: 14)),
                        ],
                      ),
                    ),
                    if (!isMobile)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.local_shipping_outlined, color: Color(0xFF007982), size: 20),
                            const SizedBox(height: 4),
                            Text('${pendientes.length}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E3A44))),
                            const Text('pendientes', style: TextStyle(fontSize: 9, color: Colors.grey)),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 32),
                // Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: 'Entregas',
                        value: '${entregas.length}',
                        icon: Icons.local_shipping_outlined,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        title: 'En ruta',
                        value: '$enRuta',
                        icon: Icons.access_time,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Listas',
                        value: '$confirmadas',
                        icon: Icons.check_circle_outline,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // List of Deliveries
                if (isMobile)
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: entregas.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) => _EntregaCard(entrega: entregas[index]),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: constraints.maxWidth > 1200 ? 3 : 2,
                      childAspectRatio: 1.2,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                    ),
                    itemCount: entregas.length,
                    itemBuilder: (context, index) => _EntregaCard(entrega: entregas[index]),
                  ),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E3A44))),
        ],
      ),
    );
  }
}

class _EntregaCard extends ConsumerWidget {
  final Entrega entrega;
  const _EntregaCard({required this.entrega});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompletada = entrega.status == EntregaStatus.completada;
    final isEnRuta = entrega.status == EntregaStatus.enRuta;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isCompletada ? const Color(0xFFE8F5E9) : const Color(0xFFE6F3F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isCompletada ? Icons.check_circle_outline : Icons.local_shipping_outlined,
                        color: isCompletada ? Colors.green : const Color(0xFF007982),
                        size: 24,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isCompletada ? const Color(0xFFE8F5E9) : (isEnRuta ? const Color(0xFFFFF3E0) : const Color(0xFFFFF8E1)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.circle, size: 6, color: isCompletada ? Colors.green : (isEnRuta ? Colors.orange : Colors.amber)),
                          const SizedBox(width: 8),
                          Text(
                            isCompletada ? 'Completada' : (isEnRuta ? 'En ruta' : 'Pendiente'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isCompletada ? Colors.green.shade700 : (isEnRuta ? Colors.orange.shade700 : Colors.orange.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  isCompletada ? '${entrega.id} · Entregado' : '${entrega.id} · ${entrega.horario}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  entrega.cliente,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A44),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF007982)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entrega.direccion,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  entrega.equipo,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xFF455A64),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
            child: isCompletada 
              ? Container(
                  height: 56,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F8E9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.green.withOpacity(0.2)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 18),
                      SizedBox(width: 10),
                      Text(
                        'Entrega sincronizada',
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                )
              : ElevatedButton(
                  onPressed: () => _showConfirmDialog(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007982),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Confirmar entrega',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.check, size: 20),
                    ],
                  ),
                ),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('CONFIRMAR ${entrega.id}',
                        style: const TextStyle(color: Color(0xFF007982), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, size: 20, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Entrega a ${entrega.cliente}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E3A44))),
                const SizedBox(height: 4),
                Text('${entrega.equipo} · ${entrega.direccion}',
                    style: const TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 32),
                const Text('Observaciones', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF455A64))),
                const SizedBox(height: 12),
                TextField(
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Ej. Recibido por encargado de bodega...',
                    filled: true,
                    fillColor: const Color(0xFFF8F9FA),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined, color: Color(0xFF007982), size: 20),
                      SizedBox(width: 12),
                      Text('Adjuntar foto de entrega', style: TextStyle(color: Color(0xFF007982), fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    ref.read(entregasProvider.notifier).confirmarEntrega(entrega.id);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Entrega confirmada y sincronizada')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007982),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Confirmar y sincronizar entrega', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      SizedBox(width: 12),
                      Icon(Icons.check, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
