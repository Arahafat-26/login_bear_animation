import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'dart:async'; //3.1 importar libreria para temporizador

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

  //3.2 variable para el temporizador de mirada
  SMINumber? _numLook;

  //3.3 timer para detener la mirada al escribir
  Timer? _typingdebounce;

  //2.1 crear las variables para FocusNode
  final _emailFocus = FocusNode(); //se llama node por un foco de cosas que puede hacer
  final _passwordFocus = FocusNode();

  //4.1 controllers que manipulan lo que el usuario escribe
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  //errores para mostrarlo en la UI
  String? emailError;
  String? passError;

  //4.3 validadores
  bool isValidEmail(String email){
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(email);
  }

  bool isValidPassword(String pass){
    final re = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',);
    return re.hasMatch(pass);
  }

  //4.4 dar accion al boton
  void _onLogin(){
    //4.5 de lo que escribio el usuario, quitar el espacios en blanco
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;

    //4.6 evaluar los errores
    final eError = isValidEmail(email) ? null : "Invalido email";
    final pError = isValidPassword(pass) ? null: "Invalid password";

    //4.7 avisar que hubo cambios
    setState(() {
     emailError = eError;
     passError = pError;
    });

    //4.8 Cerrar el teclado y bajar las manos
    FocusScope.of(context).unfocus();//quita el foco
    _typingdebounce?.cancel();
    _isChecking?.change(false);
    _isHandsUp?.change(false);
    _numLook?.value = 50.0;

    //4.9 activar triggers
    if (eError == null && pError == null){
      _trigSuccess?.fire();
    } else{
      _trigFail?.fire();
    }
  }

  //2.2 Listeners (Oyentes/Chismosos) para saber cuando el usuario esta escribiendo en el campo de texto
  @override
  void initState() {
    super.initState();
    _emailFocus.addListener((){
      if (_emailFocus.hasFocus){
      //verificar que no sea nulo
      if(_isHandsUp !=null){
        //manos abajo en el email
        _isHandsUp?.change(false);
        //3.4 mirada neutra
        _numLook?.value = 50.0;
      }
      }
    });
    _passwordFocus.addListener((){
      //manos arriba en password
      _isHandsUp?.change(_passwordFocus.hasFocus);
      //3.5 Detener la mirada al escribir
      _typingdebounce?.cancel();
      _typingdebounce = Timer(
        const Duration(milliseconds: 500),(){
          _numLook?.value = 50.0;
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    //para obtener el tamaño de la pantalla
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
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
                        //3.6 vincular la variable de mirada
                        _numLook = _controller?.findSMI('numLook');
                    },
                  ),
                ),
                //para separar espacios
                SizedBox(height:10),
                //Campo de texto para email
                TextField(
                  //4.10 enlazar controller
                  controller:_emailCtrl,
                  //2.3 asignar foco al campo de texto
                  focusNode: _emailFocus,
                  onChanged: (value) {
                    if (_isHandsUp != null){
                      //no tapes los ojos al ver email
                      //_isHandsUp!.change(false);
                    }
                    //si isChecking es nulo
                    if(_isChecking == null) return;
                    //activar el modo chismoso
                    _isChecking!.change(true);
                    //implementar el numLook
                    //80 es la medida de calibracion
                    final look = (value.length / 80 * 100).clamp(0, 100);
                    //clamp es el rango abrazadera
                    _numLook?.value = look.toDouble();
                    //3.7 detener la mirada al escribir
                    _typingdebounce?.cancel();
                    _typingdebounce = Timer(
                      const Duration(seconds: 3),
                      (){
                        //si se cierra la pantalla se cierra el contador
                        if(!mounted) return;
                        //3.8 mirada neutra y dejar de chequear
                        _numLook?.value = 50.0; //resetea la posicion horizontal de los ojos al centro
                        _isChecking?.change(false); //Detiene el modo de seguimiento
                      }
                      );
                  },
                  //para mostrar el tipo de teclado
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    //4.11 mostrat texto error
                    errorText: emailError,
                    hintText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      //para redondear los bordes
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                //Campo de texto para contraseña
                  TextField(
                    //4.10 enlazar controller
                  controller:_passCtrl,
                    //2.3 asignar foco al campo de texto
                    focusNode: _passwordFocus,
                    onChanged: (value) {
                      if(_isChecking != null){
                        //no tapes los ojos al ver el email
                        _isChecking!.change(false);
                      }
                      //si ischecking es nulo
                      if (_isHandsUp != null){
                      //Activar el modo chismoso
                      _isHandsUp!.change(true);
                      }
                    },
                    obscureText: _obscure,
                    //para mostrar el tipo de teclado
                  decoration: InputDecoration(
                    //4.11 mostrat texto error
                    errorText: passError,
                    hintText: 'Password',
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
                SizedBox(height: 10),
                //4.12 texto olvide la contraseña
                SizedBox(
                  width: size.width,
                  child: const Text(
                    'Forgot password?',
                    //alinear a la derecha
                    textAlign: TextAlign.right,
                    style: TextStyle(decoration: TextDecoration.underline)
                  ),
                ),
                const SizedBox(height: 10),
                //4.13 boton de login
                MaterialButton(
                  minWidth: size.width,
                  height: 50,
                  color: Colors.pinkAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(12),
                  ),
                  onPressed: _onLogin,
                  child: Text('Login', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 10),
                  //Texto
                  SizedBox(
                    width: size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: (){},
                          child: Text('Sign up', 
                          style: TextStyle(
                            color: Colors.black,
                            //subrayado
                            decoration: TextDecoration.underline,
                            //negritas
                            fontWeight: FontWeight.bold
                          ),
                          ),
                          ),
                      ],
                    ),
                  )
              ],
            ),
            ),
            ),
      ),
    );
  }
  @override
  void dispose(){
    //4.15 liberar los controladores
    _emailCtrl.dispose();
    _passCtrl.dispose();
    //2.4 liberar espacio en la memoria
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _typingdebounce?.cancel(); //eliminar el timer
    super.dispose();
  }
}