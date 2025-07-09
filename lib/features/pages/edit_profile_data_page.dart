import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_app/features/design/app_colors.dart';
import 'package:padel_app/models/user_model.dart';
import 'package:padel_app/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

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
      // authViewModel.clearErrorMessage(); // No estaba en la versión original del primer submit
      bool success = await authViewModel.actualizarDatosUsuario(usuarioActualizado);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar( // SnackBar original
            content: Text('Perfil actualizado con éxito.'),
            backgroundColor: AppColors.primaryGreen
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar( // SnackBar original
            content: Text(authViewModel.errorMessage ?? 'Error al actualizar el perfil.'),
            backgroundColor: Colors.red
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
        elevation: 0, // elevation 0 era común en los appbars que hicimos
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(size.width * 0.05),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // TextFormField para Nombre
              TextFormField(
                controller: _nombreController,
                style: GoogleFonts.lato(color: AppColors.textWhite, fontSize: size.width * 0.04),
                decoration: InputDecoration(
                  labelText: 'Nombre Completo',
                  labelStyle: GoogleFonts.lato(color: AppColors.textLightGray, fontSize: size.width * 0.04),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.textLightGray.withOpacity(0.5)), // Opacidad como en la versión original
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: size.width * 0.04, vertical: size.height * 0.02),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa tu nombre.';
                  }
                  return null;
                },
              ),
              SizedBox(height: size.height * 0.025), // Espacio original

              // TextFormField para Descripción
              TextFormField(
                controller: _descripcionController,
                style: GoogleFonts.lato(color: AppColors.textWhite, fontSize: size.width * 0.04),
                decoration: InputDecoration(
                  labelText: 'Descripción del Perfil',
                  labelStyle: GoogleFonts.lato(color: AppColors.textLightGray, fontSize: size.width * 0.04),
                   enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.textLightGray.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: size.width * 0.04, vertical: size.height * 0.02),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa una descripción para tu perfil.';
                  }
                  return null;
                },
              ),
              SizedBox(height: size.height * 0.04),
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        padding: EdgeInsets.symmetric(vertical: size.height * 0.018), // Padding original
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // Radio original
                        ),
                        // elevation: 3, // No había elevation en el botón original
                      ),
                      onPressed: _guardarCambios,
                      child: Text(
                        'Guardar Cambios',
                        style: GoogleFonts.lato(
                          color: AppColors.textBlack,
                          fontSize: size.width * 0.042, // Tamaño original
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
}
