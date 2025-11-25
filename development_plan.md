# Plan de Desarrollo: App Móvil de Negocios Locales

## Resumen Ejecutivo
Este documento detalla la estrategia técnica y de producto para desarrollar una plataforma móvil multiplataforma que conecte usuarios con negocios locales. La solución se construirá sobre **Flutter** para garantizar una experiencia nativa en iOS y Android con una única base de código, respaldada por **Firebase** para un desarrollo rápido del MVP. El plan prioriza la velocidad de entrega y la validación de mercado, proponiendo una arquitectura modular que permite escalar y migrar componentes críticos a medida que la plataforma crece. Se define un roadmap de 4 fases, desde un prototipo funcional hasta una plataforma escalable, con un enfoque fuerte en UX premium y herramientas gratuitas para minimizar la inversión inicial.

---

## A) Stack Propuesto

Para un equipo de 1-3 desarrolladores buscando velocidad y calidad:

| Componente | Tecnología Recomendada | Justificación | Pros | Contras |
| :--- | :--- | :--- | :--- | :--- |
| **Mobile App** | **Flutter** (Dart) | UI consistente, rendimiento nativo, excelente DX. | Single codebase, Hot Reload, UI rica. | Tamaño de app algo mayor. |
| **Web Admin** | **React** (Vite) + Tailwind | Estándar de industria, ecosistema rico para dashboards. | Rápido desarrollo, componentes listos (Shadcn/MUI). | Separado de codebase móvil (aunque Dart puede usarse en web, React es superior para admin). |
| **Backend** | **Firebase** (BaaS) | Velocidad imbatible para MVP. Auth, DB y Storage integrados. | Setup cero, tiempo real, capa gratuita generosa. | Vendor lock-in, costes escalan con uso alto, queries limitadas. |
| **Base de Datos** | **Firestore** (NoSQL) | Flexible para esquemas cambiantes de MVP. | Escalado automático, offline mode nativo. | Queries complejas difíciles, coste por lectura. |
| **Mapas** | **Google Maps SDK** | Estándar de oro, mejor data de POIs. | Fiabilidad, UX familiar. | Costoso si escala mucho (alternativa: Mapbox). |
| **Analytics** | **Google Analytics** | Integración nativa con Firebase. | Gratis, eventos automáticos. | Privacidad (cookies/consent). |
| **CI/CD** | **Codemagic** o **GitHub Actions** | Especializados en Flutter (Codemagic). | Builds fáciles para iOS/Android. | Minutos gratis limitados. |

**Estrategia de Migración de Backend:**
Firebase es ideal para el MVP (0-10k usuarios).
*   **Cuándo migrar:** Cuando los costos de lectura de Firestore superen $100-200/mes, o se requieran consultas relacionales complejas (ej. reportes avanzados de SQL).
*   **A dónde:** **Supabase** (PostgreSQL) o backend propio en **Go/Node.js** + PostgreSQL.
*   **Por qué:** Supabase ofrece SQL real, es open source y más barato a escala. Appwrite es otra opción válida, pero Supabase tiene mejor DX relacional.

---

## B) Arquitectura de Alto Nivel

### Diagrama de Componentes
```ascii
+----------------+      +----------------+
|  App Android   |      |    App iOS     |
|   (Flutter)    |      |   (Flutter)    |
+-------+--------+      +--------+-------+
        |                        |
        v                        v
+----------------------------------------+
|           API Gateway / SDK            |
|       (Firebase Auth & SDKs)           |
+-------------------+--------------------+
                    |
      +-------------+-------------+
      |                           |
+-----v------+             +------v-------+      +-------------+
| Firestore  |             | Cloud Funcs  | <--> | Google Maps |
| (Data/DB)  |             | (Logic/Jobs) |      |     API     |
+------------+             +--------------+      +-------------+
      ^                           ^
      |                           |
+-----+------+                    |
| Web Admin  | -------------------+
| (React/TS) |
+------------+
```

### Modelo de Datos Inicial (Entidades Clave)

*   **User**: `uid`, `email`, `displayName`, `photoURL`, `favorites` (array IDs), `role` (user/admin).
*   **Business**: `id`, `ownerId`, `name`, `category`, `location` (GeoPoint), `address`, `description`, `ratingAvg`, `reviewCount`, `photos` (array URLs), `hours` (map), `isPromoted` (bool).
*   **Post** (Ofertas/Novedades): `id`, `businessId`, `content`, `imageUrl`, `createdAt`, `expiresAt`, `isPinned`.
*   **MenuSection**: `id`, `businessId`, `title`, `order`.
*   **MenuItem**: `id`, `sectionId`, `name`, `price`, `description`, `photoUrl`.
*   **Review**: `id`, `businessId`, `userId`, `rating`, `comment`, `reply` (obj: {text, date}), `createdAt`.
*   **Notification**: `id`, `userId`, `type`, `title`, `body`, `read` (bool), `data` (json).

