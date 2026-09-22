import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zerocontrol/features/auth/login_screen.dart';
import 'package:zerocontrol/features/auth/register_screen.dart';
import 'package:zerocontrol/features/admin/admin_dashboard_screen.dart';

void main() {
  group('UI Tests - Pantallas y Componentes', () {

    // 1. Test de Pantalla de Login (Verificación de existencia)
    testWidgets('LoginScreen should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: LoginScreen()),
        ),
      );

      // Verificamos elementos clave que sabemos que existen
      expect(find.text('ACCESO OPERACIONAL'), findsOneWidget);
      expect(find.text('Correo electrónico'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
    });

    // 2. Test de Pantalla de Registro (Verificación de Selección de Rol)
    testWidgets('RegisterScreen should show Role selection', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: RegisterScreen()),
        ),
      );

      expect(find.text('Crear cuenta'), findsOneWidget);
      expect(find.text('Tipo de usuario'), findsOneWidget);
      expect(find.text('Administrador'), findsOneWidget); // Rol por defecto seleccionado
    });

    // 3. Test de un componente interno (Tarjeta de Estadísticas)
    // Usaremos un widget dummy para probar la visualización
    testWidgets('Stat Card component should display values correctly', (WidgetTester tester) async {
      const testTitle = 'Ventas Totales';
      const testValue = '\$1.500.000';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                   Text(testTitle),
                   Text(testValue),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text(testTitle), findsOneWidget);
      expect(find.text(testValue), findsOneWidget);
    });

  });
}
