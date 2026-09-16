import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/local_storage.dart';

class Activo {
  final String id;
  final String name;
  final String location;
  final String address;
  final String status;
  final Color statusColor;
  final String? temp;
  final String? time;
  final DateTime? fechaVisita;
  final String? tipoVisita;
  final String? estadoEquipo;
  final String? observacionesTecnico;

  Activo({
    required this.id,
    required this.name,
    required this.location,
    required this.address,
    required this.status,
    required this.statusColor,
    this.temp,
    this.time,
    this.fechaVisita,
    this.tipoVisita,
    this.estadoEquipo,
    this.observacionesTecnico,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'address': address,
      'status': status,
      'statusColor': statusColor.value,
      'temp': temp,
      'time': time,
      'fechaVisita': fechaVisita?.toIso8601String(),
      'tipoVisita': tipoVisita,
      'estadoEquipo': estadoEquipo,
      'observacionesTecnico': observacionesTecnico,
    };
  }

  factory Activo.fromMap(Map<String, dynamic> map) {
    return Activo(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      address: map['address'] ?? '',
      status: map['status'] ?? 'Pendiente',
      statusColor: Color(map['statusColor'] ?? Colors.grey.value),
      temp: map['temp'],
      time: map['time'],
      fechaVisita: map['fechaVisita'] != null ? DateTime.parse(map['fechaVisita']) : null,
      tipoVisita: map['tipoVisita'],
      estadoEquipo: map['estadoEquipo'],
      observacionesTecnico: map['observacionesTecnico'],
    );
  }

  Activo copyWith({
    String? status,
    Color? statusColor,
    DateTime? fechaVisita,
    String? tipoVisita,
    String? estadoEquipo,
    String? observacionesTecnico,
  }) {
    return Activo(
      id: id,
      name: name,
      location: location,
      address: address,
      status: status ?? this.status,
      statusColor: statusColor ?? this.statusColor,
      temp: temp,
      time: time,
      fechaVisita: fechaVisita ?? this.fechaVisita,
      tipoVisita: tipoVisita ?? this.tipoVisita,
      estadoEquipo: estadoEquipo ?? this.estadoEquipo,
      observacionesTecnico: observacionesTecnico ?? this.observacionesTecnico,
    );
  }
}

class ActivosNotifier extends StateNotifier<List<Activo>> {
  ActivosNotifier() : super([]) {
    _loadFromDB();
  }

  Future<void> _loadFromDB() async {
    final list = await LocalStorage.getActivos();
    if (list.isEmpty) {
      // Carga inicial por defecto
      state = [
        Activo(
          id: 'CF-2084',
          name: 'Conservadora vertical',
          location: 'Distribuidora La Estrella',
          address: 'Av. Providencia 1842',
          status: 'Visita pendiente',
          statusColor: Colors.orange,
          temp: '-18°',
        ),
        Activo(
          id: 'CF-1931',
          name: 'Freezer horizontal',
          location: 'Supermercado El Roble',
          address: 'Manuel Montt 552',
          status: 'Programada hoy',
          statusColor: Colors.teal,
          temp: '-22°',
        ),
        Activo(
          id: 'CF-1740',
          name: 'Vitrina refrigerada',
          location: 'Minimarket Los Alerces',
          address: 'Santa Isabel 901',
          status: 'Completada',
          statusColor: Colors.green,
          temp: '4°',
          fechaVisita: DateTime(2026, 9, 2),
          tipoVisita: 'Revisión preventiva',
          estadoEquipo: 'Operativo',
          observacionesTecnico: 'Equipo funcionando en parámetros normales. Se realizó limpieza de condensador.',
        ),
      ];
      for (var a in state) {
        await LocalStorage.insertActivo(a.toMap());
      }
    } else {
      state = list.map((m) => Activo.fromMap(m)).toList();
    }
  }

  void completeVisit(String id, {String? tipo, String? estado, String? observaciones}) async {
    final updatedActivo = state.firstWhere((a) => a.id == id).copyWith(
      status: 'Completada',
      statusColor: Colors.green,
      fechaVisita: DateTime.now(),
      tipoVisita: tipo,
      estadoEquipo: estado,
      observacionesTecnico: observaciones,
    );

    state = [
      for (final activo in state)
        if (activo.id == id) updatedActivo else activo,
    ];

    await LocalStorage.updateActivo(id, updatedActivo.toMap());
  }

  void addActivo(String name, String address, String type) async {
    final id = 'NFC-${(state.length + 5000).toString()}';
    Color color = Colors.blue;
    if (type == 'Supermercado') color = Colors.teal;
    if (type == 'Minimarket') color = Colors.purple;

    final newActivo = Activo(
      id: id,
      name: name,
      location: type,
      address: address,
      status: 'Visita pendiente',
      statusColor: Colors.orange,
      temp: 'N/A',
    );

    state = [...state, newActivo];
    await LocalStorage.insertActivo(newActivo.toMap());
  }
}

final activosProvider = StateNotifierProvider<ActivosNotifier, List<Activo>>((ref) {
  return ActivosNotifier();
});
