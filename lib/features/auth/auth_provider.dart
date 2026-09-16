import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

enum UserRole { admin, tecnico, vendedor, transportista }

// Dirección del servidor (IP especial para emulador Android)
const String baseUrl = "http://10.0.2.2/zerocontrol";

class UserProfile {
  final String name;
  final String email;
  final UserRole role;
  final String? pin;
  final bool isConnected;
  final double? lat;
  final double? lng;
  final bool isBlocked;

  UserProfile({
    required this.name,
    required this.email,
    required this.role,
    this.pin,
    this.isConnected = true,
    this.lat,
    this.lng,
    this.isBlocked = false,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'role': role.index,
        'pin': pin,
        'isConnected': isConnected,
        'lat': lat,
        'lng': lng,
        'isBlocked': isBlocked,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] ?? 'Usuario',
        email: json['email'] ?? '',
        role: UserRole.values[json['role'] ?? 1], // Default to tecnico
        pin: json['pin'],
        isConnected: json['isConnected'] ?? true,
        lat: json['lat'] != null ? (json['lat'] as num).toDouble() : null,
        lng: json['lng'] != null ? (json['lng'] as num).toDouble() : null,
        isBlocked: json['isBlocked'] ?? false,
      );

  UserProfile copyWith({bool? isConnected, UserRole? role, double? lat, double? lng}) {
    return UserProfile(
      name: name,
      email: email,
      role: role ?? this.role,
      pin: pin,
      isConnected: isConnected ?? this.isConnected,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }

  String get roleDisplayName {
    switch (role) {
      case UserRole.tecnico:
        return 'Técnico';
      case UserRole.vendedor:
        return 'Vendedor';
      case UserRole.transportista:
        return 'Transportista';
      case UserRole.admin:
        return 'Administrador';
    }
  }
}

class AuthState {
  final UserProfile? user;
  final int loginAttempts;
  final bool isBlocked;
  final List<UserProfile> registeredUsers;
  final bool isInitialized;

  AuthState({
    this.user,
    this.loginAttempts = 0,
    this.isBlocked = false,
    this.registeredUsers = const [],
    this.isInitialized = false,
  });

  AuthState copyWith({
    UserProfile? Function()? user,
    int? loginAttempts,
    bool? isBlocked,
    List<UserProfile>? registeredUsers,
    bool? isInitialized,
  }) {
    return AuthState(
      user: user != null ? user() : this.user,
      loginAttempts: loginAttempts ?? this.loginAttempts,
      isBlocked: isBlocked ?? this.isBlocked,
      registeredUsers: registeredUsers ?? this.registeredUsers,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    init();
  }

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Cargar sesión actual local (opcional para mantener login)
      final userJson = prefs.getString('current_user');
      UserProfile? currentUser;
      if (userJson != null) {
        currentUser = UserProfile.fromJson(jsonDecode(userJson));
      }

      state = state.copyWith(
        user: () => currentUser,
        isInitialized: true,
      );
      
      // Si hay un admin logueado, cargar la lista real de usuarios
      if (currentUser?.role == UserRole.admin) {
        await refreshUsers();
      }
    } catch (e) {
      state = state.copyWith(isInitialized: true);
    }
  }

