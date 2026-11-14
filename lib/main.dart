import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Paquete principal de Firebase
import 'firebase_options.dart'; // El archivo que se acaba de autogenerar
import 'screens/login_screen.dart';

void main() async {
  // 1. Asegura que Flutter esté listo para ejecutar código nativo asíncrono
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Inicializa Firebase con las opciones de tu proyecto
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Arranca la aplicación
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rive Firebase Auth',
      home: LoginScreen(), // Aquí llamas a la clase de tu pantalla de login
    );
  }
}