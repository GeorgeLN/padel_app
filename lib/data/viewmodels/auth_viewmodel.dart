import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:padel_app/data/models/user_model.dart'; // Asegúrate que la ruta sea correcta

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  Future<bool> registrarUsuario({
    required String email,
    required String password,
    required String nombre,
    required String descripcionPerfil,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        Usuario nuevoUsuario = Usuario(
          uid: firebaseUser.uid,
          correoElectronico: email,
          nombre: nombre,
          descripcionPerfil: descripcionPerfil,
          asistencias: 0,
          bonificaciones: 0,
          efectividad: 0.0,
          penalizaciones: 0,
          puntos: 0,
          subcategoria: 0,
        );

        await _firestore
            .collection('usuarios')
            .doc(firebaseUser.uid)
            .set(nuevoUsuario.toJson());

        _setLoading(false);
        return true;
      } else {
        _errorMessage = "No se pudo crear el usuario.";
        _setLoading(false);
        return false;
      }
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
      await _auth.signInWithEmailAndPassword(email: email, password: password);
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
      await _auth.signOut();
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
    _clearError(); // No notificar aquí para no limpiar errores de otras operaciones
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      try {
        DocumentSnapshot<Map<String, dynamic>> userDoc =
            await _firestore.collection('usuarios').doc(firebaseUser.uid).get();
        if (userDoc.exists) {
          return Usuario.fromJson(userDoc.data()!);
        } else {
          _errorMessage = "No se encontraron datos para este usuario.";
          notifyListeners(); // Notificar solo si hay error específico de esta función
          return null;
        }
      } catch (e) {
        _errorMessage = "Error al obtener datos del usuario: ${e.toString()}";
        notifyListeners();
        return null;
      }
    } else {
      // No establecer _errorMessage aquí si es una condición esperada (ej. usuario no logueado)
      // Dejar que la UI maneje la ausencia de un usuario.
      // Si es un error inesperado, entonces sí.
      // _errorMessage = "No hay usuario autenticado.";
      // notifyListeners();
      return null;
    }
  }

  Future<bool> actualizarDatosUsuario(Usuario usuario) async {
    _setLoading(true);
    _clearError();
    try {
      await _firestore
          .collection('usuarios')
          .doc(usuario.uid)
          .update(usuario.toJson());
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
