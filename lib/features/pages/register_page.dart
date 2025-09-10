import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_app/features/design/app_colors.dart'; // Ajusta la ruta si es necesario
import 'package:padel_app/data/viewmodels/auth_viewmodel.dart'; // Ajusta la ruta si es necesario
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nombreController = TextEditingController();
  final _documentoController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _profesionController = TextEditingController();
  final _passwordController = TextEditingController();
  final _verifyPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _nombreController.dispose();
    _documentoController.dispose();
    _descripcionController.dispose();
    _profesionController.dispose();
    _passwordController.dispose();
    _verifyPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      bool success = await authViewModel.registrarUsuario(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        nombre: _nombreController.text.trim(),
        documento: _documentoController.text.trim(),
        profesion: _profesionController.text.trim(),
        descripcionPerfil: _descripcionController.text.trim(),
      );

      if (mounted) { // Verificar si el widget sigue montado
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registro exitoso. Por favor, inicia sesión.')),
          );
          // Navegar a login screen o home screen según el flujo deseado
          // Por ejemplo, si tienes una ruta 'login':
          // Navigator.of(context).pushReplacementNamed('login');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authViewModel.errorMessage ?? 'Error en el registro.')),
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
        title: Text('Registrarse', style: GoogleFonts.lato(color: AppColors.textWhite)),
        backgroundColor: AppColors.secondBlack,
        iconTheme: const IconThemeData(color: AppColors.textWhite),
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
                  'Crear Nueva Cuenta',
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
                  controller: _nombreController,
                  labelText: 'Nombre',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa tu nombre.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: size.height * 0.02),
                _buildTextFormField(
                  controller: _documentoController,
                  labelText: 'Documento',
                  icon: Icons.badge_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa tu nombre.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: size.height * 0.02),
                _buildTextFormField(
                  controller: _descripcionController,
                  labelText: 'Descripción del Perfil',
                  icon: Icons.description,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa una descripción.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: size.height * 0.02),
                _buildTextFormField(
                  controller: _profesionController,
                  labelText: 'Profesión',
                  icon: Icons.work_history_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa tu nombre.';
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
                      return 'Por favor, ingresa una contraseña.';
                    }
                    if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: size.height * 0.02),
                _buildTextFormField(
                  controller: _verifyPasswordController,
                  labelText: 'Verificar Contraseña',
                  icon: Icons.lock_reset_rounded,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, verifica tu contraseña.';
                    }
                    if (value != _passwordController.text) {
                      return 'Las contraseñas no coinciden.';
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
                            'Registrarse',
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
                    // Navegar a la pantalla de login
                    // Navigator.of(context).pushReplacementNamed('login');
                    // O si LoginScreen es la única otra pantalla en la pila antes de esta:
                    if (Navigator.canPop(context)) {
                       Navigator.pop(context);
                    }
                  },
                  child: Text(
                    '¿Ya tienes una cuenta? Inicia Sesión',
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
    int maxLines = 1,
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
      maxLines: maxLines,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}
