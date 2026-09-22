#  Documentación de Endpoints - ZeroCONTROL API

Esta es la lista de funciones (Endpoints) que tu aplicación utiliza para comunicarse con el servidor XAMPP (MySQL).

## 📍 Base URL
`http://localhost/zerocontrol/` (Para pruebas en navegador)
`http://10.0.2.2/zerocontrol/` (Para el emulador de Android)

---

### Registro de Usuario
**URL:** `register.php`
**Método:** `POST`
**Cuerpo (JSON):**
```json
{
  "name": "Nombre Usuario",
  "email": "correo@gmail.com",
  "password": "tu_password",
  "role": 0 
}
```
> *Roles: 0: Admin, 1: Técnico, 2: Vendedor, 3: Transportista*

### 2️⃣ Inicio de Sesión
**URL:** `login.php`
**Método:** `POST`
**Cuerpo (JSON):**
```json
{
  "email": "correo@gmail.com",
  "password": "tu_password"
}
```

### Obtener Todos los Usuarios (Solo Admin)
**URL:** `get_users.php`
**Método:** `GET`
**Respuesta:** Devuelve una lista con todos los usuarios registrados en MySQL.

### 4️⃣ Actualizar Usuario (Rol, Clave, Bloqueo)
**URL:** `update_user.php`
**Método:** `POST`
**Cuerpo (JSON):**
```json
{
  "email": "correo@gmail.com",
  "password": "nueva_password",  // Opcional
  "is_blocked": 1,               // Opcional (1: Bloqueado, 0: Activo)
  "role": 2                      // Opcional
}
```

### 5️⃣ Eliminar Usuario
**URL:** `delete_user.php`
**Método:** `POST`
**Cuerpo (JSON):**
```json
{
  "email": "correo@gmail.com"
}
```

---

