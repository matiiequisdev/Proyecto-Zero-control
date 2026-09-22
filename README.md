# ZeroCONTROL ❄️
Sistema profesional de gestión operativa para activos refrigerados, diseñado para centralizar el control de personal, ventas y logística en tiempo real.

## 📋 Descripción del Proyecto
ZeroCONTROL es una aplicación móvil desarrollada en **Flutter** que permite a las empresas gestionar su operación en terreno de manera eficiente. El sistema destaca por su robustez técnica, contando con un sistema de roles jerárquico y sincronización bidireccional con una base de datos centralizada en **MySQL**.

### ✨ Características Principales
- **Autenticación Real**: Login y registro sincronizado con servidor PHP/MySQL (XAMPP).
- **Gestión de Roles**: Soporte para Administrador, Técnico, Vendedor y Transportista.
- **Panel Administrativo Maestro**:
  - Control total de usuarios (Crear, bloquear, cambiar rol, eliminar).
  - Restauración de contraseñas de operarios de forma remota.
- **Reportes Profesionales**: Motor de exportación de datos a formatos **Excel (.xlsx)** y **PDF** elegantes.
- **Visualización de Datos**: Dashboards interactivos con métricas reales de ventas y rendimiento semanal.
- **Modo Oscuro Global**: Interfaz 100% adaptable para mejorar la experiencia de usuario en cualquier condición lumínica.
- **Documentación API**: Integración con **Swagger UI** para pruebas y visualización de Endpoints.

---

## 🛠️ Tecnologías y Librerías
### Stack Técnico
- **Frontend**: Flutter (Dart) bajo arquitectura *Feature-First*.
- **Estado**: **Riverpod** para una gestión de datos reactiva y centralizada.
- **Base de Datos**: **MySQL** (MariaDB) gestionada mediante XAMPP.
- **Backend**: API REST personalizada desarrollada en **PHP**.

### Librerías Principales
- `flutter_riverpod`: Motor de gestión de estado.
- `http`: Protocolo de comunicación con el servidor local.
- `excel` & `pdf`: Generación dinámica de reportes corporativos.
- `share_plus`: Integración nativa para compartir archivos y reportes.
- `file_picker`: Selector de archivos profesional para descargas en memoria interna.
- `google_fonts`: Implementación de la familia tipográfica *Inter*.

---

## 🚀 Guía de Ejecución Paso a Paso

Sigue estas instrucciones para desplegar el entorno completo en tu máquina local:

### 1. Configuración del Servidor y Base de Datos (XAMPP)
1. Abre **XAMPP Control Panel** e inicia los módulos **Apache** y **MySQL**.
2. Entra a `http://localhost/phpmyadmin/`.
3. Crea una nueva base de datos llamada `zerocontrol`.
4. Importa el archivo `backend/database.sql` ubicado en la raíz del proyecto para crear las tablas necesarias.

### 2. Instalación del Backend (El Puente)
1. Navega a la carpeta `htdocs` de tu instalación de XAMPP (ej: `C:\xampp\htdocs`).
2. Crea una carpeta llamada `zerocontrol`.
3. Copia todos los archivos `.php` de la carpeta `backend` de este proyecto a esa nueva carpeta en htdocs.
4. Copia también la carpeta `swagger` si deseas usar la documentación interactiva.

### 3. Lanzamiento de la Aplicación
1. Abre el proyecto en **Android Studio**.
2. Ejecuta `flutter pub get` en la terminal para descargar las dependencias.
3. Inicia un emulador de Android (Pixel/Nexus recomendado).
4. Presiona **Run (F5)**. 
   - *Dato Técnico: La App conecta con tu PC usando la IP especial `10.0.2.2`.*

---

## 🧪 Pruebas Automatizadas
El proyecto cuenta con una suite de **12 pruebas** que garantizan la estabilidad de la lógica y la interfaz:
```bash
# Ejecutar todas las pruebas (Unitarias y UI)
flutter test
```

## 📖 Swagger UI
Puedes monitorear tu servidor en tiempo real entrando a:
👉 `http://localhost/zerocontrol/swagger/`

---

## 🔗 Recursos Oficiales de Flutter (Blue Letters)
Si es tu primera vez trabajando con este framework, estos enlaces te serán de gran ayuda:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

Para asistencia técnica detallada, visita la [online documentation](https://docs.flutter.dev/), donde encontrarás tutoriales, ejemplos y la referencia completa de la API de Flutter.
