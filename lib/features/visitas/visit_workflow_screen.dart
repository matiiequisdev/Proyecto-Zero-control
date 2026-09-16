import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../activos/activos_provider.dart';

class VisitWorkflowScreen extends ConsumerStatefulWidget {
  final String? activoId;
  const VisitWorkflowScreen({super.key, this.activoId});

  @override
  ConsumerState<VisitWorkflowScreen> createState() => _VisitWorkflowScreenState();
}

class _VisitWorkflowScreenState extends ConsumerState<VisitWorkflowScreen> {
  int _currentStep = 1;
  bool _nfcScanned = false;
  String? _gpsLocation;
  String? _photoPath;

  Future<void> _captureLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El servicio de ubicación está desactivado.')),
        );
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permiso de ubicación denegado.')),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Los permisos de ubicación están denegados permanentemente.')),
        );
      }
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _gpsLocation = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al capturar ubicación: $e')),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        setState(() {
          _photoPath = photo.path;
        });
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permiso de cámara denegado.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activoId = widget.activoId ?? 'CF-2084';
    final activos = ref.watch(activosProvider);
    final activo = activos.firstWhere((a) => a.id == activoId, orElse: () => activos.first);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
            color: const Color(0xFFF8F9FA),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => context.go('/dashboard'),
                  child: const Row(
                    children: [
                      Icon(Icons.arrow_back, size: 14, color: Color(0xFF007982)),
                      SizedBox(width: 6),
                      Text('Volver a mis activos',
                          style: TextStyle(color: Color(0xFF007982), fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'NUEVA VISITA · PASO $_currentStep DE 3',
                  style: const TextStyle(
                      color: Color(0xFF007982), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentStep == 1
                                ? 'Validar presencia'
                                : _currentStep == 2
                                    ? 'Evidencia del equipo'
                                    : 'Detalles de la visita',
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1E3A44), letterSpacing: -0.5),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text('${activo.id} · ${activo.name}',
                              style: const TextStyle(color: Color(0xFF90A4AE), fontSize: 14, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Progress indicators
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          _StepIndicator(isActive: _currentStep >= 1),
                          const SizedBox(width: 6),
                          _StepIndicator(isActive: _currentStep >= 2),
                          const SizedBox(width: 6),
                          _StepIndicator(isActive: _currentStep >= 3),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildStepContent(activo),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(Activo activo) {
    if (_currentStep == 1) {
      return _Step1NFC(
        isScanned: _nfcScanned,
        onScan: () {
          setState(() => _nfcScanned = true);
          Future.delayed(const Duration(milliseconds: 1500), () {
            setState(() => _currentStep = 2);
          });
        },
      );
    } else if (_currentStep == 2) {
      return _Step2Evidence(
        gpsCaptured: _gpsLocation != null,
        gpsText: _gpsLocation,
        photoTaken: _photoPath != null,
        photoPath: _photoPath,
        onCaptureGps: _captureLocation,
        onTakePhoto: _takePhoto,
        onContinue: () => setState(() => _currentStep = 3),
        onBack: () => setState(() => _currentStep = 1),
      );
    } else {
      return _Step3Details(
        onFinish: (tipo, estado, obs) {
          ref.read(activosProvider.notifier).completeVisit(
            activo.id,
            tipo: tipo,
            estado: estado,
            observaciones: obs,
          );
          context.go('/dashboard');
        },
        onBack: () => setState(() => _currentStep = 2),
      );
    }
  }
}

class _StepIndicator extends StatelessWidget {
  final bool isActive;
  const _StepIndicator({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 4,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF007982) : const Color(0xFFCFD8DC),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _Step1NFC extends StatelessWidget {
  final bool isScanned;
  final VoidCallback onScan;

  const _Step1NFC({required this.isScanned, required this.onScan});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05), blurRadius: 30, offset: const Offset(0, 10))
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9F9),
                    shape: BoxShape.circle,
                  ),
                ),
                const Icon(Icons.wifi_tethering, size: 70, color: Color(0xFF007982)),
              ],
            ),
            const SizedBox(height: 40),
            const Text(
              'Acerca tu teléfono al tag NFC',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E3A44)),
            ),
            const SizedBox(height: 12),
            const Text(
              'Validaremos que estés junto a la conservadora CF-2084\nantes de registrar la visita.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 48),
            if (!isScanned) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.monitor_heart_outlined, size: 20, color: Color(0xFF007982)),
                  const SizedBox(width: 12),
                  const Text('Esperando lectura del tag...',
                      style: TextStyle(
                          color: Color(0xFF007982), fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onScan,
                icon: const Icon(Icons.nfc),
                label: const Text('Simular escaneo NFC'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ] else ...[
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              const Text('NFC validado correctamente',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ],
        ),
      ),
    );
  }
}

