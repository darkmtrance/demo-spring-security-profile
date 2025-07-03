# Demo Spring Security Profile

Una aplicación Spring Boot que demuestra autenticación JWT con Spring Security y configuración dinámica por perfiles.

> 🚀 **Repositorio GitHub:** https://github.com/darkmtrance/demo-spring-security-profile

## Características

- ✅ Autenticación JWT con Spring Security
- ✅ Registro y login de usuarios
- ✅ Endpoints protegidos y públicos
- ✅ Configuración por perfiles (dev/prod)
- ✅ Base de datos H2 para desarrollo
- ✅ Configuración para PostgreSQL en producción
- ✅ Validación de datos con Bean Validation
- ✅ Contraseñas hasheadas con BCrypt

## Tecnologías

- Spring Boot 3.2
- Spring Security 6.2
- JWT (JJWT)
- H2 Database (dev)
- PostgreSQL (prod)
- Liquibase
- Maven

## Configuración

### Perfiles disponibles

#### Desarrollo (`dev`)
- Base de datos H2 en memoria
- Consola H2 habilitada en `/h2-console`
- Logging detallado

#### Producción (`prod`)
- Base de datos PostgreSQL
- Logging reducido
- Configuración optimizada

### Activar perfiles

```bash
# Perfil desarrollo (por defecto)
mvn spring-boot:run

# Perfil desarrollo explícito
mvn spring-boot:run -Dspring.profiles.active=dev

# Perfil producción
mvn spring-boot:run -Dspring.profiles.active=prod
```

## Endpoints

### Públicos
- `POST /api/auth/signup` - Registro de usuario
- `POST /api/auth/login` - Inicio de sesión
- `GET /h2-console/**` - Consola H2 (solo en dev)

### Protegidos (requieren JWT)
- `GET /api/protected/hello` - Mensaje de bienvenida
- `GET /api/protected/profile` - Información del perfil

## Uso

### 1. Registro de usuario
```bash
curl -X POST http://localhost:8080/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123"
  }'
```

### 2. Inicio de sesión
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }'
```

Respuesta:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "email": "john@example.com",
  "name": "John Doe"
}
```

### 3. Acceso a endpoints protegidos
```bash
curl -X GET http://localhost:8080/api/protected/hello \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

## Configuración de base de datos

### Para desarrollo (H2)
No se requiere configuración adicional. La base de datos se crea automáticamente.

### Para producción (PostgreSQL)
1. Instalar PostgreSQL
2. Crear base de datos:
```sql
CREATE DATABASE demodb;
```
3. Configurar credenciales en `application-prod.properties`

## Ejecución

```bash
# Compilar
mvn clean compile

# Ejecutar en desarrollo
mvn spring-boot:run

# Ejecutar en producción
mvn spring-boot:run -Dspring.profiles.active=prod

# Compilar JAR
mvn clean package

# Ejecutar JAR
java -jar target/demo-spring-security-profile-1.0.0.jar --spring.profiles.active=dev
```

## Consola H2 (solo en desarrollo)

Acceder a: http://localhost:8080/h2-console

- JDBC URL: `jdbc:h2:mem:testdb`
- Username: `sa`
- Password: (vacío)

## Estructura del proyecto

```
src/
├── main/
│   ├── java/
│   │   └── com/example/demospringboot/
│   │       ├── config/
│   │       │   └── SecurityConfig.java
│   │       ├── controller/
│   │       │   ├── AuthController.java
│   │       │   └── ProtectedController.java
│   │       ├── dto/
│   │       │   ├── LoginRequest.java
│   │       │   ├── LoginResponse.java
│   │       │   └── SignupRequest.java
│   │       ├── model/
│   │       │   └── User.java
│   │       ├── repository/
│   │       │   └── UserRepository.java
│   │       ├── security/
│   │       │   ├── JwtAuthFilter.java
│   │       │   ├── JwtHelper.java
│   │       │   └── UserDetailsServiceImpl.java
│   │       ├── service/
│   │       │   └── UserService.java
│   │       └── DemoSpringSecurityProfileApplication.java
│   └── resources/
│       ├── db/
│       │   └── changelog/
│       │       ├── db.changelog-master.xml
│       │       └── 001-create-user-table.xml
│       ├── application.properties
│       ├── application-dev.properties
│       └── application-prod.properties
└── test/
    └── java/
        └── com/example/demospringboot/
            └── DemoSpringSecurityProfileApplicationTests.java
```

## 🧪 Testing de la API

Disponemos de múltiples métodos para probar la API:

### 1. REST Client (Recomendado) 📄

**Archivo**: `test-api.http`

El método más completo y fácil de usar:

```bash
# 1. Instalar extensión "REST Client" en VS Code
# 2. Abrir test-api.http
# 3. Hacer clic en "Send Request" arriba de cada endpoint
# 4. Copiar el token JWT del login para usarlo en endpoints protegidos
```

### 2. Scripts Automatizados 🤖

```bash
# Bash (Linux/Mac/WSL)
./test-api.sh

# PowerShell (Windows)
.\test-api.ps1
```

### 3. cURL Manual 🌐

```bash
# Registrar usuario
curl -X POST http://localhost:8080/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"name":"John Doe","email":"john@example.com","password":"password123"}'

# Login
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"john@example.com","password":"password123"}'

# Acceder a endpoint protegido (usar el token del login)
curl -X GET http://localhost:8080/api/protected/hello \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE"
```

### 4. Herramientas Externas 🔧

- **Postman**: Importar endpoints desde `test-api.http`
- **Insomnia**: Compatible con formato REST Client
- **Thunder Client**: Extensión de VS Code alternativa

Ver [`TESTING.md`](./TESTING.md) para instrucciones detalladas.

## Notas de seguridad

- El JWT secret debe ser cambiado en producción
- Las contraseñas se hashean con BCrypt
- Los tokens JWT expiran en 24 horas
- CORS y CSRF están deshabilitados para simplificar las pruebas