  Future<void> refreshUsers() async {
    try {
      print("🔍 Conectando a MySQL en: $baseUrl/get_users.php");
      final response = await http.get(Uri.parse('$baseUrl/get_users.php')).timeout(const Duration(seconds: 10));
      
      print("📡 Servidor respondió con código: ${response.statusCode}");
      print("📄 Cuerpo de respuesta: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> usersData = data['users'];
          final users = usersData.map((u) => UserProfile.fromJson(u)).toList();
          state = state.copyWith(registeredUsers: users);
          print("✅ Sincronización exitosa: ${users.length} usuarios encontrados.");
        } else {
          print("❌ Error en PHP: ${data['message']}");
        }
      } else {
        print("❌ El servidor XAMPP no está respondiendo correctamente (Error ${response.statusCode})");
      }
    } catch (e) {
      print("🚨 Error de conexión crítico: $e");
      print("💡 Asegúrate de que XAMPP esté encendido y Apache funcionando.");
    }
  }

  Future<bool> login(String email, String password) async {
    if (state.isBlocked) return false;

    try {
      print("Intentando login para: $email");
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      print("Respuesta login (${response.statusCode}): ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          final user = UserProfile.fromJson(data['user']);
          state = state.copyWith(
            user: () => user,
            loginAttempts: 0,
          );
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('current_user', jsonEncode(user.toJson()));
          
          // Refrescar lista si es admin
          await refreshUsers();
          return true;
        } else {
          print("Fallo de login: ${data['message']}");
          return false;
        }
      }
    } catch (e) {
      print("Error de red en login: $e");
    }
    return false;
  }

  Future<bool> register(String name, String email, UserRole role, String pin) async {
    try {
      print("Registrando usuario real en MySQL: $email");
      final response = await http.post(
        Uri.parse('$baseUrl/register.php'),
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': pin,
          'role': role.index,
        }),
      );
      print("Respuesta registro (${response.statusCode}): ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          print("Registro exitoso en MySQL");
          return await login(email, pin);
        } else {
          print("Fallo en registro PHP: ${data['message']}");
        }
      }
    } catch (e) {
      print("Error de red en registro: $e");
    }
    return false;
  }

  Future<void> blockUser(String email, bool block) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/update_user.php'),
        body: jsonEncode({
          'email': email,
          'is_blocked': block ? 1 : 0,
        }),
      );
      await refreshUsers();
    } catch (e) {
      print("Error bloqueando: $e");
    }
  }

  Future<void> deleteUser(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/delete_user.php'),
        body: jsonEncode({'email': email}),
      );
      if (response.statusCode == 200) {
        await refreshUsers();
      }
    } catch (e) {
      print("Error eliminando usuario: $e");
    }
  }

  Future<void> changePasswordAdmin(String email, String newPass) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/update_user.php'),
        body: jsonEncode({
          'email': email,
          'password': newPass,
        }),
      );
      await refreshUsers();
    } catch (e) {
      print("Error password: $e");
    }
  }

  void restorePassword() {
    state = state.copyWith(
      loginAttempts: 0,
      isBlocked: false,
    );
  }

  Future<bool> resetPassword(String email, String newPin) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/update_user.php'),
        body: jsonEncode({
          'email': email,
          'password': newPin,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }
    } catch (e) {
      print("Error reseteando password: $e");
    }
    return false;
  }

  Future<void> toggleConnection() async {
    if (state.user != null) {
      final newStatus = !state.user!.isConnected;
      try {
        // En producción real, update_user.php debería soportar is_connected
        final response = await http.post(
          Uri.parse('$baseUrl/update_user.php'),
          body: jsonEncode({
            'email': state.user!.email,
            'is_connected': newStatus ? 1 : 0,
          }),
        );
        
        if (response.statusCode == 200) {
          final updatedUser = state.user!.copyWith(isConnected: newStatus);
          state = state.copyWith(user: () => updatedUser);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('current_user', jsonEncode(updatedUser.toJson()));
        }
      } catch (e) {
        print("Error toggling connection: $e");
      }
    }
  }

  Future<void> adminUpdateUserRole(String email, UserRole newRole) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/update_user.php'),
        body: jsonEncode({
          'email': email,
          'role': newRole.index,
        }),
      );
      await refreshUsers();
    } catch (e) {
      print("Error admin actualizando rol: $e");
    }
  }

  void logout() async {
    state = state.copyWith(user: () => null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
  }

  Future<void> changeRole(UserRole newRole) async {
    if (state.user != null) {
      try {
        // Actualizar en MySQL (opcional, pero recomendado)
        await http.post(
          Uri.parse('$baseUrl/update_user.php'),
          body: jsonEncode({
            'email': state.user!.email,
            'role': newRole.index,
          }),
        );

        final updatedUser = state.user!.copyWith(role: newRole);
        state = state.copyWith(user: () => updatedUser);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_user', jsonEncode(updatedUser.toJson()));
        
        await refreshUsers();
      } catch (e) {
        print("Error cambiando rol: $e");
      }
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
