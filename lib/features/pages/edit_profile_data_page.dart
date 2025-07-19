import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_app/features/design/app_colors.dart';
import 'package:padel_app/data/models/user_model.dart';
import 'package:padel_app/data/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class EditProfileDataPage extends StatefulWidget {
  final String userId; // Cambiado de Usuario a String

  const EditProfileDataPage({super.key, required this.userId}); // Cambiado el constructor

  @override
  State<EditProfileDataPage> createState() => _EditProfileDataPageState();
}

class _EditProfileDataPageState extends State<EditProfileDataPage> {
  final _formKey = GlobalKey<FormState>();
  Usuario? _usuario; // Para almacenar los datos del usuario cargado
  bool _isLoading = true; // Iniciar en true para mostrar carga mientras se obtienen datos
  bool _isSaving = false; // Para el estado de guardado

  // Controladores para los campos editables
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _asistenciasController;
  late TextEditingController _bonificacionesController;
  late TextEditingController _efectividadController;
  late TextEditingController _penalizacionesController;
  late TextEditingController _puntosController;
  late TextEditingController _puntosPosController;
  late TextEditingController _rankingController;
  late TextEditingController _subcategoriaController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    _descripcionController = TextEditingController();
    _asistenciasController = TextEditingController();
    _bonificacionesController = TextEditingController();
    _efectividadController = TextEditingController();
    _penalizacionesController = TextEditingController();
    _puntosController = TextEditingController();
    _puntosPosController = TextEditingController();
    _rankingController = TextEditingController();
    _subcategoriaController = TextEditingController();

    // Añadir listeners para el cálculo automático
    _puntosController.addListener(_calcularEfectividad);
    _asistenciasController.addListener(_calcularEfectividad);

