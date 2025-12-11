# CRUD Productos - Flutter con API + SQLite

## 📱 Descripción
Aplicación móvil desarrollada en Flutter que implementa un **CRUD completo** (Create, Read, Update, Delete) de productos. Los datos se obtienen de la API REST pública FakeStoreAPI y se almacenan localmente en SQLite para persistencia.

## 🎯 Funcionalidades
- ✅ **Listar Productos** - Carga productos desde la API y los muestra en Cards
- ✅ **Crear Producto** - Agrega nuevos productos mediante formulario
- ✅ **Editar Producto** - Modifica productos existentes
- ✅ **Eliminar Producto** - Elimina productos con confirmación
- ✅ **Persistencia Local** - Los datos se guardan en SQLite

## 🔄 Flujo de la Aplicación

```
1. Abre la app
      ↓
2. Carga productos de API (FakeStoreAPI)
      ↓
3. Guarda productos en SQLite
      ↓
4. Muestra lista en pantalla
      ↓
5. Usuario puede:
   • VER productos (READ)
   • CREAR nuevo producto (CREATE) → SQLite
   • EDITAR producto (UPDATE) → SQLite
   • ELIMINAR producto (DELETE) → SQLite
```

## 📁 RESUMEN DE ARCHIVOS

| Archivo | Descripción |
|---------|-------------|
| **lib/main.dart** | Punto de entrada de la aplicación. Configura el tema visual (color morado), desactiva el banner de debug y establece `PostsPage` como pantalla inicial. |
| **lib/models/product.dart** | Clase `Product` que representa un producto con: id, title, description, price, image, category. Contiene métodos `fromJson()` para convertir datos de API, `fromJsonDB()` para datos de SQLite, `toJson()` y `toJsonForDB()` para enviar datos. |
| **lib/screens/posts_page.dart** | Pantalla principal del CRUD. Muestra lista de productos en Cards, permite crear nuevos productos con el botón flotante (+), editar y eliminar con menú contextual. Usa `ListView.builder` para mostrar la lista y `AlertDialog` para formularios. |
| **lib/services/api_service_product.dart** | Servicio para llamadas HTTP a la API FakeStoreAPI (https://fakestoreapi.com). Contiene métodos: `getProducts()` para obtener lista, `createProduct()`, `updateProduct()`, `deleteProduct()` para las operaciones CRUD. |
| **lib/services/database_helper.dart** | Servicio SQLite que maneja la base de datos local `products.db`. Crea la tabla `products`, e implementa métodos CRUD: `insertProduct()`, `getProducts()`, `updateProduct()`, `deleteProduct()`. Usa patrón Singleton para una única instancia. |

## 📦 Dependencias (pubspec.yaml)

| Dependencia | Versión | ¿Para qué sirve? |
|-------------|---------|------------------|
| **flutter** | SDK | Framework principal para desarrollo móvil multiplataforma. |
| **cupertino_icons** | ^1.0.8 | Paquete de íconos estilo iOS. |
| **http** | ^1.2.0 | Permite realizar peticiones HTTP (GET, POST, PUT, DELETE) a APIs REST. |
| **sqflite** | ^2.4.2 | Plugin de SQLite para Flutter. Permite crear y gestionar bases de datos locales. |
| **path** | ^1.9.1 | Utilidad para manejar rutas de archivos. Se usa junto con sqflite. |

## 🚀 Instalación y Ejecución

### Prerrequisitos
- Flutter SDK instalado (versión 3.0+)
- Android Studio o VS Code con extensiones de Flutter
- Emulador Android/iOS o dispositivo físico

### Pasos
1. Clonar el repositorio:
```bash
git clone https://github.com/Vania-0731/CRUD_api.git
```

2. Navegar al directorio:
```bash
cd crud_api_s16
```

3. Instalar dependencias:
```bash
flutter pub get
```

4. Ejecutar la aplicación:
```bash
flutter run
```

## 📡 API Utilizada

**FakeStoreAPI:** `https://fakestoreapi.com/products`

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/products` | Obtener todos los productos |
| GET | `/products/{id}` | Obtener un producto por ID |
| POST | `/products` | Crear un nuevo producto |
| PUT | `/products/{id}` | Actualizar un producto |
| DELETE | `/products/{id}` | Eliminar un producto |
