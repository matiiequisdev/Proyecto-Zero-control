import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dashboard/dashboard_provider.dart';
import 'ventas_provider.dart';

class GestionComercialScreen extends ConsumerStatefulWidget {
  const GestionComercialScreen({super.key});

  @override
  ConsumerState<GestionComercialScreen> createState() => _GestionComercialScreenState();
}

class _GestionComercialScreenState extends ConsumerState<GestionComercialScreen> {
  bool showDetail = true;

  @override
  Widget build(BuildContext context) {
    final ventasState = ref.watch(ventasProvider);
    final dashboardNotifier = ref.read(dashboardProvider.notifier);
    final pendientes = ventasState.ventas.where((v) => v.status == 'Pendiente').toList();
    final completadas = ventasState.ventas.where((v) => v.status == 'Completada').toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1024;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
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
                        const Text(
                          'GESTIÓN COMERCIAL',
                          style: TextStyle(
                            color: Color(0xFF007982),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Vender freezers y congeladores',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A44),
                          ),
                        ),
                        const Text(
                          'Cotiza equipos, registra clientes y agenda visitas en un solo lugar.',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.inventory_2_outlined, color: Color(0xFF007982)),
                        const SizedBox(height: 4),
                        Text(
                          '${ventasState.unidadesDisponibles}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3A44)),
                        ),
                        const Text('unidades disponibles', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Main Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F9F9),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF007982).withOpacity(0.1)),
                ),
                child: isMobile 
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('CENTRO COMERCIAL', style: TextStyle(color: Color(0xFF007982), fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text('Tu jornada, más ordenada', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3A44))),
                        const Text('Revisa clientes, prepara una cotización y deja tu próxima visita agendada.', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        const SizedBox(height: 24),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _ActionBtn(icon: Icons.people_outline, label: 'Clientes', onTap: () => dashboardNotifier.setIndex(0)),
                            _ActionBtn(icon: Icons.history, label: 'Seguimientos', onTap: () => dashboardNotifier.setIndex(2)),
                            _ActionBtn(icon: Icons.assignment_outlined, label: 'Nueva agenda', isPrimary: true, onTap: () => dashboardNotifier.setIndex(3)),
                          ],
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('CENTRO COMERCIAL', style: TextStyle(color: Color(0xFF007982), fontSize: 10, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              const Text('Tu jornada, más ordenada', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3A44))),
                              const Text('Revisa clientes, prepara una cotización y deja tu próxima visita agendada.', style: TextStyle(color: Colors.grey, fontSize: 14)),
                              const SizedBox(height: 16),
                              const Text('Más vendido: Aún sin ventas registradas', style: TextStyle(color: Color(0xFF007982), fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _ActionBtn(icon: Icons.people_outline, label: 'Clientes', onTap: () => dashboardNotifier.setIndex(0)),
                            _ActionBtn(icon: Icons.history, label: 'Seguimientos', onTap: () => dashboardNotifier.setIndex(2)),
                            _ActionBtn(icon: Icons.assignment_outlined, label: 'Nueva agenda', isPrimary: true, onTap: () => dashboardNotifier.setIndex(3)),
                          ],
                        ),
                      ],
                    ),
              ),
              const SizedBox(height: 24),

              // Status Cards
              Row(
                children: [
                  Expanded(
                    child: _StatusCard(
                      title: 'Compra pendiente',
                      count: pendientes.length.toString().padLeft(2, '0'),
                      icon: Icons.access_time,
                      color: Colors.orange,
                      actionLabel: 'Ver pendientes →',
                      onTap: () => dashboardNotifier.setIndex(0),
                    ),
                  ),
                  SizedBox(width: isMobile ? 12 : 24),
                  Expanded(
                    child: _StatusCard(
                      title: 'Compras completa',
                      count: completadas.length.toString().padLeft(2, '0'),
                      icon: Icons.check_circle_outline,
                      color: Colors.teal,
                      actionLabel: 'Ver historial →',
                      onTap: () => dashboardNotifier.setIndex(4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Detail List
              if (showDetail)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('DETALLE ACTUALIZADO', style: TextStyle(color: Color(0xFF007982), fontSize: 10, fontWeight: FontWeight.bold)),
                                SizedBox(height: 4),
                                Text('Compra pendiente', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3A44))),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                            onPressed: () => setState(() => showDetail = false),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      isMobile 
                        ? Column(
                            children: [
                              _DetailItem(
                                index: 1, 
                                label: 'Seguimiento a cliente interesado',
                                onTap: () => dashboardNotifier.setIndex(2),
                              ),
                              const SizedBox(height: 12),
                              _DetailItem(
                                index: 2, 
                                label: 'Visita comercial programada',
                                onTap: () => dashboardNotifier.setIndex(3),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(child: _DetailItem(
                                index: 1, 
                                label: 'Seguimiento a cliente interesado',
                                onTap: () => dashboardNotifier.setIndex(2),
                              )),
                              const SizedBox(width: 16),
                              Expanded(child: _DetailItem(
                                index: 2, 
                                label: 'Visita comercial programada',
                                onTap: () => dashboardNotifier.setIndex(3),
                              )),
                            ],
                          ),
                    ],
                  ),
                ),
              const SizedBox(height: 48),

              // Catalog
              const Text('CATÁLOGO DISPONIBLE', style: TextStyle(color: Color(0xFF007982), fontSize: 10, fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Equipos recomendados', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E3A44))),
                  if (!isMobile) const Text('Venta + inventario sincronizados', style: TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 3),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isMobile ? 0.75 : 0.85, // Ajustado de 1.2 a 0.75 para evitar desbordamiento
                ),
                itemCount: ventasState.productos.length,
                itemBuilder: (context, index) {
                  final prod = ventasState.productos[index];
                  return _ProductCard(
                    producto: prod,
                    onRegister: () => _showConfirmarCompra(context, prod),
                  );
                },
              ),
            ],
          ),
        );
      }
    );
  }

  void _showConfirmarCompra(BuildContext context, Producto prod) {
    showDialog(
      context: context,
      builder: (context) => ConfirmarCompraDialog(producto: prod),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback? onTap;

  const _ActionBtn({required this.icon, required this.label, this.isPrimary = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF1E3A44) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF007982).withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isPrimary ? Colors.white : const Color(0xFF007982)),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: isPrimary ? Colors.white : const Color(0xFF007982), fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color color;
  final String actionLabel;
  final VoidCallback? onTap;

  const _StatusCard({required this.title, required this.count, required this.icon, required this.color, required this.actionLabel, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(count, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E3A44))),
            const SizedBox(height: 8),
            Text(actionLabel, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final int index;
  final String label;
  final VoidCallback? onTap;

  const _DetailItem({required this.index, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: Color(0xFF007982), shape: BoxShape.circle),
              child: Text(index.toString(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
            const Icon(Icons.check, color: Colors.orange, size: 16),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Producto producto;
  final VoidCallback onRegister;

  const _ProductCard({required this.producto, required this.onRegister});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen con altura flexible para evitar desbordamiento
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: producto.imageUrl != null
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.network(
                        producto.imageUrl!,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                        },
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 40),
                        ),
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.inventory_2_outlined, color: Colors.grey, size: 40),
                    ),
            ),
          ),
          // Información del producto
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(producto.id, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
                            child: Text('${producto.stock} disponibles', style: const TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        producto.name, 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        producto.subtitle, 
                        style: const TextStyle(color: Colors.grey, fontSize: 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(producto.price, style: const TextStyle(color: Color(0xFF007982), fontWeight: FontWeight.bold, fontSize: 12)),
                      ElevatedButton(
                        onPressed: onRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007982),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          minimumSize: const Size(0, 28),
                        ),
                        child: const Text('Registrar venta', style: TextStyle(fontSize: 10)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ConfirmarCompraDialog extends ConsumerStatefulWidget {
  final Producto producto;
  const ConfirmarCompraDialog({super.key, required this.producto});

  @override
  ConsumerState<ConfirmarCompraDialog> createState() => _ConfirmarCompraDialogState();
}

class _ConfirmarCompraDialogState extends ConsumerState<ConfirmarCompraDialog> {
  String? selectedClient;
  String? selectedRegion;
  String selectedOrigen = 'Visita Terreno';
  
  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  final comunaController = TextEditingController();
  final regionController = TextEditingController();
  final phoneController = TextEditingController();
  final addressSearchController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    lastNameController.dispose();
    comunaController.dispose();
    regionController.dispose();
    phoneController.dispose();
    addressSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ventasState = ref.watch(ventasProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 100),
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          width: isMobile ? screenWidth : 800,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CONFIRMAR COMPRA', style: TextStyle(color: Color(0xFF007982), fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Registrar ${widget.producto.name}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E3A44))),
                const Text('Completa los datos para registrar la venta.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 24),
                
                const Text('NUEVO CLIENTE ACTIVO', style: TextStyle(color: Color(0xFF007982), fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildModernAddressForm(isMobile),
                
                const SizedBox(height: 12),
                Align(
                  alignment: isMobile ? Alignment.center : Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (nameController.text.isNotEmpty) {
                        final fullNombre = "${nameController.text} ${lastNameController.text}".trim();
                        ref.read(ventasProvider.notifier).addCliente(fullNombre);
                        setState(() => selectedClient = fullNombre);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Cliente "$fullNombre" guardado y seleccionado')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Por favor ingresa al menos el nombre')),
                        );
                      }
                    },
                    icon: const Icon(Icons.person_add_alt, size: 16),
                    label: const Text('Guardar cliente'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF0F9F9), 
                      foregroundColor: const Color(0xFF007982),
                      elevation: 0,
                      minimumSize: const Size(150, 40),
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 24),

                const Text('O SELECCIONAR EXISTENTE', style: TextStyle(color: Color(0xFF007982), fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildSelectionSection(isMobile, ventasState),
              
                const SizedBox(height: 32),
                _buildActionButtons(isMobile),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionSection(bool isMobile, VentasState ventasState) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDropdownField('Cliente activo', selectedClient, ventasState.clientes, (val) => _updateClientSelection(val)),
          const SizedBox(height: 20),
          _buildDropdownField('Sector o destino', selectedRegion, ['Región Metropolitana', 'Valparaíso', 'Biobío'], (val) => setState(() => selectedRegion = val)),
          const SizedBox(height: 20),
          _buildDropdownField('Origen de la venta', selectedOrigen, ['Visita Terreno', 'Redes Sociales', 'Web', 'Referido'], (val) => setState(() => selectedOrigen = val!)),
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: _buildDropdownField('Cliente activo', selectedClient, ventasState.clientes, (val) => _updateClientSelection(val))),
        const SizedBox(width: 16),
        Expanded(child: _buildDropdownField('Sector o destino', selectedRegion, ['Región Metropolitana', 'Valparaíso', 'Biobío'], (val) => setState(() => selectedRegion = val))),
        const SizedBox(width: 16),
        Expanded(child: _buildDropdownField('Origen', selectedOrigen, ['Visita Terreno', 'Redes Sociales', 'Web', 'Referido'], (val) => setState(() => selectedOrigen = val!))),
      ],
    );
  }

  void _updateClientSelection(String? val) {
    setState(() {
      selectedClient = val;
      if (val != null) {
        nameController.clear();
        lastNameController.clear();
        comunaController.clear();
        regionController.clear();
        phoneController.clear();
        addressSearchController.clear();
      }
    });
  }

  Widget _buildActionButtons(bool isMobile) {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        alignment: isMobile ? WrapAlignment.center : WrapAlignment.end,
        spacing: 16,
        runSpacing: 12,
        children: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(minimumSize: const Size(120, 48)),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final client = nameController.text.isNotEmpty 
                ? "${nameController.text} ${lastNameController.text}".trim() 
                : selectedClient;
                
              if (client != null && client.isNotEmpty) {
                ref.read(ventasProvider.notifier).registrarVenta(
                  widget.producto.name,
                  client,
                  regionController.text.isNotEmpty ? regionController.text : (selectedRegion ?? 'RM'),
                  comunaController.text.isNotEmpty ? comunaController.text : 'Comuna',
                  origen: selectedOrigen,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Compra registrada con éxito')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor ingresa un nombre o selecciona un cliente')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF007982), minimumSize: const Size(180, 48)),
            child: const Text('Confirmar compra'),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, String? value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildModernAddressForm(bool isMobile) {
    return Column(
      children: [
        if (isMobile) ...[
          _buildTextField('Nombre*', nameController),
          const SizedBox(height: 12),
          _buildTextField('Apellidos*', lastNameController),
        ] else
          Row(
            children: [
              Expanded(child: _buildTextField('Nombre*', nameController)),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField('Apellidos*', lastNameController)),
            ],
          ),
        const SizedBox(height: 12),
        _buildSearchAddressField(),
        const SizedBox(height: 12),
        if (isMobile) ...[
          _buildTextField('Comuna*', comunaController),
          const SizedBox(height: 12),
          _buildTextField('Región*', regionController),
        ] else
          Row(
            children: [
              Expanded(child: _buildTextField('Comuna*', comunaController)),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField('Región*', regionController)),
            ],
          ),
        const SizedBox(height: 12),
        _buildTextField('Teléfono*', phoneController, prefix: '+56 '),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {String? prefix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixText: prefix,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dirección (Calle y Número)*', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text == '') return const Iterable<String>.empty();
            return [
              'Arica, Región de Arica y Parinacota',
              'Iquique, Región de Tarapacá',
              'Antofagasta, Región de Antofagasta',
              'Copiapó, Región de Atacama',
              'La Serena, Región de Coquimbo',
              'Valparaíso, Región de Valparaíso',
              'Viña del Mar, Región de Valparaíso',
              'Quilpué, Región de Valparaíso',
              'Santiago, Región Metropolitana',
              'Puente Alto, Región Metropolitana',
              'Maipú, Región Metropolitana',
              'La Florida, Región Metropolitana',
              'San Bernardo, Región Metropolitana',
              'Quilicura, Región Metropolitana',
              'Rancagua, Región de O\'Higgins',
              'Talca, Región del Maule',
              'Chillán, Región de Ñuble',
              'Concepción, Región del Biobío',
              'Talcahuano, Región del Biobío',
              'Temuco, Región de la Araucanía',
              'Valdivia, Región de los Ríos',
              'Puerto Montt, Región de los Lagos',
              'Coyhaique, Región de Aysén',
              'Punta Arenas, Región de Magallanes',
            ].where((String option) {
              return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
            });
          },
          onSelected: (String selection) {
            addressSearchController.text = selection;
            final parts = selection.split(', ');
            if (parts.length >= 2) {
              comunaController.text = parts[0];
              regionController.text = parts[1];
            }
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: 'Ej: Av. Providencia 123',
                suffixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 300,
                  constraints: const BoxConstraints(maxHeight: 250),
                  color: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (BuildContext context, int index) {
                            final String option = options.elementAt(index);
                            return ListTile(
                              leading: const Icon(Icons.location_on_outlined, size: 18, color: Colors.blue),
                              title: Text(option, style: const TextStyle(fontSize: 13)),
                              onTap: () => onSelected(option),
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        color: Colors.grey.shade50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text('powered by ', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            const Text('Google', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
