import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Producto {
  final String id;
  final String name;
  final String subtitle;
  final int stock;
  final String price;
  final Color color;
  final String? imageUrl;

  Producto({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.stock,
    required this.price,
    required this.color,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'subtitle': subtitle,
        'stock': stock,
        'price': price,
        'color': color.value,
        'imageUrl': imageUrl,
      };

  factory Producto.fromMap(Map<String, dynamic> map) => Producto(
        id: map['id'],
        name: map['name'],
        subtitle: map['subtitle'],
        stock: map['stock'],
        price: map['price'],
        color: Color(map['color']),
        imageUrl: map['imageUrl'],
      );
}

class Venta {
  final String id;
  final String productoNombre;
  final String clienteNombre;
  final String price; // Añadido campo precio
  final String region;
  final String comuna;
  final String status; // 'Pendiente', 'Completada'
  final DateTime fecha;
  final String origen; // 'Visita Terreno', 'Redes Sociales', 'Web', 'Referido'
  final String etapa; // 'Prospecto', 'Cotizado', 'Negociación', 'Cerrado'

  Venta({
    required this.id,
    required this.productoNombre,
    required this.clienteNombre,
    required this.price,
    required this.region,
    required this.comuna,
    required this.status,
    required this.fecha,
    required this.origen,
    required this.etapa,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'productoNombre': productoNombre,
        'clienteNombre': clienteNombre,
        'price': price,
        'region': region,
        'comuna': comuna,
        'status': status,
        'fecha': fecha.toIso8601String(),
        'origen': origen,
        'etapa': etapa,
      };

  factory Venta.fromMap(Map<String, dynamic> map) => Venta(
        id: map['id'] ?? '',
        productoNombre: map['productoNombre'] ?? '',
        clienteNombre: map['clienteNombre'] ?? '',
        price: map['price'] ?? '\$0',
        region: map['region'] ?? '',
        comuna: map['comuna'] ?? '',
        status: map['status'] ?? 'Pendiente',
        fecha: DateTime.parse(map['fecha'] ?? DateTime.now().toIso8601String()),
        origen: map['origen'] ?? 'Visita Terreno',
        etapa: map['etapa'] ?? 'Prospecto',
      );

  Venta copyWith({String? price, String? status, String? etapa}) {
    return Venta(
      id: id,
      productoNombre: productoNombre,
      clienteNombre: clienteNombre,
      price: price ?? this.price,
      region: region,
      comuna: comuna,
      status: status ?? this.status,
      fecha: fecha,
      origen: origen,
      etapa: etapa ?? this.etapa,
    );
  }
}

class VentasState {
  final List<Producto> productos;
  final List<Venta> ventas;
  final List<String> clientes;
  final int unidadesDisponibles;
  final int satisfaccionCliente;

  VentasState({
    required this.productos,
    required this.ventas,
    required this.clientes,
    required this.unidadesDisponibles,
    this.satisfaccionCliente = 85,
  });

  VentasState copyWith({
    List<Producto>? productos,
    List<Venta>? ventas,
    List<String>? clientes,
    int? unidadesDisponibles,
    int? satisfaccionCliente,
  }) {
    return VentasState(
      productos: productos ?? this.productos,
      ventas: ventas ?? this.ventas,
      clientes: clientes ?? this.clientes,
      unidadesDisponibles: unidadesDisponibles ?? this.unidadesDisponibles,
      satisfaccionCliente: satisfaccionCliente ?? this.satisfaccionCliente,
    );
  }
}

class VentasNotifier extends StateNotifier<VentasState> {
  VentasNotifier()
      : super(VentasState(
          productos: [],
          ventas: [],
          clientes: ['Distribuidora La Estrella', 'Supermercado El Roble', 'Minimarket Los Alerces'],
          unidadesDisponibles: 29,
        )) {
    _loadFromLocal();
  }

  Future<void> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // SIEMPRE inicializamos los productos con los datos más recientes (con fotos estables)
      _initDefault(); 

      final ventasJson = prefs.getString('vendedor_ventas');
      final clientesJson = prefs.getString('vendedor_clientes');
      final unidades = prefs.getInt('vendedor_unidades') ?? 29;
      final satisfaccion = prefs.getInt('vendedor_satisfaccion') ?? 85;

      if (ventasJson != null) {
        final List<dynamic> ventasList = jsonDecode(ventasJson);
        final List<dynamic> clientesList = jsonDecode(clientesJson ?? '[]');

        // Migración: Asegurar que ventas antiguas tengan precio
        final migratedVentas = ventasList.map((m) {
          final venta = Venta.fromMap(m);
          if (venta.price == '\$0' || venta.price.isEmpty) {
            try {
              final product = state.productos.firstWhere((p) => p.name == venta.productoNombre);
              return venta.copyWith(price: product.price);
            } catch (_) {
              return venta;
            }
          }
          return venta;
        }).toList();

        state = state.copyWith(
          ventas: migratedVentas,
          clientes: clientesList.cast<String>(),
          unidadesDisponibles: unidades,
          satisfaccionCliente: satisfaccion,
        );
      }
    } catch (e) {
      _initDefault();
    }
  }

  Future<void> _saveToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vendedor_ventas', jsonEncode(state.ventas.map((v) => v.toMap()).toList()));
    await prefs.setString('vendedor_clientes', jsonEncode(state.clientes));
    await prefs.setInt('vendedor_unidades', state.unidadesDisponibles);
    await prefs.setInt('vendedor_satisfaccion', state.satisfaccionCliente);
  }

  void _initDefault() {
    state = state.copyWith(
        productos: [
          Producto(
            id: 'FREEZER-ML', 
            name: 'FREEZER HORIZONTAL', 
            subtitle: 'Modelo Dual Blanco · 100 Lts', 
            stock: 6, price: '\$119.990', 
            color: Colors.white,
            imageUrl: 'https://http2.mlstatic.com/D_NQ_NP_660309-MLC46566085542_072021-O.webp'
          ),
          Producto(
            id: 'CONSERV-ML', 
            name: 'CONSERVADORA DUAL', 
            subtitle: 'Modelo Inverter · 143 Lts', 
            stock: 3, price: '\$139.990', 
            color: Colors.white,
            imageUrl: 'https://http2.mlstatic.com/D_NQ_NP_956041-MLC46566085541_072021-O.webp'
          ),
          Producto(
            id: 'MURAL-ML', 
            name: 'VITRINA REFRIGERADA', 
            subtitle: 'Mural Exhibición Premium', 
            stock: 2, price: '\$939.990', 
            color: Colors.white,
            imageUrl: 'https://http2.mlstatic.com/D_NQ_NP_612260-MLC46566085540_072021-O.webp'
          ),
          Producto(
            id: 'REF-ML', 
            name: 'REFRIGERADOR VERTICAL', 
            subtitle: 'Serie Profesional · 180 Lts', 
            stock: 3, price: '\$180.690', 
            color: Colors.white,
            imageUrl: 'https://http2.mlstatic.com/D_NQ_NP_844463-MLC46566085539_072021-O.webp'
          ),
          Producto(
            id: 'PAST-ML', 
            name: 'VITRINA PASTELERA', 
            subtitle: 'Cristal Curvo · 1.5 Mts', 
            stock: 2, price: '\$1.000.000', 
            color: Colors.white,
            imageUrl: 'https://http2.mlstatic.com/D_NQ_NP_610427-MLC46566085538_072021-O.webp'
          ),
        ],
        ventas: [
          Venta(id: 'V-1', productoNombre: 'FREEZER HORIZONTAL', clienteNombre: 'Distribuidora La Estrella', price: '\$119.990', region: 'RM', comuna: 'Providencia', status: 'Pendiente', fecha: DateTime.now(), origen: 'Visita Terreno', etapa: 'Prospecto'),
          Venta(id: 'V-2', productoNombre: 'REFRIGERADOR VERTICAL', clienteNombre: 'Supermercado El Roble', price: '\$180.690', region: 'RM', comuna: 'Santiago', status: 'Completada', fecha: DateTime.now().subtract(const Duration(days: 1)), origen: 'Web', etapa: 'Cerrado'),
        ]);
    _saveToLocal();
  }

  void registrarVenta(String productoNombre, String clienteNombre, String region, String comuna, {String origen = 'Visita Terreno', String etapa = 'Prospecto'}) {
    final product = state.productos.firstWhere((p) => p.name == productoNombre);
    final newVenta = Venta(
      id: 'V-${state.ventas.length + 100}',
      productoNombre: productoNombre,
      clienteNombre: clienteNombre,
      price: product.price,
      region: region,
      comuna: comuna,
      status: 'Pendiente',
      fecha: DateTime.now(),
      origen: origen,
      etapa: etapa,
    );
    state = state.copyWith(
      ventas: [newVenta, ...state.ventas],
      unidadesDisponibles: state.unidadesDisponibles - 1,
      satisfaccionCliente: (state.satisfaccionCliente + 1).clamp(0, 100),
    );
    _saveToLocal();
  }

  String get topTienda {
    if (state.ventas.isEmpty) return 'Sin datos';
    final counts = <String, int>{};
    for (var v in state.ventas) {
      counts[v.clienteNombre] = (counts[v.clienteNombre] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  String get topProducto {
    if (state.ventas.isEmpty) return 'Sin datos';
    final counts = <String, int>{};
    for (var v in state.ventas) {
      counts[v.productoNombre] = (counts[v.productoNombre] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  int getFunnelValue(String etapa) {
    return state.ventas.where((v) => v.etapa == etapa).length;
  }

  void completarVenta(String id) {
    state = state.copyWith(
      ventas: state.ventas.map<Venta>((v) => v.id == id ? Venta(
        id: v.id,
        productoNombre: v.productoNombre,
        clienteNombre: v.clienteNombre,
        price: v.price,
        region: v.region,
        comuna: v.comuna,
        status: 'Completada',
        fecha: v.fecha,
        origen: v.origen,
        etapa: 'Cerrado',
      ) : v).toList(),
    );
    _saveToLocal();
  }

  void addCliente(String nombre) {
    if (!state.clientes.contains(nombre)) {
      state = state.copyWith(clientes: [...state.clientes, nombre]);
      _saveToLocal();
    }
  }
}

final ventasProvider = StateNotifierProvider<VentasNotifier, VentasState>((ref) {
  return VentasNotifier();
});
