import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //Control para mostrar/ocultar contraseña
  bool _obscure = true;

  //1.1 crear el cerebro de la animacion
  StateMachineController? _controller;
  //SMI: State MAchine Input/ enrrada de maquina de estado
  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFail;

  @override
  Widget build(BuildContext context) {
    //para obtener el tamaño de la pantalla
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(
                width: size.width,
                height: 200,
                child: RiveAnimation.asset(
                  'assets/login-bear.riv',
                  stateMachines: ['Login Machine'],
                  //1.2 vincular animacion
                  onInit: (artboard){
                    _controller = StateMachineController.fromArtboard(
                      artboard,
                      'Login Machine',
                      );

                      //1.3 verificar que inicio bien
                      if (_controller == null) return;
                      artboard.addController(_controller!);
                      //agrega el controlador al escenario/tablero
                      artboard.addController(_controller!);
                      //vinvulamos variables
                      _isChecking = _controller!.findSMI('isChecking');
                      _isHandsUp = _controller!.findSMI('isHandsUp');
                      _trigSuccess = _controller!.findSMI('trigSuccess');
                      _trigFail = _controller!.findSMI('trigFail');
                  },
                ),
              ),
              //para separar espacios
              SizedBox(height:10),
              //Campo de texto para email
              TextField(
                onChanged: (value) {
                  if (_isHandsUp != null){
                    //no tapes los ojos al ver email
                    _isHandsUp!.change(false);
                  }
                  //si isChecking es nulo
                  if(_isChecking == null) return;
                  //activar el modo chismoso
                  _isChecking!.change(true);
                },
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    //para redondear los bordes
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 10),
              //Campo de texto para contraseña
                TextField(
                  onChanged: (value) {
                    if(_isChecking != null){
                      //no tapes los ojos al ver el email
                      _isChecking!.change(false);
                    }
                    //si ischecking es nulo
                    if (_isHandsUp == null) return;
                    //Activar el modo chismoso
                    _isHandsUp!.change(true);
                  },
                  obscureText: _obscure,
                  //para mostrar el tipo de teclado
                decoration: InputDecoration(
                  hintText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    //if operador ternario
                    icon: Icon(
                      _obscure ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: (){
                      //Refrescar el icono
                      setState(() {
                        _obscure = !_obscure;
                      });
                    }, 
                    ),
                  border: OutlineInputBorder(
                    //para redondear los bordes
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          ),
          ),
    );
  }
}