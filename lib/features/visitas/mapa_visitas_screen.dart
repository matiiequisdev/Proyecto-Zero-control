import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../activos/activos_provider.dart';

class MapaVisitasScreen extends ConsumerStatefulWidget {
  const MapaVisitasScreen({super.key});

  @override
  ConsumerState<MapaVisitasScreen> createState() => _MapaVisitasScreenState();
}

class _MapaVisitasScreenState extends ConsumerState<MapaVisitasScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  String _selectedType = 'Distribuidora';

  @override
  Widget build(BuildContext context) {
    final activos = ref.watch(activosProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('COBERTURA EN TERRENO',
                        style: TextStyle(
                            color: Color(0xFF007982),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1)),
                    SizedBox(height: 8),
                    Text('Mapa de visitas',
                        style: TextStyle(
                            fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF1E3A44))),
                    SizedBox(height: 4),
                    Text('Ubicación de tus activos y visitas programadas.',
                        style: TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: Color(0xFF007982), size: 18),
                    SizedBox(width: 8),
                    Text('Santiago',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Color(0xFF1E3A44), fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Form Card
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9F9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFB2DFDB).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('NUEVA VISITA CERCANA',
                    style: TextStyle(
                        color: Color(0xFF007982),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1)),
                const SizedBox(height: 8),
                const Text('Agregar un lugar a tu ruta',
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E3A44))),
                const SizedBox(height: 24),
                LayoutBuilder(builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 900;
                  final List<Widget> fields = [
                    Expanded(
                      flex: isWide ? 2 : 0,
                      child: _FormField(
                        label: 'Tipo de negocio',
                        child: DropdownButtonFormField<String>(
                          value: _selectedType,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Distribuidora', child: Text('Distribuidora')),
                            DropdownMenuItem(value: 'Supermercado', child: Text('Supermercado')),
                            DropdownMenuItem(value: 'Minimarket', child: Text('Minimarket')),
                          ],
                          onChanged: (val) => setState(() => _selectedType = val!),
                        ),
                      ),
                    ),
                    if (isWide) const SizedBox(width: 16) else const SizedBox(height: 16),
                    Expanded(
                      flex: isWide ? 3 : 0,
                      child: _FormField(
                        label: 'Nombre del lugar',
                        child: TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: 'Ej. Distribuidora Norte',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                    ),
                    if (isWide) const SizedBox(width: 16) else const SizedBox(height: 16),
                    Expanded(
                      flex: isWide ? 3 : 0,
                      child: _FormField(
                        label: 'Dirección',
                        child: TextField(
                          controller: _addressController,
                          decoration: InputDecoration(
                            hintText: 'Ej. Av. Las Condes 123',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                    ),
                    if (isWide) const SizedBox(width: 16) else const SizedBox(height: 16),
                    Padding(
                      padding: EdgeInsets.only(top: isWide ? 24 : 0),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (_nameController.text.isNotEmpty && _addressController.text.isNotEmpty) {
                            ref.read(activosProvider.notifier).addActivo(
                              _nameController.text,
                              _addressController.text,
                              _selectedType,
                            );
                            _nameController.clear();
                            _addressController.clear();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Visita agregada correctamente')),
                            );
                          }
                        },
                        icon: const Icon(Icons.add_location_alt_outlined, size: 20, color: Colors.white),
                        label: const Text('Agregar visita', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                          backgroundColor: const Color(0xFF007982),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ];

                  return isWide
                      ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: fields)
                      : Column(children: fields);
                }),
              ],
            ),
          ),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildMap()),
                    const SizedBox(width: 32),
                    Expanded(flex: 2, child: _buildNearbyList(context, activos)),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildMap(),
                    const SizedBox(height: 32),
                    _buildNearbyList(context, activos),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return Container(
      height: 480,
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1),
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: NetworkImage(
              'https://via.placeholder.com/800x480/E0F2F1/007982?text=Mapa+Interactivo+ZeroControl'),
          fit: BoxFit.cover,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)],
      ),
      child: Stack(
        children: [
          // Simulated Markers
          const Positioned(top: 150, left: 150, child: _MapMarker(number: '1')),
          const Positioned(top: 250, right: 180, child: _MapMarker(number: '2', color: Colors.orange)),
          const Positioned(bottom: 120, left: 220, child: _MapMarker(number: '3', color: Colors.purple)),
          const Positioned(top: 50, left: 50, child: _MapMarker(number: '4', color: Colors.teal)),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton.extended(
              onPressed: () {},
              backgroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.my_location, color: Color(0xFF007982), size: 20),
              label: const Text('Tu ubicación',
                  style: TextStyle(color: Color(0xFF1E3A44), fontWeight: FontWeight.bold)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyList(BuildContext context, List<Activo> activos) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 25, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Visitas cercanas',
                  style:
                      TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E3A44))),
              Text('${activos.length} activos',
                  style: TextStyle(
                      color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 32),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activos.length,
            separatorBuilder: (context, index) => const Divider(height: 32),
            itemBuilder: (context, index) {
              final item = activos[index];
              return _NearbyVisitItem(
                id: item.id,
                name: item.name,
                address: item.address,
                color: item.statusColor,
                onTap: () => context.go('/visit-workflow?id=${item.id}'),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final Widget child;
  const _FormField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF546E7A))),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _NearbyVisitItem extends StatelessWidget {
  final String id;
  final String name;
  final String address;
  final Color color;
  final VoidCallback onTap;

  const _NearbyVisitItem(
      {required this.id, required this.name, required this.address, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.ac_unit, color: color, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(id,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xFF1E3A44), fontSize: 15)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        address,
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
    );
  }
}

class _MapMarker extends StatelessWidget {
  final String number;
  final Color color;
  const _MapMarker({required this.number, this.color = const Color(0xFF007982)});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5)],
          ),
          child: Center(
              child: Text(number,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
        ),
        Icon(Icons.arrow_drop_down, color: color, size: 20),
      ],
    );
  }
}
