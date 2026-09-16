import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/local_storage.dart';

enum EntregaStatus { pendiente, enRuta, completada }

class Entrega {
  final String id;
  final String cliente;
  final String lugar;
  final String direccion;
  final String horario;
  final String equipo;
  final EntregaStatus status;
  final DateTime? fechaConfirmacion;

  Entrega({
    required this.id,
    required this.cliente,
    required this.lugar,
    required this.direccion,
    required this.horario,
    required this.equipo,
    this.status = EntregaStatus.pendiente,
    this.fechaConfirmacion,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cliente': cliente,
      'lugar': lugar,
      'direccion': direccion,
      'horario': horario,
      'equipo': equipo,
      'status': status.index,
      'fechaConfirmacion': fechaConfirmacion?.toIso8601String(),
    };
  }

  factory Entrega.fromMap(Map<String, dynamic> map) {
    return Entrega(
      id: map['id'],
      cliente: map['cliente'],
      lugar: map['lugar'],
      direccion: map['direccion'],
      horario: map['horario'],
      equipo: map['equipo'],
      status: EntregaStatus.values[map['status']],
      fechaConfirmacion: map['fechaConfirmacion'] != null ? DateTime.parse(map['fechaConfirmacion']) : null,
    );
  }

  Entrega copyWith({EntregaStatus? status, DateTime? fechaConfirmacion}) {
    return Entrega(
      id: id,
      cliente: cliente,
      lugar: lugar,
      direccion: direccion,
      horario: horario,
      equipo: equipo,
      status: status ?? this.status,
      fechaConfirmacion: fechaConfirmacion ?? this.fechaConfirmacion,
    );
  }
}

class EntregasNotifier extends StateNotifier<List<Entrega>> {
  EntregasNotifier() : super([]) {
    _loadFromDB();
  }

  Future<void> _loadFromDB() async {
    final list = await LocalStorage.getEntregas();
    if (list.isEmpty) {
      state = [
        Entrega(
          id: 'ENT-1042',
          cliente: 'Supermercado El Roble',
          lugar: 'Bodega central',
          direccion: 'Manuel Montt 552, Santiago',
          horario: '09:30 - 10:30',
          equipo: 'Congelador 249 lts',
          status: EntregaStatus.enRuta,
        ),
        Entrega(
          id: 'ENT-1043',
          cliente: 'Distribuidora La Estrella',
          lugar: 'Local comercial',
          direccion: 'Av. Providencia 1842, Santiago',
          horario: '11:00 - 12:00',
          equipo: 'Congelador dual 198 lts',
          status: EntregaStatus.pendiente,
        ),
        Entrega(
          id: 'ENT-1044',
          cliente: 'Minimarket Los Alerces',
          lugar: 'Tienda principal',
          direccion: 'Santa Isabel 901, Santiago',
          horario: '15:00 - 16:00',
          equipo: 'Congeladora 199 lts',
          status: EntregaStatus.pendiente,
        ),
      ];
      for (var e in state) {
        await LocalStorage.insertEntrega(e.toMap());
      }
    } else {
      state = list.map((m) => Entrega.fromMap(m)).toList();
    }
  }

  void addEntrega(String cliente, String lugar, String direccion, String horario) async {
    final id = 'ENT-${(state.length + 1045).toString()}';
    final newEntrega = Entrega(
      id: id,
      cliente: cliente,
      lugar: lugar,
      direccion: direccion,
      horario: horario,
      equipo: 'Equipo por asignar',
    );
    
    state = [...state, newEntrega];
    await LocalStorage.insertEntrega(newEntrega.toMap());
  }

  void confirmarEntrega(String id) async {
    final updatedEntrega = state.firstWhere((e) => e.id == id).copyWith(
      status: EntregaStatus.completada, 
      fechaConfirmacion: DateTime.now()
    );

    state = [
      for (final entrega in state)
        if (entrega.id == id) updatedEntrega else entrega,
    ];

    await LocalStorage.updateEntrega(id, updatedEntrega.toMap());
  }
}

final entregasProvider = StateNotifierProvider<EntregasNotifier, List<Entrega>>((ref) {
  return EntregasNotifier();
});
