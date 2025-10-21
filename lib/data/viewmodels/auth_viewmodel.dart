import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:padel_app/data/models/user_model.dart';
import 'package:padel_app/data/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthViewModel({required AuthRepository authRepository})
      : _authRepository = authRepository {
    _checkAdminStatus();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isAdmin = false;
  bool get isAdmin => _isAdmin;

  User? get currentUser => _authRepository.currentUser;
  Stream<User?> get authStateChanges => _authRepository.authStateChanges;

  Future<void> _checkAdminStatus() async {
    final usuario = await _authRepository.obtenerDatosUsuarioActual();
    _isAdmin = usuario?.admin ?? false;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  Future<ProfileData?> getProfileData() async {
    _setLoading(true);
    _clearError();
    try {
      final profileData = await _authRepository.getProfileData();
      _setLoading(false);
      return profileData;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
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
      await _authRepository.registrarUsuario(
        email: email,
        password: password,
        nombre: nombre,
        descripcionPerfil: descripcionPerfil,
        documento: documento,
        profesion: profesion,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> iniciarSesion(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      await _authRepository.iniciarSesion(email, password);
      await _checkAdminStatus();
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<void> cerrarSesion() async {
    _clearError();
    try {
      await _authRepository.cerrarSesion();
      _isAdmin = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<Usuario?> obtenerDatosUsuarioActual() async {
    _setLoading(true);
    _clearError();
    try {
      final usuario = await _authRepository.obtenerDatosUsuarioActual();
      _setLoading(false);
      return usuario;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      notifyListeners();
      return null;
    }
  }

  Future<bool> actualizarDatosUsuario(Usuario usuario) async {
    _setLoading(true);
    _clearError();
    try {
      await _authRepository.actualizarDatosUsuario(usuario);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }
}