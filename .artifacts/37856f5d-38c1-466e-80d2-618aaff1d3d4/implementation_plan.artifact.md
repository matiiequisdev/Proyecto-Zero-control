# Plan de Implementación: ZeroControl App

Este plan detalla la creación de la aplicación ZeroControl siguiendo los diseños proporcionados en las capturas de pantalla, incluyendo el flujo de login, dashboard con pestañas y el proceso de registro de visitas en 3 pasos.

## User Review Required

> [!IMPORTANT]
> - Se utilizará **Material Design 3** con una paleta de colores personalizada (Teal/Cian) para coincidir con las imágenes.
> - La navegación se gestionará con `go_router`.
> - El estado global se manejará con `flutter_riverpod`.
> - La cámara y el GPS serán simulados o integrados mediante plugins estándar de Flutter (`camera`, `geolocator`).

## Proposed Changes

### Dependencias y Configuración

#### [MODIFY] [pubspec.yaml](file:///C:/Users/Matiiequisde/StudioProjects/Zerocontrol/pubspec.yaml)
- Añadir `flutter_riverpod`, `go_router`, `geolocator`, `camera`, `google_fonts`, `animate_do`.

---

### Arquitectura de UI y Pantallas

#### [NEW] [theme.dart](file:///C:/Users/Matiiequisde/StudioProjects/Zerocontrol/lib/core/theme.dart)
- Definición del `ThemeData` con Material 3 y colores corporativos de ZeroControl.

#### [NEW] [login_screen.dart](file:///C:/Users/Matiiequisde/StudioProjects/Zerocontrol/lib/features/auth/login_screen.dart)
- Implementación de la pantalla de login con selección de roles (Técnico, Vendedor, Transportista).
- Validación simple de email (@distribuidora.cl).

#### [NEW] [splash_screen.dart](file:///C:/Users/Matiiequisde/StudioProjects/Zerocontrol/lib/features/auth/splash_screen.dart)
- Animación de entrada personalizada por rol que muestra "Hola, [Nombre] - [Rol]".

#### [NEW] [dashboard_layout.dart](file:///C:/Users/Matiiequisde/StudioProjects/Zerocontrol/lib/features/dashboard/dashboard_layout.dart)
- Estructura principal con Sidebar (en pantallas grandes) o Bottom Navigation.
- Pestañas: Mis Activos, Mapa de Visitas, Historial.

#### [NEW] [activos_screen.dart](file:///C:/Users/Matiiequisde/StudioProjects/Zerocontrol/lib/features/activos/activos_screen.dart)
- Vista de "Mis activos" con tarjetas detalladas (Conservadora vertical, Freezer, etc.).

#### [NEW] [mapa_visitas_screen.dart](file:///C:/Users/Matiiequisde/StudioProjects/Zerocontrol/lib/features/visitas/mapa_visitas_screen.dart)
- Formulario "Agregar un lugar a tu ruta".
- Vista de mapa (simulada con un widget de imagen/placeholder similar a la captura).
- Lista de "Visitas cercanas".

#### [NEW] [visit_workflow_screen.dart](file:///C:/Users/Matiiequisde/StudioProjects/Zerocontrol/lib/features/visitas/visit_workflow_screen.dart)
- Flujo de 3 pasos:
    - **Paso 1 (NFC)**: Pantalla de validación de presencia con botón de simulación.
    - **Paso 2 (Evidencia)**: Captura de GPS y apertura de cámara.
    - **Paso 3 (Detalles)**: Formulario final de detalles de la visita.

---

### Lógica y Estado

#### [NEW] [auth_provider.dart](file:///C:/Users/Matiiequisde/StudioProjects/Zerocontrol/lib/features/auth/auth_provider.dart)
- Gestión del usuario logueado y su rol.

#### [NEW] [activos_provider.dart](file:///C:/Users/Matiiequisde/StudioProjects/Zerocontrol/lib/features/activos/activos_provider.dart)
- Estado de los activos y sincronización con el historial.

## Verification Plan

### Manual Verification
1.  **Login**: Probar ingresar con un email de distribuidora y seleccionar cada rol.
2.  **Splash**: Verificar que la animación y el texto correspondan al rol seleccionado.
3.  **Dashboard**: Navegar entre las 3 pestañas principales.
4.  **Mapa**: Agregar un lugar a la ruta y ver si se refleja en la UI.
5.  **Flujo de Visita**:
    - Presionar "Registrar visita" en un activo.
    - Simular NFC.
    - Capturar ubicación (GPS) y abrir cámara.
    - Completar el paso 3.
