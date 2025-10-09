import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:padel_app/data/models/unified_stats_model.dart';
import 'package:padel_app/data/models/user_model.dart';
import 'package:padel_app/data/repositories/auth_repository.dart';

// Helper class to hold combined profile data, accessible to the UI
class ProfileData {
  final Usuario basicInfo;
  final UnifiedStats bestStats;

  ProfileData({required this.basicInfo, required this.bestStats});
}

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  AuthViewModel({required AuthRepository repository}) : _repository = repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  User? get currentUser => _repository.currentUser;
  Stream<User?> get authStateChanges => _repository.authStateChanges;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<ProfileData?> getProfileData() async {
    _clearError();
    try {
      return await _repository.getProfileData();
    } catch (e) {
      _errorMessage = "Error al obtener datos del perfil: ${e.toString()}";
      notifyListeners();
      return null;
    }
  }

  Future<bool> registrarUsuario({
    required String email,
    required String password,
    required String nombre,
    required String descripcionPerfil,
    required String documento,
    required String profesion,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      User? user = await _repository.registrarUsuario(
        email: email,
        password: password,
        nombre: nombre,
        descripcionPerfil: descripcionPerfil,
        documento: documento,
        profesion: profesion,
      );
      _setLoading(false);
      return user != null;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseAuthException(e.code);
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = "Ocurrió un error inesperado: ${e.toString()}";
      _setLoading(false);
      return false;
    }
  }

  Future<bool> iniciarSesion(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      await _repository.iniciarSesion(email, password);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseAuthException(e.code);
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = "Ocurrió un error inesperado: ${e.toString()}";
      _setLoading(false);
      return false;
    }
  }

  Future<void> cerrarSesion() async {
    _clearError();
    try {
      await _repository.cerrarSesion();
      notifyListeners();
    } catch (e) {
      _errorMessage = "Error al cerrar sesión: ${e.toString()}";
      notifyListeners();
    }
  }

  String _mapFirebaseAuthException(String code) {
    switch (code) {
      case 'weak-password':
        return 'La contraseña proporcionada es demasiado débil.';
      case 'email-already-in-use':
        return 'La cuenta ya existe para ese correo electrónico.';
      case 'user-not-found':
        return 'No se encontró usuario para ese correo electrónico.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'invalid-email':
        return 'El formato del correo electrónico no es válido.';
      case 'user-disabled':
        return 'Este usuario ha sido deshabilitado.';
      default:
        return 'Ocurrió un error de autenticación.';
    }
  }

  Future<Usuario?> obtenerDatosUsuarioActual() async {
    _clearError();
    try {
      final user = await _repository.obtenerDatosUsuarioActual();
      if (user == null) {
        _errorMessage = "No se encontraron datos para este usuario.";
        notifyListeners();
      }
      return user;
    } catch (e) {
      _errorMessage = "Error al obtener datos del usuario: ${e.toString()}";
      notifyListeners();
      return null;
    }
  }

  Future<bool> actualizarDatosUsuario(Usuario usuario) async {
    _setLoading(true);
    _clearError();
    try {
      await _repository.actualizarDatosUsuario(usuario);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Error al actualizar datos del usuario: ${e.toString()}";
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }
}