### Reglas de Seguridad Clave
1.  **Auth**: Solo usuarios autenticados pueden escribir reseñas o crear negocios.
2.  **Business Owner**: Solo el `ownerId` del negocio puede editar su perfil, menú y posts.
3.  **Public Read**: Cualquiera puede leer negocios, menús y reseñas públicas.
4.  **Admin**: Custom Claims en token (`admin: true`) para acceso total desde panel web.

---

## C) MVP — Entregables Concretos

**Objetivo:** Validar que los usuarios encuentran valor en descubrir negocios y que los negocios quieren gestionar su perfil.

**Features Prioritarias:**
1.  **Auth**: Login Social (Google) + Email.
2.  **Feed**: Lista de negocios ordenados por distancia (geoquery simple).
3.  **Detalle Negocio**: Info básica, mapa, galería, botón "Llamar/Ir".
4.  **Búsqueda**: Por nombre texto simple.
5.  **Perfil Negocio (Dueño)**: Editar info básica y subir 1 foto.
6.  **Reseñas**: Crear reseña texto + estrellas.

**Criterios de Aceptación Mínimos:**
*   Usuario puede ver lista de negocios a < 5km.
*   Usuario puede registrarse y dejar una reseña.
*   Dueño puede reclamar/crear negocio y editar horario.
*   App no crashea en flujo principal.
*   Carga de imágenes optimizada (resize básico).

---

## D) Fases / Roadmap

### Fase 0: Prototipo (Semanas 1-2)
*   **Objetivo**: "Walking skeleton". Navegación y conexión a DB.
*   **Tareas**: Setup Flutter, Config Firebase, Auth flow, Pantalla lista (dummy data), Pantalla detalle.
*   **Entregable**: APK instalable donde se ve un mapa y lista estática.

### Fase 1: MVP Público (Semanas 3-6)
*   **Objetivo**: Lanzamiento a friends & family / beta testers.
*   **Historias**:
    *   Como usuario, quiero ver negocios cerca de mí.
    *   Como usuario, quiero buscar "Pizza".
    *   Como negocio, quiero subir la foto de mi fachada.
*   **Técnico**: GeoQueries (Geoflutterfire o nativo), Cloudinary/Firebase Storage para imágenes, Formulario de alta negocio.
*   **Tests**: Unit tests de modelos, Widget test de tarjeta de negocio.
*   **Esfuerzo**: XL (Base sólida).

### Fase 2: Funciones de Negocio (Semanas 7-10)
*   **Objetivo**: Retención de negocios y usuarios.
*   **Historias**:
    *   Como negocio, quiero publicar mi menú.
    *   Como negocio, quiero publicar una oferta del día.
    *   Como usuario, quiero guardar favoritos.
*   **Técnico**: Subcolecciones para Menú, Lógica de "Pinned Posts", Notificaciones Push (FCM).
*   **Entregable**: App completa funcional para mercado.

### Fase 3: Escalado y Monetización (Mes 3+)
*   **Objetivo**: Rentabilidad.
*   **Historias**:
    *   Como negocio, quiero pagar para salir primero (Promoted).
    *   Como admin, quiero ver métricas de uso.
*   **Técnico**: Integración Stripe/RevenueCat, Panel Admin React avanzado, Cache agresivo, Optimización de lecturas.

---

## E) Diseño y UX