class _Step2Evidence extends StatelessWidget {
  final bool gpsCaptured;
  final String? gpsText;
  final bool photoTaken;
  final String? photoPath;
  final VoidCallback onCaptureGps;
  final VoidCallback onTakePhoto;
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const _Step2Evidence({
    required this.gpsCaptured,
    this.gpsText,
    required this.photoTaken,
    this.photoPath,
    required this.onCaptureGps,
    required this.onTakePhoto,
    required this.onContinue,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 800;

      final List<Widget> items = [
        // GPS Card
        Container(
          width: isWide ? null : double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration:
                    BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.my_location, color: Colors.blue, size: 24),
              ),
              const SizedBox(height: 24),
              const Text('Ubicación confirmada',
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E3A44))),
              const SizedBox(height: 8),
              const Text('La visita quedará asociada automáticamente a tu ubicación actual.',
                  style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(gpsCaptured ? Icons.check_circle : Icons.location_on_outlined,
                        color: gpsCaptured ? Colors.green : Colors.grey, size: 24),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        gpsCaptured
                            ? 'Ubicación registrada: $gpsText'
                            : 'GPS pendiente de captura',
                        style: TextStyle(
                            color: gpsCaptured ? const Color(0xFF1E3A44) : Colors.grey,
                            fontWeight: gpsCaptured ? FontWeight.bold : FontWeight.normal),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              OutlinedButton(
                onPressed: onCaptureGps,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Capturar ubicación',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
        if (!isWide) const SizedBox(height: 24),
        if (isWide) const SizedBox(width: 32),
        // Photo Card
        Container(
          width: isWide ? null : double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.purple.shade50, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.camera_alt_outlined, color: Colors.purple, size: 24),
              ),
              const SizedBox(height: 24),
              const Text('Foto de evidencia',
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E3A44))),
              const SizedBox(height: 8),
              const Text('Toma una foto del estado actual del equipo.',
                  style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 32),
              if (!photoTaken)
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
                  ),
                  child: Center(
                    child: TextButton.icon(
                      onPressed: onTakePhoto,
                      icon: const Icon(Icons.camera_alt_outlined, color: Colors.grey, size: 28),
                      label: const Text('Abrir cámara',
                          style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ),
                  ),
                )
              else
                Stack(
                  children: [
                    Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: FileImage(File(photoPath!)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const Positioned(
                      top: 12,
                      right: 12,
                      child: Icon(Icons.check_circle, color: Colors.green, size: 28),
                    ),
                  ],
                ),
              const SizedBox(height: 32),
              if (gpsCaptured && photoTaken) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(10)),
                  child: const Row(
                    children: [
                      Icon(Icons.check, color: Colors.green, size: 20),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('Evidencia completada y lista para sincronizar.',
                            style: TextStyle(
                                color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Continuar',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(width: 12),
                      Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ];

      return isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((w) => w is Container ? Expanded(child: w) : w).toList())
          : Column(children: items);
    });
  }
}

class _Step3Details extends StatefulWidget {
  final Function(String, String, String) onFinish;
  final VoidCallback onBack;
  const _Step3Details({required this.onFinish, required this.onBack});

  @override
  State<_Step3Details> createState() => _Step3DetailsState();
}

class _Step3DetailsState extends State<_Step3Details> {
  String _tipoVisita = 'Revisión preventiva';
  String _estadoEquipo = 'Operativo';
  final _obsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row for dropdowns
          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            final List<Widget> fields = [
              Expanded(
                flex: isWide ? 1 : 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tipo de visita',
                        style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF455A64), fontSize: 13)),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _tipoVisita,
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black87),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFECEFF1))),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFECEFF1))),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Revisión preventiva', child: Text('Revisión preventiva', style: TextStyle(fontSize: 14))),
                        DropdownMenuItem(value: 'Reparación', child: Text('Reparación', style: TextStyle(fontSize: 14))),
                        DropdownMenuItem(value: 'Instalación', child: Text('Instalación', style: TextStyle(fontSize: 14))),
                      ],
                      onChanged: (val) => setState(() => _tipoVisita = val!),
                    ),
                  ],
                ),
              ),
              if (isWide) const SizedBox(width: 24) else const SizedBox(height: 20),
              Expanded(
                flex: isWide ? 1 : 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Estado del equipo',
                        style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF455A64), fontSize: 13)),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _estadoEquipo,
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black87),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFECEFF1))),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFECEFF1))),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Operativo', child: Text('Operativo', style: TextStyle(fontSize: 14))),
                        DropdownMenuItem(value: 'Requiere atención', child: Text('Requiere atención', style: TextStyle(fontSize: 14))),
                        DropdownMenuItem(value: 'Fuera de servicio', child: Text('Fuera de servicio', style: TextStyle(fontSize: 14))),
                      ],
                      onChanged: (val) => setState(() => _estadoEquipo = val!),
                    ),
                  ],
                ),
              ),
            ];
            return isWide ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: fields) : Column(crossAxisAlignment: CrossAxisAlignment.start, children: fields);
          }),
          const SizedBox(height: 24),
          const Text('Observaciones',
              style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF455A64), fontSize: 13)),
          const SizedBox(height: 10),
          TextField(
            controller: _obsController,
            maxLines: 5,
            decoration: InputDecoration(
                hintText: 'Agrega detalles relevantes de la visita...',
                hintStyle: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 14),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFECEFF1))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFECEFF1)))),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: widget.onBack,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  backgroundColor: const Color(0xFFF1F5F9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Atrás',
                    style: TextStyle(color: Color(0xFF007982), fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                onPressed: () => widget.onFinish(_tipoVisita, _estadoEquipo, _obsController.text),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  backgroundColor: const Color(0xFF007982),
                  minimumSize: const Size(180, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 2,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Guardar visita', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    SizedBox(width: 10),
                    Icon(Icons.assignment_turned_in_outlined, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
