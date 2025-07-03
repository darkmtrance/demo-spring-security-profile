# 🧪 Guía de Pruebas - Demo Spring Security Profile

Esta guía detalla cómo probar todas las funcionalidades del proyecto.

## 🚀 Preparación

### 1. Ejecutar la aplicación
```bash
# Modo desarrollo (H2)
mvn spring-boot:run -Dspring-boot.run.profiles=dev

# Modo producción (PostgreSQL)
mvn spring-boot:run -Dspring-boot.run.profiles=prod
```

### 2. Verificar que la aplicación está corriendo
```bash
curl http://localhost:8080/h2-console
# Debería devolver la página de la consola H2
```

## 📋 Casos de Prueba

### ✅ Caso 1: Registro de Usuario

**Objetivo**: Registrar un nuevo usuario en el sistema

```bash
curl -X POST http://localhost:8080/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "name": "María García",
    "email": "maria@example.com",
    "password": "password123"
  }'
```

**Respuesta esperada** (200 OK):
```json
{
  "message": "User registered successfully",
  "user": {
    "id": 1,
    "name": "María García",
    "email": "maria@example.com"
  }
}
```

### ✅ Caso 2: Login Exitoso

**Objetivo**: Autenticar usuario y obtener JWT

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "maria@example.com",
    "password": "password123"
  }'
```

**Respuesta esperada** (200 OK):
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "email": "maria@example.com",
  "name": "María García"
}
```

### ❌ Caso 3: Login con Credenciales Incorrectas

**Objetivo**: Verificar que login falla con contraseña incorrecta

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "maria@example.com",
    "password": "wrongpassword"
  }'
```

**Respuesta esperada** (400 Bad Request):
```json
{
  "error": "Invalid credentials"
}
```

### ❌ Caso 4: Acceso a Endpoint Protegido Sin Token

**Objetivo**: Verificar que endpoint protegido rechaza requests sin JWT

```bash
curl -X GET http://localhost:8080/api/protected/hello
```

**Respuesta esperada** (403 Forbidden):
```json
{
  "timestamp": "2025-07-03T05:00:00.000+00:00",
  "status": 403,
  "error": "Forbidden",
  "path": "/api/protected/hello"
}
```

### ✅ Caso 5: Acceso a Endpoint Protegido Con Token

**Objetivo**: Verificar que endpoint protegido acepta JWT válido

```bash
# Usar el token obtenido del login
curl -X GET http://localhost:8080/api/protected/hello \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9..."
```

**Respuesta esperada** (200 OK):
```json
{
  "message": "Hello from protected endpoint!",
  "user": "maria@example.com",
  "timestamp": 1751519104727
}
```

### ✅ Caso 6: Endpoint de Perfil

**Objetivo**: Obtener información del perfil del usuario

```bash
curl -X GET http://localhost:8080/api/protected/profile \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9..."
```

**Respuesta esperada** (200 OK):
```json
{
  "message": "This is your profile",
  "email": "maria@example.com",
  "authorities": []
}
```

### ❌ Caso 7: Registro con Email Duplicado

**Objetivo**: Verificar que no se permiten emails duplicados

```bash
# Intentar registrar el mismo email otra vez
curl -X POST http://localhost:8080/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Otro Usuario",
    "email": "maria@example.com",
    "password": "password456"
  }'
```

**Respuesta esperada** (400 Bad Request):
```json
{
  "error": "Email already exists"
}
```

### ❌ Caso 8: Registro con Datos Inválidos

**Objetivo**: Verificar validación de datos en registro

```bash
curl -X POST http://localhost:8080/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "name": "",
    "email": "invalid-email",
    "password": "123"
  }'
```

**Respuesta esperada** (400 Bad Request):
```json
{
  "error": "Validation failed: ..."
}
```

## 🔍 Verificación de Perfiles

### Perfil Development
```bash
# Verificar logs detallados
tail -f application.log | grep DEBUG

# Acceder a consola H2
http://localhost:8080/h2-console
# JDBC URL: jdbc:h2:mem:testdb
# User: sa
# Password: (vacío)
```

### Perfil Production
```bash
# Verificar conexión a PostgreSQL
# Los logs deberían mostrar:
# "HikariPool-1 - Starting..."
# "Database available at 'jdbc:postgresql://localhost:5432/demodb'"
```

## 🛠️ Scripts Automatizados

### PowerShell (Windows)
```powershell
# Ejecutar todas las pruebas
.\test-endpoints.ps1
```

### Bash (Linux/Mac)
```bash
# Hacer ejecutable
chmod +x test-endpoints.sh

# Ejecutar todas las pruebas
./test-endpoints.sh
```

## 📊 Resultados Esperados

| Caso de Prueba | Status Code | Autenticación | Resultado |
|----------------|-------------|---------------|-----------|
| Registro nuevo usuario | 200 | No | Usuario creado |
| Login válido | 200 | No | JWT devuelto |
| Login inválido | 400 | No | Error de credenciales |
| Endpoint sin token | 403 | Requerida | Acceso denegado |
| Endpoint con token | 200 | Válida | Acceso permitido |
| Perfil con token | 200 | Válida | Datos del perfil |
| Email duplicado | 400 | No | Error de validación |
| Datos inválidos | 400 | No | Error de validación |

## 🔧 Troubleshooting

### Error "Connection refused"
- Verificar que la aplicación esté ejecutándose en puerto 8080
- Comprobar que no haya otros procesos usando el puerto

### Error 500 "Database connection"
- Para perfil `prod`: verificar que PostgreSQL esté ejecutándose
- Comprobar credenciales de base de datos en `application-prod.properties`

### Token expirado
- Los tokens JWT expiran en 24 horas
- Realizar login nuevamente para obtener token fresco

### Problemas de validación
- Verificar que el JSON esté bien formateado
- Comprobar que los campos requeridos estén presentes
- Validar formato de email y longitud de contraseña

## 📝 Notas Adicionales

- **Consola H2**: Disponible solo en perfil `dev` en `/h2-console`
- **JWT Secret**: Configurable en `application.properties`
- **Duración Token**: 24 horas por defecto
- **Base de datos**: Se recrea en cada reinicio en modo `dev`
- **Logs**: Configurables por perfil para diferentes niveles de detalle