**Guía de Estilo:**
*   **Filosofía**: "Clean & Vibrant". Espacios blancos generosos para legibilidad, con acentos de color fuertes para llamadas a la acción.
*   **Tipografía**: Sans-serif moderna (ej. *Inter* o *Poppins*) para títulos, *Roboto* para cuerpo.
*   **Paleta**:
    *   Primario: Azul eléctrico o Verde menta (según branding).
    *   Fondo: Blanco (#FFFFFF) / Gris muy claro (#F8F9FA).
    *   Dark Mode: Gris oscuro (#121212) con superficies elevadas (#1E1E1E).
*   **Accesibilidad**: Contraste AA mínimo. Soporte para escalado de texto dinámico.

**Wireframes (Pantallas Clave):**
1.  **Home/Feed**: Barra búsqueda superior, filtros horizontales (chips), lista vertical de tarjetas de negocio (foto grande, nombre, rating, distancia).
2.  **Mapa**: Vista pantalla completa con pines. Bottom sheet deslizable con resumen del negocio seleccionado.
3.  **Detalle Negocio**: Header con foto paralla, info clave, pestañas (Info, Menú, Reseñas). FAB para "Llamar" o "Cómo llegar".
4.  **Perfil Usuario**: Avatar, lista de favoritos, lista de mis reseñas, ajustes.

---

## F) DevOps & QA

**CI/CD (Codemagic/GitHub Actions):**
1.  **Trigger**: Push a `main` o `develop`.
2.  **Build**: `flutter build apk --release` / `flutter build ios`.
3.  **Test**: Ejecutar `flutter test`.
4.  **Deploy**:
    *   `develop` -> Firebase App Distribution (Testers internos).
    *   `main` (tag) -> Google Play Console (Internal Track) / TestFlight.

**Estrategia de QA:**
*   **Unit Tests**: Lógica de negocio pura (modelos, parsers).
*   **Widget Tests**: Componentes UI aislados (ej. tarjeta de negocio renderiza bien).
*   **Manual**: "Bug bash" semanal con el equipo antes de release.
*   **Monitorización**: Sentry o Crashlytics para reportes de crash en tiempo real.

---

## G) Escalabilidad y Costos

**Puntos de Dolor (Cost Drivers):**
*   **Lecturas Firestore**: Cada vez que un usuario hace scroll en el feed, son N lecturas.
    *   *Mitigación*: Paginación estricta (limit 20), cache local de Flutter.
*   **Google Maps**: Costo por carga de mapa.
    *   *Mitigación*: Usar "Lite Mode" en listas, cargar mapa interactivo solo a demanda.
*   **Storage**: Imágenes de alta resolución.
    *   *Mitigación*: Redimensionar en cliente o Cloud Function antes de guardar.

**Optimización Fase Inicial:**
*   Usar capa gratuita de Firebase (Spark Plan) hasta el límite.
*   Limpiar datos de prueba regularmente.
*   Configurar alertas de presupuesto en Google Cloud Console.

---

## H) Seguridad y Cumplimiento

**Autenticación:**
*   Firebase Auth. Proveedores: Email/Password y Google.
*   Deshabilitar registro anónimo para evitar spam inicial.

**Reglas Firestore (Security Rules):**
```javascript
match /businesses/{businessId} {
  allow read: if true;
  allow create: if request.auth != null;
  allow update: if request.auth.uid == resource.data.ownerId;
}
```

**Privacidad:**
*   **Eliminación de cuenta**: Requisito obligatorio para Apple Store. Implementar Cloud Function que borre datos de Auth y Firestore recursivamente.
*   **Términos**: Texto simple indicando que se usa ubicación para mostrar resultados cercanos y no se comparte con terceros.

---

## I) Plan de Pruebas y Métricas

**KPIs Iniciales:**
1.  **Retención D1**: % usuarios que vuelven al día siguiente.
2.  **Conversión a Detalle**: % de clics en tarjetas del feed.
3.  **Negocios Activos**: # negocios que editaron su perfil en la última semana.

**A/B Test Propuesto (Feed):**
*   **Variante A**: Ordenar puramente por distancia.
*   **Variante B**: Ordenar por "Recomendados" (mix de distancia + rating).
*   **Medición**: Cuál genera más clics en "Llamar" o "Ver Menú".

---

## J) Backlog Inicial (Primeras 6 Semanas)

**Prioridad Alta (Must Have):**
1.  [Setup] Inicializar proyecto Flutter y repo Git. (1 pt)
2.  [Setup] Configurar Firebase (Auth, Firestore) en proyecto. (1 pt)
3.  [Frontend] Implementar Login Screen (Google + Email). (2 pts)
4.  [Backend] Definir modelos de datos en código y reglas Firestore. (2 pts)
5.  [Frontend] Crear Layout base (Bottom Navigation). (1 pt)
6.  [Frontend] Implementar Feed de Negocios (UI Mock). (3 pts)
7.  [Backend] Script para poblar DB con datos semilla (fake data). (2 pts)
8.  [Frontend] Conectar Feed con Firestore (Lectura real). (3 pts)
9.  [Frontend] Pantalla Detalle de Negocio (Header, Info). (3 pts)
10. [Frontend] Integración Google Maps en Detalle. (3 pts)

**Prioridad Media (Should Have):**
11. [Frontend] Perfil de Usuario (Ver/Editar datos). (2 pts)
12. [Frontend] Búsqueda por texto (filtro local o query simple). (3 pts)
13. [Frontend] Formulario "Crear Negocio" (Básico). (5 pts)
14. [Backend] Cloud Function para redimensionar imágenes (opcional MVP). (3 pts)
15. [Frontend] Subida de imágenes (Logo negocio). (3 pts)
16. [Frontend] Pantalla de "Mis Favoritos". (2 pts)

**Prioridad Baja (Nice to Have):**
17. [Frontend] Dark Mode toggle. (2 pts)
18. [Frontend] Animaciones de transición (Hero). (2 pts)
19. [DevOps] Setup CI/CD básico (Build check). (2 pts)
20. [Legal] Pantalla de Términos y Condiciones. (1 pt)
