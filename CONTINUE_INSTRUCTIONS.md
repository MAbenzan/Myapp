# Continuar el desarrollo en otro PC

## Resumen rápido del estado actual
- **Repositorio**: https://github.com/MAbenzan/Myapp (ya está creado y contiene el commit inicial).
- **Modelos**:
  - `UserModel` ahora incluye `enum UserType { client, business }` y campo `businessId`.
  - `BusinessModel` tiene nuevos campos `isPublished`, `phoneNumber`, `schedule` y métodos `isProfileComplete()` / `profileCompleteness`.
- **Datos dummy**: Actualizados con los nuevos campos.
- **Pantalla de detalle** (`BusinessDetailScreen`) funciona con `NestedScrollView` + `TabBar` (tabs: Menú, Reseñas, Info).
- **Plan de implementación** (`implementation_plan.md`) contiene los pasos aprobados y decisiones.

## Qué falta por hacer (próximos pasos)
1. **Registro**
   - UI para elegir tipo de cuenta (Cliente / Negocio).
   - Si se elige *Negocio*, solicitar datos mínimos (nombre, dirección, foto, horarios) y crear `BusinessModel` con `isPublished = false`.
2. **Banner "Completa tu perfil"**
   - Mostrar porcentaje de completitud y botón que lleva al formulario de edición.
3. **Pantalla "Mi Negocio"**
   - Gestión de menú, horarios, fotos y publicación (`isPublished = true`).
4. **Integrar Google Maps** en la pestaña **Info**.
5. **Verificaciones**
   - Negocios recién creados NO aparecen en el feed hasta completar el perfil.
   - Navegación condicional según `UserType`.
   - Tests unitarios y de widget.

## Instrucciones para continuar en el nuevo PC
1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/MAbenzan/Myapp.git
   cd Myapp
   ```
2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```
3. **Abrir el proyecto** en tu IDE (VS Code, Android Studio, etc.).
4. **Revisar los artefactos**
   - `C:/Users/mbenzan/.gemini/antigravity/brain/05ef8ce5-d586-4631-af2d-300a4baab862/task.md`
   - `C:/Users/mbenzan/.gemini/antigravity/brain/05ef8ce5-d586-4631-af2d-300a4baab862/implementation_plan.md`
5. **Continuar con el siguiente paso** del plan (registro con selector de tipo). Puedes usar los archivos de UI existentes como referencia (`register_screen.dart`).

---
*Este documento está pensado para que lo copies y lo tengas a mano en el nuevo equipo.*
