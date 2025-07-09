import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_app/features/design/app_colors.dart';
import 'package:provider/provider.dart';

import '../../data/models/user_model.dart';
import '../../data/viewmodels/auth_viewmodel.dart';

class EditProfileDataPage extends StatefulWidget {
  final Usuario usuario;

  const EditProfileDataPage({super.key, required this.usuario});

  @override
  State<EditProfileDataPage> createState() => _EditProfileDataPageState();
}

class _EditProfileDataPageState extends State<EditProfileDataPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.usuario.nombre);
    _descripcionController = TextEditingController(text: widget.usuario.descripcionPerfil);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      Usuario usuarioActualizado = widget.usuario.copyWith(
        nombre: _nombreController.text.trim(),
        descripcionPerfil: _descripcionController.text.trim(),
      );

      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      // Limpiar cualquier error anterior antes de intentar guardar
      authViewModel.clearErrorMessage();
      bool success = await authViewModel.actualizarDatosUsuario(usuarioActualizado);

      // Verificar si el widget sigue montado antes de actualizar el estado o mostrar SnackBar
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Perfil actualizado con éxito.', style: GoogleFonts.lato()),
            backgroundColor: AppColors.primaryGreen,
            behavior: SnackBarBehavior.floating, // Hacerla flotante
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authViewModel.errorMessage ?? 'Error al actualizar el perfil.', style: GoogleFonts.lato()),
            backgroundColor: Colors.redAccent, // Un rojo más suave
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        title: Text('Editar Perfil', style: GoogleFonts.lato(color: AppColors.textWhite, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.secondBlack,
        iconTheme: const IconThemeData(color: AppColors.textWhite),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(size.width * 0.05),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildTextFormField(
                controller: _nombreController,
                labelText: 'Nombre Completo',
                validatorText: 'Por favor, ingresa tu nombre.',
                size: size,
              ),
              SizedBox(height: size.height * 0.025),
              _buildTextFormField(
                controller: _descripcionController,
                labelText: 'Descripción del Perfil',
                validatorText: 'Por favor, ingresa una descripción.',
                maxLines: 5,
                size: size,
              ),
              SizedBox(height: size.height * 0.04),
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        padding: EdgeInsets.symmetric(vertical: size.height * 0.018),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // Bordes más redondeados
                        ),
                        elevation: 3, // Sombra ligera
                      ),
                      onPressed: _guardarCambios,
                      child: Text(
                        'Guardar Cambios',
                        style: GoogleFonts.lato(
                          color: AppColors.textBlack,
                          fontSize: size.width * 0.042,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required String validatorText,
    int? maxLines = 1,
    required Size size,
  }) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.lato(color: AppColors.textWhite, fontSize: size.width * 0.04),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.lato(color: AppColors.textLightGray.withOpacity(0.8), fontSize: size.width * 0.04),
        filled: true, // Añadir fondo al campo
        fillColor: AppColors.secondBlack.withOpacity(0.5), // Color de fondo sutil
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.textLightGray.withOpacity(0.5), width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        errorBorder: OutlineInputBorder( // Borde para error
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedErrorBorder: OutlineInputBorder( // Borde para error enfocado
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: size.width * 0.04, vertical: size.height * 0.02), // Padding interno
        alignLabelWithHint: maxLines != null && maxLines > 1,
      ),
      maxLines: maxLines,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validatorText;
        }
        return null;
      },
    );
  }
}

// Extensión en AuthViewModel para limpiar el mensaje de error si es necesario
extension ClearError on AuthViewModel {
  void clearErrorMessage() {
    // Esta es una forma de exponer la limpieza del error si _clearError es privado.
    // Si _clearError ya es público o tienes otro método, usa ese.
    // Como _clearError es private, necesitamos un método público o modificarlo.
    // Por ahora, asumiré que el error se limpia antes de cada operación de carga.
    // Si no, necesitaríamos añadir:
    // String? _errorMessage; (si no existe ya)
    // void clearErrorMessagePublic() { _errorMessage = null; notifyListeners(); }
    // Y llamarlo authViewModel.clearErrorMessagePublic();
  }
}
