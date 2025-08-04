import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_app/features/design/app_colors.dart';

import '../../data/jugador_stats.dart';

class EditProfileDataPage extends StatefulWidget {
  final String userId;
  final String sourceCollection;
  final String docId;
  final String mapKey;

  const EditProfileDataPage({
    super.key,
    required this.userId,
    required this.sourceCollection,
    required this.docId,
    required this.mapKey,
  });

  @override
  State<EditProfileDataPage> createState() => _EditProfileDataPageState();
}

class _EditProfileDataPageState extends State<EditProfileDataPage> {
  final _formKey = GlobalKey<FormState>();
  JugadorStats? _jugadorStats;
  bool _isLoading = true;
  bool _isSaving = false;

  late TextEditingController _asistenciasController;
  late TextEditingController _bonificacionesController;
  late TextEditingController _efectividadController;
  late TextEditingController _penalizacionesController;
  late TextEditingController _puntosController;
  late TextEditingController _subcategoriaController;
  late TextEditingController _nombreController;

  @override
  void initState() {
    super.initState();
    _asistenciasController = TextEditingController();
    _bonificacionesController = TextEditingController();
    _efectividadController = TextEditingController();
    _penalizacionesController = TextEditingController();
    _puntosController = TextEditingController();
    _subcategoriaController = TextEditingController();
    _nombreController = TextEditingController();

    _puntosController.addListener(_calcularEfectividad);
    _asistenciasController.addListener(_calcularEfectividad);

    _loadJugadorStatsData();
  }

  void _calcularEfectividad() {
    final puntos = int.tryParse(_puntosController.text);
    final asistencias = int.tryParse(_asistenciasController.text);

    if (puntos != null && asistencias != null && asistencias > 0) {
      final efectividad = (puntos / (asistencias * 3)) * 100;
      _efectividadController.text = efectividad.round().toString();
    } else {
      _efectividadController.text = '0';
    }
  }

  Future<void> _loadJugadorStatsData() async {
    setState(() { _isLoading = true; });
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      String userName = userDoc.exists ? userDoc.get('nombre') ?? '' : '';

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection(widget.sourceCollection)
          .doc(widget.docId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final statsMap = data[widget.mapKey] as Map<String, dynamic>? ?? {};
        final jugadorData = statsMap[widget.userId]as Map<String, dynamic>?;

        if (jugadorData != null) {
          _jugadorStats = JugadorStats.fromJson(jugadorData);
          if (_jugadorStats!.nombre.isEmpty) {
            _jugadorStats = _jugadorStats!.copyWith(nombre: userName);
          }
        } else {
          _jugadorStats = JugadorStats.empty(uid: widget.userId, nombre: userName);
        }
      } else {
        _jugadorStats = JugadorStats.empty(uid: widget.userId, nombre: userName);
      }

      _asistenciasController.text = _jugadorStats!.asistencias.toString();
      _bonificacionesController.text = _jugadorStats!.bonificaciones.toString();
      _efectividadController.text = _jugadorStats!.efectividad.toString();
      _penalizacionesController.text = _jugadorStats!.penalizacion.toString();
      _puntosController.text = _jugadorStats!.puntos.toString();
      _subcategoriaController.text = _jugadorStats!.subcategoria.toString();
      _nombreController.text = _jugadorStats!.nombre;

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e', style: GoogleFonts.lato()), backgroundColor: Colors.red),
      );
      Navigator.of(context).pop();
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  Future<void> _guardarCambios() async {
    if (_formKey.currentState!.validate() && _jugadorStats != null) {
      setState(() { _isSaving = true; });

      final efectividadValue = int.tryParse(_efectividadController.text) ?? _jugadorStats!.efectividad;

      JugadorStats statsActualizado = _jugadorStats!.copyWith(
        nombre: _jugadorStats!.nombre,
        asistencias: int.tryParse(_asistenciasController.text) ?? _jugadorStats!.asistencias,
        bonificaciones: int.tryParse(_bonificacionesController.text) ?? _jugadorStats!.bonificaciones,
        efectividad: efectividadValue,
        penalizacion: int.tryParse(_penalizacionesController.text) ?? _jugadorStats!.penalizacion,
        puntos: int.tryParse(_puntosController.text) ?? _jugadorStats!.puntos,
        subcategoria: int.tryParse(_subcategoriaController.text) ?? _jugadorStats!.subcategoria,
      );

      try {
        await FirebaseFirestore.instance
            .collection(widget.sourceCollection)
            .doc(widget.docId)
            .update({'${widget.mapKey}.${widget.userId}': statsActualizado.toJson()});

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Estadísticas actualizadas con éxito.', style: GoogleFonts.lato()),
            backgroundColor: AppColors.primaryGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e', style: GoogleFonts.lato()),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        if(mounted) {
          setState(() { _isSaving = false; });
        }
      }
    }
  }

  @override
  void dispose() {
    _asistenciasController.dispose();
    _bonificacionesController.dispose();
    _efectividadController.dispose();
    _penalizacionesController.dispose();
    _puntosController.dispose();
    _subcategoriaController.dispose();
    _nombreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        title: Text('Editar Estadísticas', style: GoogleFonts.lato(color: AppColors.textWhite, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.secondBlack,
        iconTheme: const IconThemeData(color: AppColors.textWhite),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : _jugadorStats == null
              ? Center(child: Text('No se pudieron cargar los datos.', style: GoogleFonts.lato(color: AppColors.textWhite)))
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
                          validatorText: 'Ingresa un nombre.',
                          size: size,
                          readOnly: true,
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
                          validatorText: 'Valor inválido.',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          size: size,
                          readOnly: true,
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
                          controller: _subcategoriaController,
                          labelText: 'Subcategoría',
                          validatorText: 'Ingresa un número válido.',
                          keyboardType: TextInputType.number,
                          size: size,
                        ),
                        SizedBox(height: size.height * 0.04),
                        _isSaving
                            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryGreen,
                                  padding: EdgeInsets.symmetric(vertical: size.height * 0.018),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 3,
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
    TextInputType? keyboardType,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.lato(color: AppColors.textWhite, fontSize: size.width * 0.04),
      keyboardType: keyboardType,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.lato(color: AppColors.textLightGray.withValues(alpha: 0.8), fontSize: size.width * 0.04),
        filled: true,
        fillColor: readOnly ? Colors.grey[800] : AppColors.secondBlack.withValues(alpha: 0.5),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.textLightGray.withValues(alpha: 0.5), width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: size.width * 0.04, vertical: size.height * 0.02),
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
