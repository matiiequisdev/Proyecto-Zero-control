import 'package:flutter_test/flutter_test.dart';
import 'package:zerocontrol/features/auth/auth_provider.dart';
import 'package:zerocontrol/features/ventas/ventas_provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Inicialización necesaria para tests que usen plugins o bindings de Flutter
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Mock de SharedPreferences para evitar errores de persistencia en tests
  SharedPreferences.setMockInitialValues({});

  group('Unit Tests - Modelos y Lógica de Negocio', () {
    
    // 1. Test de parseo de Usuario
    test('UserProfile should parse correctly from JSON', () {
      final json = {
        'name': 'Matias',
        'email': 'matias@gmail.com',
        'role': 0,
        'isConnected': true,
      };
      final user = UserProfile.fromJson(json);
      expect(user.name, 'Matias');
      expect(user.role, UserRole.admin);
    });

    // 2. Test de visualización de Roles
    test('UserProfile should return correct role display name', () {
      final user = UserProfile(name: 'Test', email: 'test@gmail.com', role: UserRole.tecnico);
      expect(user.roleDisplayName, 'Técnico');
      
      final admin = UserProfile(name: 'Admin', email: 'admin@gmail.com', role: UserRole.admin);
      expect(admin.roleDisplayName, 'Administrador');
    });

    // 3. Test de parseo de Ventas
    test('Venta should parse correctly from Map', () {
      final map = {
        'id': 'V-100',
        'productoNombre': 'FREEZER',
        'clienteNombre': 'Cliente 1',
        'price': '\$100.000',
        'status': 'Completada',
        'fecha': DateTime.now().toIso8601String(),
      };
      final venta = Venta.fromMap(map);
      expect(venta.id, 'V-100');
      expect(venta.price, '\$100.000');
    });

    // 4. Test de Lógica de Ventas (Filtrado de Estado)
    test('VentasState copyWith should update list correctly', () {
      final state = VentasState(productos: [], ventas: [], clientes: [], unidadesDisponibles: 10);
      final newVenta = Venta(id: '1', productoNombre: 'A', clienteNombre: 'B', price: '0', region: 'R', comuna: 'C', status: 'S', fecha: DateTime.now(), origen: 'O', etapa: 'E');
      final updated = state.copyWith(ventas: [newVenta]);
      expect(updated.ventas.length, 1);
    });

    // 5. Test de Copia de Estado (Auth)
    test('AuthState copyWith should update fields correctly', () {
      final state = AuthState(loginAttempts: 1, isBlocked: false);
      final updated = state.copyWith(loginAttempts: 2, isBlocked: true);
      expect(updated.loginAttempts, 2);
      expect(updated.isBlocked, true);
    });

    // 6. Test de Modelo Producto
    test('Producto model should store data correctly', () {
      final product = Producto(
        id: '1', 
        name: 'Refri', 
        subtitle: 'Pro', 
        stock: 10, 
        price: '\$500', 
        color: Colors.blue
      );
      expect(product.stock, 10);
      expect(product.name, 'Refri');
    });

    // 7. Test de copyWith de UserProfile
    test('UserProfile copyWith should update connection status', () {
      final user = UserProfile(name: 'A', email: 'a@gmail.com', role: UserRole.vendedor);
      final updatedUser = user.copyWith(isConnected: false);
      expect(updatedUser.isConnected, false);
    });

    // 8. Test de lógica de Display Name de Vendedor
    test('Vendedor role display name check', () {
      final user = UserProfile(name: 'V', email: 'v@gmail.com', role: UserRole.vendedor);
      expect(user.roleDisplayName, 'Vendedor');
    });

    // 9. Extra: Test de lógica de Display Name de Transportista
    test('Transportista role display name check', () {
      final user = UserProfile(name: 'T', email: 't@gmail.com', role: UserRole.transportista);
      expect(user.roleDisplayName, 'Transportista');
    });

  });
}
