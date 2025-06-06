# CryptoAcademy 🚀

**Proyecto Final de Ciclo Formativo de Grado Superior en Desarrollo de Aplicaciones Multiplataforma (DAM)**

**Alumno:** Álvaro Moreno Morejón

---

## 📜 Índice

* [Introducción](#introducción)
    * [Descripción del Proyecto](#descripción-del-proyecto)
    * [Justificación](#justificación)
    * [Objetivos](#objetivos)
    * [Motivación](#motivación)
* [✨ Funcionalidades del Proyecto](#-funcionalidades-del-proyecto)
* [🛠️ Tecnologías Utilizadas](#️-tecnologías-utilizadas)
* [⚙️ Guía de Instalación](#️-guía-de-instalación)
    * [Prerrequisitos](#prerrequisitos)
    * [Configuración del Backend (Spring Boot)](#configuración-del-backend-spring-boot)
    * [Configuración del Frontend (Flutter)](#configuración-del-frontend-flutter)
* [📖 Guía de Uso](#-guía-de-uso)
* [🔗 Enlace a la Documentación Detallada](#-enlace-a-la-documentación-detallada)
* [🎨 Enlace a Figma de la Interfaz](#-enlace-a-figma-de-la-interfaz)
* [🏁 Conclusión](#-conclusión)
* [🤝 Contribuciones, Agradecimientos y Referencias](#-contribuciones-agradecimientos-y-referencias)
* [📝 Licencia](#-licencia)
* [📧 Contacto](#-contacto)

---

## Introducción

### Descripción del Proyecto
**CryptoAcademy** es una aplicación móvil diseñada para que los usuarios puedan simular operaciones de compra y venta de criptomonedas. Utilizando datos de precios obtenidos en tiempo real, la plataforma ofrece un entorno seguro y educativo donde los usuarios pueden aprender y experimentar con el mercado de criptomonedas sin arriesgar capital real.

### Justificación
El creciente interés en el mundo de las criptomonedas ha generado una demanda de herramientas que permitan a los recién llegados familiarizarse con la dinámica del trading. CryptoAcademy busca cubrir esta necesidad, ofreciendo una plataforma que reduce la barrera de entrada y el riesgo asociado al aprendizaje práctico en este mercado.

### Objetivos
* Desarrollar una aplicación móvil multiplataforma (Flutter) intuitiva y fácil de usar.
* Implementar un backend robusto y seguro (Spring Boot) para gestionar la lógica de negocio.
* Integrar datos de mercado en tiempo real de criptomonedas a través de la API de CoinGecko.
* Permitir la simulación de operaciones de compra/venta con fondos virtuales.
* Proporcionar herramientas para el seguimiento del portafolio, historial de transacciones y visualización de tendencias.
* Fomentar un ambiente de aprendizaje competitivo y gamificado a través de un ranking de usuarios.
* Ofrecer una experiencia de usuario fluida y educativa.

### Motivación
La motivación de este proyecto nace de la curiosidad por las tecnologías como blockchain y el deseo de crear una herramienta práctica que desmitifique el trading de criptomonedas, haciéndolo accesible para cualquier persona interesada en aprender sobre inversión en un entorno controlado y sin riesgos.

---

## ✨ Funcionalidades del Proyecto

La plataforma CryptoAcademy cuenta con las siguientes funcionalidades principales:

* **Gestión de Usuarios:**
    * Registro de nuevos usuarios con validación de datos.
    * Inicio de sesión seguro con autenticación basada en JWT.
    * Gestión de perfil de usuario, incluyendo la visualización de detalles (fecha de registro, rol) y la posibilidad de actualizar el nombre.
* **Gestión de Carteras Virtuales:**
    * Creación de una cartera virtual inicial por defecto al registrarse con 100.000 EUR virtuales.
    * Creación y gestión de múltiples carteras adicionales por usuario.
    * Posibilidad de editar el nombre de las carteras.
* **Trading Simulado:**
    * Visualización de un listado de criptomonedas con datos de mercado (precio, capitalización, cambio 24h) obtenidos de CoinGecko.
    * Búsqueda de criptomonedas por nombre o símbolo.
    * Simulación de operaciones de compra y venta de criptomonedas utilizando el saldo virtual de la cartera seleccionada, con validaciones de saldo y tenencia.
* **Seguimiento y Análisis:**
    * Visualización del portafolio detallado por cartera, mostrando el valor total, el valor de las criptos y el saldo fiat de la cartera.
    * Historial completo de todas las transacciones realizadas por el usuario, con opción de filtrar por tipo (compra/venta).
    * Visualización de gráficos de precios históricos para cada criptomoneda con diferentes rangos de tiempo (1D, 7D, 30D, etc.).
    * Consulta del saldo fiat total y del valor total en cripto del usuario (sumando todas sus carteras), implementado con **funciones de base de datos** para optimizar el cálculo.
* **Gamificación y Comunidad:**
    * Ranking de usuarios basado en el valor total de sus portafolios simulados, implementado con un **procedimiento almacenado** de base de datos para un rendimiento eficiente.
* **Integridad y Trazabilidad de Datos:**
    * Auditoría automática de todas las transacciones nuevas mediante **triggers de base de datos**, asegurando un registro histórico inmutable de las operaciones.
* **(Trabajo Futuro) Notificaciones Push:**
    * El sistema está preparado para una futura implementación de alertas de precios personalizadas.

---

## 🛠️ Tecnologías Utilizadas

* **Frontend:**
    * **Framework:** Flutter (Dart)
    * **Gestión de Estado:** Provider
    * **Llamadas API:** Paquete `http`
    * **Formateo:** `intl`
    * **Almacenamiento Seguro:** `flutter_secure_storage` (para el token JWT)
    * **Gráficos:** `fl_chart`
* **Backend:**
    * **Framework:** Spring Boot 3.2.5 (`Java 17`)
    * **Módulos:** Spring Web (API REST), Spring Data JPA (Hibernate), Spring Security (con autenticación JWT)
    * **Librerías Clave:** `jjwt` (para JWT), Lombok, OkHttp3 (cliente HTTP)
* **Base de Datos:**
    * **SGBD:** MySQL 8.0
    * **Lógica en BD:** Procedimientos Almacenados, Funciones y Triggers SQL
* **APIs Externas:**
    * CoinGecko API (para datos de mercado de criptomonedas)
* **Gestión de Proyecto y Dependencias:**
    * **Backend:** Maven
    * **Frontend:** Pub (Gestor de paquetes de Dart)
* **Control de Versiones:**
    * Git & GitHub

---

## ⚙️ Guía de Instalación

### Prerrequisitos
* Java JDK 17 o superior
* Apache Maven 3.6+
* Servidor de Base de Datos MySQL (versión 8.0 recomendada)
* Flutter SDK (última versión estable recomendada)
* Un IDE para Java/Spring Boot (ej. IntelliJ IDEA, Eclipse, VSCode)
* Un IDE para Flutter (ej. Android Studio, VSCode con extensiones de Flutter/Dart)
* Git

### Configuración del Backend (Spring Boot)
1.  **Clonar el repositorio:**
    ```bash
    git clone https://github.com/M0r3n0SVQ/CryptoAcademy-Backend.git
    cd CryptoAcademy-Backend
    ```
2.  **Configurar la Base de Datos MySQL:**
    * Crea una base de datos en MySQL con el nombre `dbtrading`.
    * Asegúrate de que el usuario de la base de datos tenga todos los permisos sobre esta BD.
    * Configura los detalles de conexión en `src/main/resources/application-local.properties`:
        ```properties
        spring.datasource.url=jdbc:mysql://localhost:3306/dbtrading
        spring.datasource.username=[TU_USUARIO_DB]
        spring.datasource.password=[TU_PASSWORD_DB]
        
        # Clave secreta para JWT (puedes generar una online)
        app.security.jwt.secret-key=[TU_JWT_SECRET_KEY]
        
        # API Key de CoinGecko (versión gratuita)
        coingecko.api.key=[TU_COINGECKO_API_KEY]
        ```
    * **Importante**: La configuración `spring.jpa.hibernate.ddl-auto` está en `validate`. Esto significa que las tablas no se crearán solas. Debes ejecutar el script SQL para crear la estructura de tablas inicial, también se crearán el procedimiento `CalcularRankingUsuarios`, las funciones `ObtenerSaldoFiatTotalUsuario` y `ObtenerValorCriptoTotalUsuario`, la tabla `audit_log_transacciones` y el trigger `TRG_Audit_Transacciones_Insert`.

3.  **Construir y Ejecutar el Backend:**
    * Desde la raíz del proyecto backend, ejecuta:
        ```bash
        mvn clean install
        mvn spring-boot:run --spring-boot.run.profiles=local
        ```
    * El backend estará corriendo en `http://localhost:8080`.

### Configuración del Frontend (Flutter)
1.  **Clonar el repositorio:**
    ```bash
    git clone https://github.com/M0r3n0SVQ/CryptoAcademy-Frontend.git
    cd CryptoAcademy-Frontend
    ```
2.  **Obtener dependencias:**
    ```bash
    flutter pub get
    ```
3.  **Configurar la URL del Backend:**
    * En el archivo `lib/core/constants/app_constants.dart`, asegúrate de que la variable `activeApiBaseUrl` apunte a tu backend:
        * **Emulador Android (backend en localhost):** `http://10.0.2.2:8080/api`
        * **Dispositivo físico (misma red WiFi):** `http://[IP_LOCAL_DE_TU_PC]:8080/api`
4.  **Ejecutar la Aplicación Flutter:**
    * Con un emulador corriendo o un dispositivo conectado, ejecuta:
        ```bash
        flutter run
        ```

---

## 📖 Guía de Uso

1.  **Registro e Inicio de Sesión:** Crea una cuenta y accede a la aplicación.
2.  **Pantalla de Portafolio:** Al iniciar sesión, verás la pantalla de portafolio. Puedes crear nuevas carteras con el botón `+` y cambiar entre ellas con el menú desplegable. Se muestra el saldo y valor de la cartera seleccionada.
3.  **Mercado y Detalle:** Navega a la pantalla de mercado para ver la lista de criptomonedas. Toca una para ver sus detalles y un gráfico de precios interactivo.
4.  **Operar (Comprar/Vender):** Desde la pantalla de detalle, puedes pulsar "Comprar" o "Vender". Se abrirá un diálogo donde seleccionarás la cartera, verás tu saldo disponible en ella y podrás introducir la cantidad a operar.
5.  **Historial de Transacciones:** Consulta un registro completo de todas tus operaciones.
6.  **Ranking de Usuarios:** Compara tu rendimiento con el de otros usuarios en la tabla de clasificación.
7.  **Perfil de Usuario:** Accede a tu perfil para ver tus datos (nombre, email, fecha de registro, rol) y resúmenes financieros globales. También puedes actualizar tu nombre desde esta pantalla.

---

## 🔗 Enlace a la Documentación Detallada

La documentación técnica completa del proyecto, incluyendo diagramas y casos de prueba, se puede encontrar en:
** **

---

## 🎨 Enlace a Figma de la Interfaz

El diseño visual y prototipado de las pantallas principales de CryptoAcademy se puede consultar en el siguiente enlace de Figma:
**https://www.figma.com/proto/TYREV6EcQ7CrvYvo0FSLhG/TFG?node-id=0-1&t=L5ziqEWgTl00N2W9-1**

---

## 🏁 Conclusión

CryptoAcademy es una plataforma integral y funcional para la simulación de trading de criptomonedas. El proyecto combina con éxito un backend robusto y escalable desarrollado con Spring Boot y un frontend moderno y reactivo construido con Flutter. La implementación de lógica avanzada en la base de datos (procedimientos, funciones, triggers) optimiza el rendimiento y asegura la integridad de los datos. El resultado es una herramienta educativa valiosa y una base sólida para futuras expansiones.

**Posibles Mejoras Futuras:**
* Implementación de notificaciones push para alertas de precios personalizadas.
* Más opciones de análisis técnico en los gráficos (medias móviles, RSI).
* Funcionalidades sociales como seguir a otros traders o compartir operaciones.
* Ampliación de la gamificación con logros y niveles de usuario.

---

## 🤝 Contribuciones, Agradecimientos y Referencias

* **Agradecimientos:**
    * A mis profesores por su guía, paciencia y por compartir sus conocimientos, que han sido fundamentales durante los dos años.
    * De manera muy especial, a mis padres, por su apoyo incondicional, ánimo y confianza en mí durante todo este camino.
* **Referencias:**
    * Documentación oficial de Flutter, Dart, Spring Boot, Java y MySQL.
    * CoinGecko API: https://www.coingecko.com/es/api/documentation
    * Librería `fl_chart` para los gráficos en Flutter.

---

## 📝 Licencia

Este proyecto se distribuye bajo la Licencia MIT. Ver el archivo `LICENSE.md` para más detalles.

---

## 📧 Contacto

* **Nombre:** Álvaro Moreno Morejón
* **Email:** alvaromorenofp@gmail.com
* **Perfil de GitHub:** https://github.com/M0r3n0SVQ
* **Perfil de LinkedIn:** https://www.linkedin.com/in/%C3%A1lvaro-moreno-morej%C3%B3n-ba348828a/

---
