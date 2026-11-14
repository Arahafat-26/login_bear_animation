import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart'; 

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos al usuario actual
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // --- INTEGRACIÓN: CIERRE DE SESIÓN ---
              await FirebaseAuth.instance.signOut();
              
              if (context.mounted) {
                // Limpiamos el historial de pantallas y volvemos al Login
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          )
        ],
      ),
      body: Center(
        child: Text(
          '¡Bienvenido, ${user?.email ?? 'Usuario'}!',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}