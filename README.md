# Expense Management - Gestor de Gastos

Una aplicación móvil multiplataforma desarrollada con Flutter que permite a los usuarios registrar, visualizar y analizar sus gastos. La aplicación proporciona una interfaz intuitiva para la gestión de transacciones, gráfico visuale de resumen de gastos y almacenamiento local de datos mediante base de datos SQLite.

## Requisitos

- **Flutter**: 3.10.8 o superior
- **Dart**: 3.10.8 o superior
- **Android**: SDK 21+ (Android 5.0+)
- **iOS**: 12.0 o superior
- **macOS**: 10.13 o superior
- **Windows**: Windows 10 o superior
- **Linux**: Distribuciones modernas (Ubuntu 20.04+)
- **Git**: Para clonar el repositorio

## Tecnología

| Tecnología | Versión |
|-----------|---------|
| Flutter | 3.10.8+ |
| Dart | 3.10.8+ |
| Provider | 6.1.5+1 |
| SQLite | 2.4.2 |
| fl_chart | 1.1.1 |
| path_provider | 2.1.5 |

## Estructura del Proyecto

```
lib/
├── main.dart                      # Punto de entrada de la aplicación
├── models/
│   ├── expense_data.dart          # Modelo de datos de gastos
│   └── transaction.dart           # Modelo de transacciones
├── providers/
│   └── transaction_provider.dart  # Proveedor de estado (Provider)
├── screens/
│   ├── summary_screen.dart        # Pantalla de resumen con gráficos
│   ├── transaction_form_screen.dart # Formulario para agregar transacciones
│   └── transaction_history.dart   # Historial de transacciones
├── services/
│   └── database_helper.dart       # Servicio de base de datos SQLite
├── theme/
│   └── app_theme.dart             # Configuración de temas y estilos
└── widgets/
    └── expense_chart.dart         # Widget de gráfico de gastos
```

## Cómo Ejecutar

### 1. Requisitos previos
Asegúrate de tener Flutter instalado. Verifica la instalación:
```bash
flutter --version
```

### 2. Clonar el repositorio
```bash
git clone <URL_DEL_REPOSITORIO>
cd expense_managment
```

### 3. Obtener dependencias
```bash
flutter pub get
```

### 4. Ejecutar la aplicación

**En dispositivo o emulador Android/iOS:**
```bash
flutter run
```

**En web:**
```bash
flutter run -d web-server
```

**En Windows:**
```bash
flutter run -d windows
```

**En macOS:**
```bash
flutter run -d macos
```

**En Linux:**
```bash
flutter run -d linux
```

### 5. Build para producción
```bash
# Android
flutter build apk

# iOS
flutter build ios

# Web
flutter build web

# Windows
flutter build windows

# macOS
flutter build macos

# Linux
flutter build linux
```

## Autor

Edson Espinoza