import 'package:beatzpro/ui/utils/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../home.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  bool rememberMe = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    _loadUserCredentials(); // Cargar credenciales guardadas si existen
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Función para cargar los datos almacenados
  void _loadUserCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      rememberMe = prefs.getBool('rememberMe') ?? false; // Cargar estado del checkbox
      if (rememberMe) {
        // Si está activado, cargar el email y la contraseña guardados
        emailController.text = prefs.getString('email') ?? '';
        passwordController.text = prefs.getString('password') ?? '';
      }
    });
  }

  // Función para guardar o eliminar las credenciales en SharedPreferences
  void _saveOrRemoveUserCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      // Si el checkbox está marcado, guardamos las credenciales
      await prefs.setString('email', emailController.text);
      await prefs.setString('password', passwordController.text);
      await prefs.setBool('rememberMe', rememberMe);
    } else {
      // Si el checkbox está desmarcado, eliminamos las credenciales
      await prefs.remove('email');
      await prefs.remove('password');
      await prefs.setBool('rememberMe', rememberMe);
    }
  }

  // Función para realizar el inicio de sesión
  Future<void> _login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Por favor, ingrese su correo electrónico y contraseña')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Intento de iniciar sesión con Firebase Authentication
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Guardar o eliminar las credenciales según el estado del checkbox
      _saveOrRemoveUserCredentials();

      // Navegar a la pantalla de inicio (HomeScreen)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withLightness(0.4)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Imagen de usuario (avatar)
                  Image.asset(
                    'assets/icons/ico.png', // Ruta de la imagen
                    fit: BoxFit.cover,
                    width: 160,
                    height: 160,
                  ),
                  const SizedBox(height: 30),
                  // Caja central
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Campo de Email
                        _buildTextField(
                          label: 'Email',
                          icon: Icons.email,
                          controller: emailController,
                        ),
                        const SizedBox(height: 20),
                        // Campo de Password
                        _buildTextField(
                          label: 'Contraseña',
                          icon: Icons.lock,
                          obscureText: true,
                          controller: passwordController,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      rememberMe = value!;
                                      _saveOrRemoveUserCredentials();
                                    });
                                  },
                                  activeColor: Colors.white,
                                  checkColor: Colors.black,
                                ),
                                const Text(
                                  'Recordar',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ForgotPasswordScreen()),
                                );
                              },
                              child: const Text(
                                '¿Olvidaste tu contraseña?',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Botón de Login
                        _buildLoginButton(
                          text: isLoading ? 'Espere...' : 'Iniciar Sesión',
                          onPressed:
                              isLoading ? null : _login, // Función de login
                        ),
                        const SizedBox(height: 20),
                        // Botón de Registro
                        _buildRegisterButton(
                          text: 'Registrarse',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegisterScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        prefixIcon: Icon(icon, color: Colors.white),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildLoginButton({
    required String text,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          backgroundColor: Theme.of(context)
              .primaryColor, // Color dinámico basado en el tema
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          backgroundColor: Theme.of(context).primaryColor, // Color más claro
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
