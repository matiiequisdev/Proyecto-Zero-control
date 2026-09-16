# Implementación del Rol de Administrador en ZeroCONTROL

Este plan detalla la creación del panel de administración "todo en uno" para ZeroCONTROL, permitiendo la supervisión global de la operación, gestión de usuarios, visualización de activos y reportes.

## User Review Required

> [!IMPORTANT]
> El rol de Administrador tendrá acceso a datos sensibles (todos los usuarios y activos). Se habilitará la opción de registro como Administrador para facilitar las pruebas del reto.

## Proposed Changes

### Core & Auth
- **[MODIFY] [auth_provider.dart](file:///C:/Users/Matiiequisde/Documents/zerocontrol/lib/features/auth/auth_provider.dart)**: Añadir `admin` al enum `UserRole`.
- **[MODIFY] [register_screen.dart](file:///C:/Users/Matiiequisde/Documents/zerocontrol/lib/features/auth/register_screen.dart)**: Incluir el botón de Administrador en la selección de tipo de usuario.

### UI & Navigation
- **[MODIFY] [dashboard_layout.dart](file:///C:/Users/Matiiequisde/Documents/zerocontrol/lib/features/dashboard/dashboard_layout.dart)**:
  - Actualizar el Sidebar para mostrar el menú de Admin.
  - Configurar el flujo de pantallas para el rol Admin.

### Admin Feature [NEW]
- **[NEW] [admin_dashboard_screen.dart](file:///C:/Users/Matiiequisde/Documents/zerocontrol/lib/features/admin/admin_dashboard_screen.dart)**: Panel de control con métricas globales y gráficos.
- **[NEW] [user_management_screen.dart](file:///C:/Users/Matiiequisde/Documents/zerocontrol/lib/features/admin/user_management_screen.dart)**: Lista de usuarios con opción de bloqueo/edición.
- **[NEW] [admin_map_screen.dart](file:///C:/Users/Matiiequisde/Documents/zerocontrol/lib/features/admin/admin_map_screen.dart)**: Mapa con ubicación de trabajadores.
- **[NEW] [admin_assets_screen.dart](file:///C:/Users/Matiiequisde/Documents/zerocontrol/lib/features/admin/admin_assets_screen.dart)**: Inventario maestro de activos.

## Verification Plan

### Automated Tests
- No se requieren por ahora, verificación visual manual.

### Manual Verification
1. Registrar un nuevo usuario con el rol **Administrador**.
2. Verificar que el Sidebar muestre: "Dashboard Global", "Gestión de Usuarios", "Mapa en Tiempo Real", "Inventario Maestro".
3. Validar que los gráficos en el Dashboard muestren datos ficticios pero coherentes con la base de datos local.
4. Probar la descarga de reportes (simulada con un SnackBar o impresión en consola).
