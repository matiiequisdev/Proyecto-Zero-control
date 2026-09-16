import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'entregas_provider.dart';

class RutaDiaScreen extends ConsumerStatefulWidget {
  const RutaDiaScreen({super.key});

  @override
  ConsumerState<RutaDiaScreen> createState() => _RutaDiaScreenState();
}

class _RutaDiaScreenState extends ConsumerState<RutaDiaScreen> {
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressSearchController = TextEditingController();
  final _comunaController = TextEditingController();
  final _regionController = TextEditingController();
  final _additionalInfoController = TextEditingController();
  final _deliveryInstructionsController = TextEditingController();
  final _phoneController = TextEditingController();
  final _horarioController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _addressSearchController.dispose();
    _comunaController.dispose();
    _regionController.dispose();
    _additionalInfoController.dispose();
    _deliveryInstructionsController.dispose();
    _phoneController.dispose();
    _horarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entregas = ref.watch(entregasProvider);
    final pendientes = entregas.where((e) => e.status != EntregaStatus.completada).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
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
                    Text('OPERACIÓN LOGÍSTICA',
                        style: TextStyle(
                            color: Color(0xFF007982),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1)),
                    SizedBox(height: 8),
                    Text('Ruta del día',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1E3A44))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.location_on_outlined, color: Color(0xFF007982), size: 20),
                    Text('${pendientes.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const Text('pendientes', style: TextStyle(fontSize: 9, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('NUEVA RUTA', style: TextStyle(color: Color(0xFF007982), fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                
                // Nombre y Apellidos
                Row(
                  children: [
                    Expanded(child: _buildTextField('Nombre*', _nameController)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField('Apellidos*', _lastNameController)),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Dirección con Autocomplete
                _buildSearchAddressField(),
                const SizedBox(height: 16),
                
                // Comuna y Región
                Row(
                  children: [
                    Expanded(child: _buildTextField('Comuna*', _comunaController)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField('Región*', _regionController)),
                  ],
                ),
                const SizedBox(height: 24),
                
                const Text('Información adicional', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 16),
                
                _buildTextField('Departamento / Oficina / Piso', _additionalInfoController),
                const SizedBox(height: 16),
                
                _buildTextField('Instrucciones de entrega', _deliveryInstructionsController, maxLines: 3),
                const SizedBox(height: 16),
                
                // Teléfono y Horario
                Row(
                  children: [
                    Expanded(flex: 2, child: _buildTextField('Teléfono*', _phoneController, prefix: '+56 ')),
                    const SizedBox(width: 12),
                    Expanded(flex: 1, child: _buildTextField('Horario*', _horarioController, suffix: Icons.access_time)),
                  ],
                ),
                
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.isNotEmpty && _addressSearchController.text.isNotEmpty) {
                      final fullNombre = "${_nameController.text} ${_lastNameController.text}".trim();
                      ref.read(entregasProvider.notifier).addEntrega(
                        fullNombre,
                        'Entrega Programada',
                        _addressSearchController.text,
                        _horarioController.text.isNotEmpty ? _horarioController.text : '10:00 - 18:00',
                      );
                      
                      // Limpiar campos después de guardar
                      _nameController.clear();
                      _lastNameController.clear();
                      _addressSearchController.clear();
                      _comunaController.clear();
                      _regionController.clear();
                      _additionalInfoController.clear();
                      _deliveryInstructionsController.clear();
                      _phoneController.clear();
                      _horarioController.clear();

                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ruta guardada con éxito')));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Completa los campos obligatorios')));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007982),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Guardar ruta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {String? prefix, IconData? suffix, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF455A64))),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixText: prefix,
            suffixIcon: suffix != null ? Icon(suffix, size: 20) : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dirección (Calle y Número)*', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF455A64))),
        const SizedBox(height: 6),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text == '') return const Iterable<String>.empty();
            return [
              'Santiago, Región Metropolitana',
              'Santiago Centro, Región Metropolitana',
              'Providencia, Región Metropolitana',
              'Las Condes, Región Metropolitana',
              'Ñuñoa, Región Metropolitana',
              'Viña del Mar, Región de Valparaíso',
              'Valparaíso, Región de Valparaíso',
              'Concepción, Región del Biobío',
              'La Serena, Región de Coquimbo',
              'Antofagasta, Región de Antofagasta',
              'Temuco, Región de la Araucanía',
            ].where((String option) {
              return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
            });
          },
          onSelected: (String selection) {
            _addressSearchController.text = selection;
            final parts = selection.split(', ');
            if (parts.length >= 2) {
              _comunaController.text = parts[0];
              _regionController.text = parts[1];
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
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
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
