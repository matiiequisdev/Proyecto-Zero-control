import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'ventas_provider.dart';

class AgendaComercialScreen extends ConsumerWidget {
  const AgendaComercialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ventasState = ref.watch(ventasProvider);
    final topTienda = ref.read(ventasProvider.notifier).topTienda;
    final topProducto = ref.read(ventasProvider.notifier).topProducto;
    
    // Get next pending sale for "Next Visit"
    Venta? nextVenta;
    try {
      nextVenta = ventasState.ventas.firstWhere((v) => v.status == 'Pendiente');
    } catch (_) {}

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AGENDA COMERCIAL ESTRATÉGICA',
                style: TextStyle(
                  color: Color(0xFF007982),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tu ruta al éxito',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A44),
                ),
              ),
              const Text(
                'Optimiza tus visitas comerciales y maximiza el cierre de ventas.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _StatTrendCard(
                      title: 'Tienda con más compras',
                      value: topTienda,
                      icon: Icons.store_mall_directory_outlined,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatTrendCard(
                      title: 'Producto estrella',
                      value: topProducto,
                      icon: Icons.auto_awesome,
                      color: const Color(0xFF007982),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              if (isMobile) 
                Column(
                  children: [
                    _buildNextVisitCard(nextVenta),
                    const SizedBox(height: 24),
                    _buildStrategicMap(),
                    const SizedBox(height: 24),
                    _buildWeeklyCalendar(),
                    const SizedBox(height: 24),
                    _buildSalesFunnel(ref.read(ventasProvider.notifier)),
                    const SizedBox(height: 24),
                    _buildClientSentiment(ventasState.satisfaccionCliente),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Calendar & Map
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _buildStrategicMap(),
                          const SizedBox(height: 24),
                          _buildWeeklyCalendar(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Right Column: Next Visit & Funnel
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          _buildNextVisitCard(nextVenta),
                          const SizedBox(height: 24),
                          _buildSalesFunnel(ref.read(ventasProvider.notifier)),
                          const SizedBox(height: 24),
                          _buildClientSentiment(ventasState.satisfaccionCliente),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildStrategicMap() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1),
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: NetworkImage('https://api.mapbox.com/styles/v1/mapbox/light-v10/static/-70.6483, -33.4569,12/800x400?access_token=dummy'),
          fit: BoxFit.cover,
          opacity: 0.3,
        ),
      ),
      child: Stack(
        children: [
          const Center(child: Icon(Icons.location_on, color: Color(0xFF007982), size: 48)),
          Position8(top: 40, left: 100, icon: Icons.store, color: Colors.orange, label: 'Potencial: Alto'),
          Position8(bottom: 60, right: 120, icon: Icons.store, color: Colors.teal, label: 'Visita Hoy'),
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: const Text('Zonas de mayor demanda', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyCalendar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Planificación Semanal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CalendarDay(day: 'Lun', date: '04', isSelected: true),
              _CalendarDay(day: 'Mar', date: '05'),
              _CalendarDay(day: 'Mie', date: '06'),
              _CalendarDay(day: 'Jue', date: '07', hasEvent: true),
              _CalendarDay(day: 'Vie', date: '08'),
              _CalendarDay(day: 'Sab', date: '09'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNextVisitCard(Venta? nextVenta) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1E3A44), Color(0xFF243E48)]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('PRÓXIMA VISITA CRÍTICA', style: TextStyle(color: Color(0xFF64FFDA), fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(nextVenta?.clienteNombre ?? 'Sin visitas pendientes', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          Text(nextVenta != null ? 'Entrega de ${nextVenta.productoNombre}' : 'Organiza tu agenda comercial', style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.white70, size: 14),
              const SizedBox(width: 8),
              Text(nextVenta != null ? DateFormat('HH:mm').format(nextVenta.fecha.add(const Duration(hours: 2))) : '--:--', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF007982), minimumSize: const Size(double.infinity, 36)),
            child: const Text('Preparar presentación'),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesFunnel(VentasNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Embudo de Ventas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          _FunnelStage(label: 'Prospectos', value: notifier.getFunnelValue('Prospecto').toString(), color: Colors.blue.shade100, width: 1.0),
          _FunnelStage(label: 'Cotizados', value: notifier.getFunnelValue('Cotizado').toString(), color: Colors.orange.shade100, width: 0.7),
          _FunnelStage(label: 'Negociación', value: notifier.getFunnelValue('Negociación').toString(), color: Colors.teal.shade100, width: 0.4),
          _FunnelStage(label: 'Cerrados', value: notifier.getFunnelValue('Cerrado').toString(), color: Colors.green.shade100, width: 0.2),
        ],
      ),
    );
  }

  Widget _buildClientSentiment(int satisfaccion) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Satisfacción del Cliente', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.sentiment_very_satisfied, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(child: LinearProgressIndicator(value: satisfaccion / 100, color: Colors.green, backgroundColor: Colors.white)),
              const SizedBox(width: 8),
              Text('$satisfaccion%', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTrendCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTrendCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.05), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E3A44)), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Position8 extends StatelessWidget {
  final double? top, bottom, left, right;
  final IconData icon;
  final Color color;
  final String label;

  const Position8({this.top, this.bottom, this.left, this.right, required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
            child: Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  final String day;
  final String date;
  final bool isSelected;
  final bool hasEvent;

  const _CalendarDay({required this.day, required this.date, this.isSelected = false, this.hasEvent = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(day, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        const SizedBox(height: 8),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF007982) : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: hasEvent ? const Color(0xFF007982) : Colors.transparent),
          ),
          child: Center(
            child: Text(date, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}

class _FunnelStage extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final double width;

  const _FunnelStage({required this.label, required this.value, required this.color, required this.width});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey))),
          Expanded(
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: width,
              child: Container(
                height: 24,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
                child: Center(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
