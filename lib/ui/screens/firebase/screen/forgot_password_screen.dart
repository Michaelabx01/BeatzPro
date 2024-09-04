import 'package:beatzpro/ui/utils/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String email = '';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor, // Color primario ajustado
              Theme.of(context).primaryColor.withLightness(0.5) // Más claro
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
                  // Icono de usuario (avatar)
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: const Icon(Icons.lock_open, size: 50, color: Colors.white),
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
                        // Título
                        const Text(
                          'Restablecer Contraseña',
                          style: TextStyle(
                            color: Colors.white, // Ajustado para que combine con el tema
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Campo de Email
                        _buildTextField(
                          label: 'Email',
                          icon: Icons.email,
                          onChanged: (value) {
                            setState(() {
                              email = value;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        // Botón de Restablecer Contraseña
                        _buildResetButton(
                          text: isLoading ? 'Enviando...' : 'Restablecer Contraseña',
                          onPressed: () {
                            if (!isLoading) {
                              _resetPassword();
                            }
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
    required Function(String) onChanged,
  }) {
    return TextField(
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white), // Ajustado al tema
        filled: true,
        fillColor: Theme.of(context).primaryColor, // Color dinámico basado en el tema
        prefixIcon: Icon(icon, color: Colors.white),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildResetButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor, // Gradiente dinámico basado en el tema
            Theme.of(context).primaryColor, // Más claro
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 15),
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

  // Función para enviar el correo de restablecimiento de contraseña
  void _resetPassword() async {
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter your email'),
      ));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Enlace de restablecimiento de contraseña enviado a $email'),
      ));
      Navigator.pop(context);  // Vuelve a la pantalla de login
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${e.toString()}'),
      ));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
