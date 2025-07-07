import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_app/features/design/app_colors.dart'; // Ajusta la ruta si es necesario
import 'package:padel_app/viewmodels/auth_viewmodel.dart'; // Ajusta la ruta si es necesario
import 'package:padel_app/views/register_screen.dart'; // Para navegar a RegisterScreen
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      bool success = await authViewModel.iniciarSesion(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) { // Verificar si el widget sigue montado
        if (success) {
          // Navegar a la pantalla principal después del login
          // Por ejemplo, si tu pantalla principal es 'table' o 'home'
          // Navigator.of(context).pushReplacementNamed('table');
          // O limpiar la pila y navegar a la home
          // Navigator.of(context).pushNamedAndRemoveUntil('table', (route) => false);
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Inicio de sesión exitoso!')),
          );
          // Aquí deberías navegar a tu pantalla principal.
          // Por ahora, si 'table' es tu home y está configurada:
          if (Navigator.canPop(context)) { // Si vino de register, pop. Sino, reemplazar.
            Navigator.pop(context); // Asumiendo que table page está debajo
          } else {
            // Esta es una suposición, necesitarás ajustar la navegación
            Navigator.pushReplacementNamed(context, 'table');
          }

        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authViewModel.errorMessage ?? 'Error al iniciar sesión.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        title: Text('Iniciar Sesión', style: GoogleFonts.lato(color: AppColors.textWhite)),
        backgroundColor: AppColors.secondBlack,
        iconTheme: const IconThemeData(color: AppColors.textWhite),
        // automaticallyImplyLeading: false, // Descomentar si no quieres botón de atrás
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Bienvenido de Nuevo',
                  style: GoogleFonts.lato(
                    color: AppColors.textWhite,
                    fontSize: size.width * 0.06,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: size.height * 0.03),
                _buildTextFormField(
                  controller: _emailController,
                  labelText: 'Correo Electrónico',
                  icon: Icons.email,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa tu correo.';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Ingresa un correo válido.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: size.height * 0.02),
                _buildTextFormField(
                  controller: _passwordController,
                  labelText: 'Contraseña',
                  icon: Icons.lock,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa tu contraseña.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: size.height * 0.04),
                authViewModel.isLoading
                    ? const CircularProgressIndicator(color: AppColors.primaryGreen)
                    : SizedBox(
                        width: double.infinity,
                        height: size.height * 0.06,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Text(
                            'Iniciar Sesión',
                            style: GoogleFonts.lato(
                              color: AppColors.textBlack,
                              fontSize: size.width * 0.045,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                SizedBox(height: size.height * 0.02),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: Text(
                    '¿No tienes una cuenta? Regístrate',
                    style: GoogleFonts.lato(color: AppColors.primaryGreen),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.lato(color: AppColors.textWhite),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.lato(color: AppColors.textLightGray),
        prefixIcon: Icon(icon, color: AppColors.textLightGray),
        filled: true,
        fillColor: AppColors.secondBlack,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.primaryGreen),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
      obscureText: obscureText,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}
