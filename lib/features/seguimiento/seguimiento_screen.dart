import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../ventas/ventas_provider.dart';

class SeguimientoScreen extends ConsumerWidget {
  const SeguimientoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ventasState = ref.watch(ventasProvider);
    final ventas = ventasState.ventas;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SEGUIMIENTO DE VENTAS',
            style: TextStyle(
              color: Color(0xFF007982),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ventas en tiempo real',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A44),
            ),
          ),
          const Text(
            'Monitorea el origen y estado de cada producto vendido.',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 32),

          if (ventas.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 64.0),
                child: Text('No hay ventas registradas para seguimiento.', style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ventas.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final venta = ventas[index];
                return _SeguimientoItem(venta: venta);
              },
            ),
        ],
      ),
    );
  }
}

class _SeguimientoItem extends StatelessWidget {
  final Venta venta;
  const _SeguimientoItem({required this.venta});

  @override
  Widget build(BuildContext context) {
    final fechaStr = DateFormat('dd MMM, HH:mm').format(venta.fecha);
    final isPendiente = venta.status == 'Pendiente';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPendiente ? Colors.orange.withOpacity(0.1) : Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.shopping_cart_outlined, 
              color: isPendiente ? Colors.orange : Colors.teal,
              size: 24,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(venta.id, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                    Text(fechaStr, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(venta.productoNombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E3A44))),
                Text('Cliente: ${venta.clienteNombre}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFF0F9F9), borderRadius: BorderRadius.circular(6)),
                      child: Row(
                        children: [
                          const Icon(Icons.share_location_outlined, size: 12, color: Color(0xFF007982)),
                          const SizedBox(width: 4),
                          Text('Origen: ${venta.origen}', style: const TextStyle(color: Color(0xFF007982), fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPendiente ? Colors.orange.shade50 : Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        venta.status, 
                        style: TextStyle(color: isPendiente ? Colors.orange : Colors.teal, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