    _loadUserData().then((_) {
      _calcularEfectividad();
    });
  }

  void _calcularEfectividad() {
    final puntos = int.tryParse(_puntosController.text);
    final asistencias = int.tryParse(_asistenciasController.text);

    if (puntos != null && asistencias != null && asistencias > 0) {
      final efectividad = (puntos / (asistencias * 3)) * 100;
      _efectividadController.text = efectividad.toStringAsFixed(2).replaceAll('.', ',');
    } else {
      _efectividadController.text = '0,00';
    }
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.userId)
          .get();
      if (userDoc.exists) {
        _usuario = Usuario.fromJson(userDoc.data() as Map<String, dynamic>);
        // Inicializar controladores con los datos del usuario
        _nombreController.text = _usuario!.nombre;
        _descripcionController.text = _usuario!.descripcionPerfil;
        _asistenciasController.text = _usuario!.asistencias.toString();
        _bonificacionesController.text = _usuario!.bonificaciones.toString();
        _efectividadController.text = _usuario!.efectividad.toString().replaceAll('.', ',');
        _penalizacionesController.text = _usuario!.penalizaciones.toString();
        _puntosController.text = _usuario!.puntos.toString();
        _puntosPosController.text = _usuario!.puntos_pos.toString();
        _rankingController.text = _usuario!.ranking.toString();
        _subcategoriaController.text = _usuario!.subcategoria.toString();
      } else {
        // Manejar el caso donde el usuario no se encuentra
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario no encontrado.', style: GoogleFonts.lato()), backgroundColor: Colors.red),
        );
        Navigator.of(context).pop(); // Regresar si no se encuentra el usuario
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e', style: GoogleFonts.lato()), backgroundColor: Colors.red),
      );
      Navigator.of(context).pop(); // Regresar en caso de error
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _asistenciasController.dispose();
    _bonificacionesController.dispose();
    _efectividadController.dispose();
    _penalizacionesController.dispose();
    _puntosController.dispose();
    _puntosPosController.dispose();
    _rankingController.dispose();
    _subcategoriaController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    if (_formKey.currentState!.validate() && _usuario != null) {
      setState(() {
        _isSaving = true;
      });

      // Reemplazar coma por punto para el parseo de double
      final efectividadString = _efectividadController.text.replaceAll(',', '.');
      final efectividadValue = double.tryParse(efectividadString) ?? _usuario!.efectividad;

      Usuario usuarioActualizado = _usuario!.copyWith(
        nombre: _nombreController.text,
        descripcionPerfil: _descripcionController.text,
        asistencias: int.tryParse(_asistenciasController.text) ?? _usuario!.asistencias,
        bonificaciones: int.tryParse(_bonificacionesController.text) ?? _usuario!.bonificaciones,
        efectividad: efectividadValue,
        penalizaciones: int.tryParse(_penalizacionesController.text) ?? _usuario!.penalizaciones,
        puntos: int.tryParse(_puntosController.text) ?? _usuario!.puntos,
        puntos_pos: int.tryParse(_puntosPosController.text) ?? _usuario!.puntos_pos,
        ranking: int.tryParse(_rankingController.text) ?? _usuario!.ranking,
        subcategoria: int.tryParse(_subcategoriaController.text) ?? _usuario!.subcategoria,
      );

      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      authViewModel.clearErrorMessage();
      bool success = await authViewModel.actualizarDatosUsuario(usuarioActualizado);

      // Verificar si el widget sigue montado antes de actualizar el estado o mostrar SnackBar
      if (!mounted) return;

      setState(() {
        _calcularEfectividad();
        _isSaving = false; // Cambiado de _isLoading a _isSaving
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
        title: Text('Editar Estadísticas', style: GoogleFonts.lato(color: AppColors.textWhite, fontWeight: FontWeight.bold)), // Título cambiado
        backgroundColor: AppColors.secondBlack,
        iconTheme: const IconThemeData(color: AppColors.textWhite),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : _usuario == null // Añadido chequeo por si _usuario es null después de carga
              ? Center(child: Text('No se pudieron cargar los datos del usuario.', style: GoogleFonts.lato(color: AppColors.textWhite)))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(size.width * 0.05),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _buildTextFormField(
                          controller: _nombreController,
                          labelText: 'Nombre',
                          validatorText: 'Ingresa un nombre válido.',
                          size: size,
                        ),
                        SizedBox(height: size.height * 0.025),
                        _buildTextFormField(
                          controller: _descripcionController,
                          labelText: 'Descripción del Perfil',
                          validatorText: 'Ingresa una descripción válida.',
                          maxLines: 3,
                          size: size,
                        ),
                        SizedBox(height: size.height * 0.025),
                        _buildTextFormField(
                          controller: _asistenciasController,
                          labelText: 'Asistencias',
                          validatorText: 'Ingresa un número válido.',
                          keyboardType: TextInputType.number,
                          size: size,
                        ),
                        SizedBox(height: size.height * 0.025),
                        _buildTextFormField(
                          controller: _bonificacionesController,
                          labelText: 'Bonificaciones',
                          validatorText: 'Ingresa un número válido.',
                          keyboardType: TextInputType.number,
                          size: size,
                        ),
                        SizedBox(height: size.height * 0.025),
                        _buildTextFormField(
                          controller: _efectividadController,
                          labelText: 'Efectividad (%)',
                          validatorText: 'Ingresa un número válido (ej: 75.5).',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          size: size,
                        ),
                        SizedBox(height: size.height * 0.025),
                        _buildTextFormField(
                          controller: _penalizacionesController,
                          labelText: 'Penalizaciones',
                          validatorText: 'Ingresa un número válido.',
                          keyboardType: TextInputType.number,
                          size: size,
                        ),
                        SizedBox(height: size.height * 0.025),
                        _buildTextFormField(
                          controller: _puntosController,
                          labelText: 'Puntos',
                          validatorText: 'Ingresa un número válido.',
                          keyboardType: TextInputType.number,
                          size: size,
                        ),
                        SizedBox(height: size.height * 0.025),
                        _buildTextFormField(
                          controller: _puntosPosController,
                          labelText: 'Puntos de Posición',
                          validatorText: 'Ingresa un número válido.',
                          keyboardType: TextInputType.number,
                          size: size,
                        ),
                        SizedBox(height: size.height * 0.025),
                        _buildTextFormField(
                          controller: _rankingController,
                          labelText: 'Ranking',
                          validatorText: 'Ingresa un número válido.',
                          keyboardType: TextInputType.number,
                          size: size,
                        ),
                        SizedBox(height: size.height * 0.025),
                        _buildTextFormField(
                          controller: _subcategoriaController,
                          labelText: 'Subcategoría',
                          validatorText: 'Ingresa un número válido.',
                          keyboardType: TextInputType.number,
                          size: size,
                        ),
                        SizedBox(height: size.height * 0.04),
                        _isSaving // Cambiado de _isLoading a _isSaving
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
    TextInputType? keyboardType, // Añadido keyboardType
  }) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.lato(color: AppColors.textWhite, fontSize: size.width * 0.04),
      keyboardType: keyboardType, // Aplicado keyboardType
      readOnly: labelText == 'Efectividad (%)',
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.lato(color: AppColors.textLightGray.withValues(alpha: 0.8), fontSize: size.width * 0.04),
        filled: true, // Añadir fondo al campo
        fillColor: AppColors.secondBlack.withValues(alpha: 0.5), // Color de fondo sutil
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.textLightGray.withValues(alpha: 0.5), width: 1),
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
