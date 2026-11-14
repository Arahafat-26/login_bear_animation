import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _obscure = true;
  String? emailError;
  String? passError;
  String? confirmError;
  bool _isLoading = false;

  // Validadores Regex (Las mismas reglas de tu examen)
  bool isValidEmail(String email) {
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(email);
  }

  bool isValidPassword(String pass) {
    final re = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$');
    return re.hasMatch(pass);
  }

  Future<void> _onSignUp() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final confirm = _confirmPassCtrl.text;

    // Evaluar errores
    final eError = isValidEmail(email) ? null : "Email inválido";
    final pError = isValidPassword(pass) ? null : "Mínimo 8 caracteres, 1 mayúscula, 1 número y 1 especial";
    final cError = (pass == confirm) ? null : "Las contraseñas no coinciden";

    setState(() {
      emailError = eError;
      passError = pError;
      confirmError = cError;
    });

    FocusScope.of(context).unfocus();

    if (eError != null || pError != null || cError != null) return;

    setState(() => _isLoading = true);

    // --- INTEGRACIÓN CON FIREBASE: CREAR USUARIO ---
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Cuenta creada exitosamente!'), backgroundColor: Colors.green),
        );
        // Regresamos a la pantalla del osito
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String errorMsg = 'Error al registrar usuario';
      if (e.code == 'email-already-in-use') {
        errorMsg = 'Este correo ya está registrado.';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    errorText: emailError,
                    hintText: 'Email',
                    helperText: 'Ejemplo: usuario@dominio.com',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    errorText: passError,
                    hintText: 'Contraseña',
                    helperText: 'Mínimo 8 caracteres, 1 mayúscula, 1 número y 1 especial (@\$!%*?&)',
                    helperMaxLines: 2,
                    prefixIcon: const Icon(Icons.lock),
                    errorMaxLines: 2,
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _confirmPassCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    errorText: confirmError,
                    hintText: 'Confirmar Contraseña',
                    prefixIcon: const Icon(Icons.lock_clock),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 30),
                MaterialButton(
                  minWidth: size.width,
                  height: 50,
                  color: Colors.pinkAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onPressed: _isLoading ? null : _onSignUp,
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text('Registrarse', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }
}