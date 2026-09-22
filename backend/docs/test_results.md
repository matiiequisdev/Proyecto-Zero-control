# ✅ Reporte de Pruebas Automatizadas - ZeroCONTROL

Se ha implementado una suite completa de pruebas para asegurar la estabilidad del sistema, cubriendo tanto la lógica de negocio (Unit Tests) como la interfaz de usuario (UI Tests).

##  Resumen Ejecutivo
- **Total de pruebas ejecutadas:** 12
- **Pruebas Unitarias:** 9 (Aprobadas ✅)
- **Pruebas de Interfaz (Widget):** 3 (Aprobadas ✅)
- **Estado Global:** 100% Pass

---

## Pruebas Unitarias (8+ implementadas)
Ubicación: `test/unit_test.dart`

| ID | Nombre del Test | Objetivo | Resultado |
|:---|:---|:---|:---|
| 1 | UserProfile JSON Parsing | Verificar que el modelo de usuario lea correctamente los datos de MySQL. | ✅ PASS |
| 2 | Role Display Names | Asegurar que los roles (Admin, Técnico, etc.) se muestren correctamente en español. | ✅ PASS |
| 3 | Venta Map Parsing | Validar que los registros de ventas se procesen sin errores desde el Map. | ✅ PASS |
| 4 | VentasState Update | Confirmar que el estado de Riverpod se actualice al añadir nuevas ventas. | ✅ PASS |
| 5 | AuthState copyWith | Verificar la integridad de los datos al actualizar el estado de autenticación. | ✅ PASS |
| 6 | Producto Model | Validar el almacenamiento de stock y precios en el modelo de productos. | ✅ PASS |
| 7 | UserProfile copyWith | Asegurar que los cambios parciales en el perfil (como conexión) funcionen. | ✅ PASS |
| 8 | Vendedor Logic | Específico: Validar nombre de visualización del rol Vendedor. | ✅ PASS |
| 9 | Transportista Logic | Específico: Validar nombre de visualización del rol Transportista. | ✅ PASS |

---

##  Pruebas de Interfaz (3 implementadas)
Ubicación: `test/ui_test.dart`

| ID | Componente/Pantalla | Objetivo | Resultado |
|:---|:---|:---|:---|
| 1 | LoginScreen | Verificar la existencia de campos de Correo, Contraseña y botones de acceso. | ✅ PASS |
| 2 | RegisterScreen | Validar la visualización del selector de roles y el formulario de registro. | ✅ PASS |
| 3 | Stat Card | Probar que los componentes de métricas (Dashboard) rendericen valores dinámicos correctamente. | ✅ PASS |

---

## Instrucciones de Ejecución

Para volver a ejecutar las pruebas y verificar los resultados, usa los siguientes comandos en la terminal:

```bash
# Ejecutar todas las pruebas
flutter test

# Ejecutar solo unitarias
flutter test test/unit_test.dart

# Ejecutar solo interfaz
flutter test test/ui_test.dart
```

> [!TIP]
> Estas pruebas se ejecutan en un entorno simulado, por lo que no requieren tener XAMPP encendido ni un emulador conectado.
