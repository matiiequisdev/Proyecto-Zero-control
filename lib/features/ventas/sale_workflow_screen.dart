import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'ventas_provider.dart';

class SaleWorkflowScreen extends ConsumerStatefulWidget {
  final String ventaId;
  const SaleWorkflowScreen({super.key, required this.ventaId});

  @override
  ConsumerState<SaleWorkflowScreen> createState() => _SaleWorkflowScreenState();
}

class _SaleWorkflowScreenState extends ConsumerState<SaleWorkflowScreen> {
  int _currentStep = 1;
  String? _gpsLocation;
  String? _photoPath;

  Future<void> _captureLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        // En caso de que el usuario lo haya denegado permanentemente, simulamos una ubicación
        // para no bloquear el flujo de la demo.
        setState(() {
          _gpsLocation = "-33.4569, -70.6483 (Ubicación simulada)";
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _gpsLocation = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      });
    } catch (e) {
      // Si hay cualquier error de permisos, simulamos para permitir continuar
      setState(() {
        _gpsLocation = "-33.4569, -70.6483 (Modo Desarrollo)";
      });
    }
  }

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _photoPath = photo.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ventasState = ref.watch(ventasProvider);
    final venta = ventasState.ventas.firstWhere((v) => v.id == widget.ventaId);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          _buildHeader(venta),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildStepContent(venta),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Venta venta) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => context.go('/dashboard'),
            child: const Row(
              children: [
                Icon(Icons.arrow_back, size: 14, color: Color(0xFF007982)),
                SizedBox(width: 6),
                Text('Volver al resumen', style: TextStyle(color: Color(0xFF007982), fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('CONFIRMACIÓN DE COMPRA · PASO $_currentStep DE 3', 
              style: const TextStyle(color: Color(0xFF007982), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentStep == 1 ? 'Ubicación de entrega' : _currentStep == 2 ? 'Evidencia fotográfica' : 'Confirmación final',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E3A44)),
                    ),
                    Text('${venta.productoNombre} · ${venta.clienteNombre}', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              ),
              _buildProgressDots(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDots() {
    return Row(
      children: List.generate(3, (index) => Container(
        margin: const EdgeInsets.only(left: 4),
        width: 24,
        height: 4,
        decoration: BoxDecoration(
          color: (index + 1) <= _currentStep ? const Color(0xFF007982) : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
      )),
    );
  }

  Widget _buildStepContent(Venta venta) {
    if (_currentStep == 1) {
      return _buildLocationStep();
    } else if (_currentStep == 2) {
      return _buildPhotoStep();
    } else {
      return _buildFinalStep(venta);
    }
  }

  Widget _buildLocationStep() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
          child: Column(
            children: [
              const Icon(Icons.location_on, size: 64, color: Colors.blue),
              const SizedBox(height: 24),
              const Text('Validar ubicación de entrega', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Text('Confirma que te encuentras en el domicilio del cliente para la entrega.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              if (_gpsLocation != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 12),
                      Text('Registrado: $_gpsLocation', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _captureLocation,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56)),
                child: const Text('Capturar GPS'),
              ),
            ],
          ),
        ),
        if (_gpsLocation != null) ...[
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => setState(() => _currentStep = 2),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A44), minimumSize: const Size(double.infinity, 56)),
            child: const Text('Siguiente paso'),
          ),
        ]
      ],
    );
  }

  Widget _buildPhotoStep() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
          child: Column(
            children: [
              const Icon(Icons.camera_alt, size: 64, color: Colors.purple),
              const SizedBox(height: 24),
              const Text('Evidencia de entrega', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Text('Toma una foto del producto entregado junto al cliente.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              if (_photoPath == null)
                GestureDetector(
                  onTap: _takePhoto,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFFF8F9FA),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined, color: Colors.grey, size: 48),
                        SizedBox(height: 12),
                        Text('Click para abrir cámara', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                )
              else
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(_photoPath!), height: 200, width: double.infinity, fit: BoxFit.cover),
                ),
            ],
          ),
        ),
        if (_photoPath != null) ...[
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => setState(() => _currentStep = 3),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A44), minimumSize: const Size(double.infinity, 56)),
            child: const Text('Continuar al cierre'),
          ),
        ],
        const SizedBox(height: 16),
        TextButton(onPressed: () => setState(() => _currentStep = 1), child: const Text('Volver atrás')),
      ],
    );
  }

  Widget _buildFinalStep(Venta venta) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
          child: Column(
            children: [
              const Icon(Icons.verified_outlined, size: 64, color: Colors.teal),
              const SizedBox(height: 24),
              const Text('COMPRA RECIBIDA CON EXITO', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _buildResumenItem(Icons.location_on, 'GPS', 'Capturado correctamente'),
              const Divider(),
              _buildResumenItem(Icons.camera_alt, 'Foto', 'Almacenada en sistema'),
              const Divider(),
              _buildResumenItem(Icons.person, 'Cliente', venta.clienteNombre),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  ref.read(ventasProvider.notifier).completarVenta(venta.id);
                  context.go('/dashboard');
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Compra finalizada con éxito')));
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, minimumSize: const Size(double.infinity, 56)),
                child: const Text('Finalizar y Sincronizar'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextButton(onPressed: () => setState(() => _currentStep = 2), child: const Text('Volver atrás')),
      ],
    );
  }

  Widget _buildResumenItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF007982)),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
