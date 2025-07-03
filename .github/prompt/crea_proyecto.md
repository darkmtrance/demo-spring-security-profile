# 🎯 Prompt para el Proyecto Demo: Autenticación JWT con Spring Security y Configuración Dinámica por Perfiles en Spring Boot

## ✅ Objetivo General
Desarrollar una aplicación Spring Boot mínima para demostrar autenticación y autorización basada en JWT usando Spring Security, y cómo adaptar la configuración según el entorno usando Spring Boot Profiles.

---

## ⭐ Características Clave a Demostrar

### 1️⃣ Autenticación y Autorización con JWT
- Flujo completo de registro (`/signup`) y login (`/login`) mediante APIs RESTful.
- Generación y entrega de un JWT al cliente tras un login exitoso.
- Las solicitudes a recursos protegidos deben incluir el JWT en el encabezado `Authorization`.
- Diferenciación entre endpoints públicos (registro, login, documentación) y protegidos.
- Autenticación sin estado (stateless) para mayor escalabilidad.
- Contraseñas hasheadas con `BCryptPasswordEncoder`.

### 2️⃣ Configuración Adaptable con Spring Boot Profiles
- Definir al menos dos perfiles: `dev` y `prod`.
- Configuraciones de base de datos y logging distintas por perfil.
- Uso de archivos de propiedades separados:
  - `application.properties`
  - `application-dev.properties`
  - `application-prod.properties`
- Métodos para activar perfiles: argumento `-Dspring.profiles.active=dev|prod`, variables de entorno, o configuración en el IDE.

---

## ⚙️ Pila Tecnológica y Dependencias
- Spring Boot 3.2+
- Spring Security 6.2+
- JWT: `jjwt-api`, `jjwt-impl`, `jjwt-jackson`
- Spring Boot Starter Web
- Spring Boot Starter Security
- Bases de Datos:
  - **PostgreSQL** para `prod`.
  - **H2 (in-memory)** para `dev`.
- Liquibase
- Spring Boot Starter Validation
- Maven

---

## 🏗️ Componentes Clave a Implementar

### 🔹 Configuración Base
- Crear el proyecto con Spring Initializr y añadir dependencias.
- Configurar `pom.xml`.

### 🔹 Modelado y Persistencia (Usuarios)
- Entidad `User` (record sugerido) con `name`, `email`, `password`.
- Repositorio `UserRepository` usando `JdbcClient`.
- Hasheo de contraseñas con `BCryptPasswordEncoder`.

### 🔹 APIs de Autenticación (Auth Controller)
- DTO `SignupRequest` con validaciones.
- Endpoint `/api/auth/signup` (POST): registrar usuario.
- DTOs `LoginRequest` y `LoginResponse`.
- Endpoint `/api/auth/login` (POST): autenticar y generar JWT.

### 🔹 Lógica de Seguridad
- **JwtHelper**:
  - `generateToken(email)`: generar JWT.
  - `extractUsername(token)`: extraer email.
  - `validateToken(token, userDetails)`: validar token.
- **UserDetailsServiceImpl**:
  - Implementar `UserDetailsService` para cargar usuarios.
- **SecurityConfig**:
  - Anotar con `@EnableWebSecurity` y `@Configuration`.
  - Desactivar CORS y CSRF.
  - Configurar autorización: públicos (`/api/auth/signup/**`, `/api/auth/login/**`) y protegidos (resto).
  - Definir `PasswordEncoder` y `AuthenticationManager`.
- **JwtAuthFilter**:
  - Extender `OncePerRequestFilter`.
  - Leer token del encabezado `Authorization`.
  - Validar token, establecer autenticación en `SecurityContextHolder`.
  - Integrar el filtro antes de `UsernamePasswordAuthenticationFilter`.

### 🔹 Configuración de Perfiles
- Archivos en `src/main/resources`:
  - `application.properties`: común.
  - `application-dev.properties`: usar H2 y logging detallado.
  - `application-prod.properties`: usar PostgreSQL

### Pasos para la Realización y Pruebas

Configurar el proyecto con Spring Initializr.

Crear User y UserRepository.

Implementar UserService para registro.

Desarrollar JwtHelper.

Implementar UserDetailsServiceImpl.

Crear AuthController con /signup y /login.

Implementar JwtAuthFilter.

Configurar SecurityConfig integrando JwtAuthFilter.

Crear archivos application.properties, application-dev.properties, application-prod.properties.

### 🔎 Pruebas (Postman/cURL)
Ejecutar en perfil dev y verificar uso de H2.

Ejecutar en perfil prod y verificar uso de PostgreSQL.

Registrar usuario vía POST /api/auth/signup.

Login vía POST /api/auth/login, obtener JWT.

Acceso no autorizado: intentar acceder a recurso protegido sin JWT (esperado 403).

Acceso autorizado: acceder con JWT en Authorization (esperado 200).