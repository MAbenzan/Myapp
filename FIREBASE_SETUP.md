# Guía de Configuración de Firebase

## Pasos a seguir:

### 1. Crear Proyecto Firebase (Manual - En tu navegador)
Ve a [Firebase Console](https://console.firebase.google.com) y:
1. Haz clic en "Agregar proyecto" (Add project)
2. Dale un nombre (ejemplo: `myapp-local-business`)
3. Deshabilita Google Analytics (opcional para MVP)
4. Espera a que se cree el proyecto

### 2. Autenticarse con Firebase CLI (Yo lo haré)
```bash
firebase login
```
Esto abrirá tu navegador para que inicies sesión con tu cuenta de Google.

### 3. Configurar FlutterFire (Yo lo haré)
```bash
flutterfire configure
```
Este comando:
- Te pedirá seleccionar el proyecto de Firebase que creaste
- Generará automáticamente los archivos de configuración para Android e iOS
- Creará `lib/firebase_options.dart`

### 4. Agregar dependencias de Firebase (Yo lo haré)
Modificaré `pubspec.yaml` para agregar:
- `firebase_core`
- `firebase_auth`
- `cloud_firestore`
- `firebase_storage`

---

## ¿Qué necesito de ti ahora?

**Por favor, crea el proyecto de Firebase en la consola** (Paso 1 arriba).

Una vez lo tengas creado, avísame y yo ejecutaré `firebase login` y `flutterfire configure` para conectar todo automáticamente.

> **Nota**: Si ya tienes un proyecto de Firebase existente que quieras usar, también funciona. Solo indícame el nombre del proyecto.
