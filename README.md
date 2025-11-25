# 🔥 Flutter Expense Tracker OCR 🔥

Aplicación modular y escalable desarrollada en **Flutter 3**, diseñada para gestionar ingresos y gastos con precisión y eficiencia.  
La app ofrece una interfaz intuitiva, ofreciendo una experiencia fluida para usuarios que desean controlar sus finanzas personales.  
Incluye integración con **Firebase** y reconocimiento de texto (**OCR con Google ML Kit**) para extraer automáticamente el monto de tickets fotografiados.

---

## 🧰 Requisitos del Sistema

### 💻 Hardware:

- Procesador: Intel Core i3 / AMD Ryzen 3 o superior
- Memoria RAM: 4 GB mínimo
- Almacenamiento: 1 GB libre para proyecto y dependencias
- Conectividad: Acceso a internet para sincronización con Firebase
- Resolución de pantalla: 1280x720 o superior

### 🧪 Software

- Flutter 3.x
- Dart 3.x
- Android Studio / VS Code con extensiones Flutter
- Node.js 18.x (para dependencias Firebase CLI)
- Firebase CLI instalado
- Navegador moderno (Chrome, Firefox, Edge)

---

## 🛠 Instalación

### Clona el repositorio:

```bash
  git clone https://github.com/xEdwardP/flutter_expense_tracker_ocr.git
  cd flutter_expense_tracker_ocr
```

### Instala dependencias:

```bash
  flutter pub get
```

### Configura tu archivo firebase_config.dart:

```bash
  cp lib/data/firebase_config_example.dart lib/data/firebase_config.dart
```

---

## ⚙ Variables de Entorno

Para ejecutar correctamente este proyecto, asegúrate de definir las siguientes variables en tu archivo firebase_config.dart:

- `apiKey`
- `authDomain`
- `projectId`
- `storageBucket`
- `messagingSenderId`
- `appId`

---

## 🧠 Autores

- [@Edward Pineda](https://github.com/xEdwardP)
- [@Jose Boanerges](https://github.com/joseAO-cmd)
- [@Omar Pinto](https://github.com/Omar03PP)
- [@Stefano Ponce](https://github.com/StefanoPonce)
- [@Hector Villeda](https://github.com/HectorVilleda-glich)

---
