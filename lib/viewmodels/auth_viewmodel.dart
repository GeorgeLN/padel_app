import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:padel_app/models/user_model.dart'; // Asegúrate que la ruta sea correcta

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
      // 1. Crear usuario en Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // 2. Crear objeto Usuario con todos los datos
        Usuario nuevoUsuario = Usuario(
          uid: firebaseUser.uid,
          correoElectronico: email,
          nombre: nombre,
          descripcionPerfil: descripcionPerfil,
          // Los campos numéricos se inicializan a 0 por defecto según el modelo
          asistencias: 0,
          bonificaciones: 0,
          efectividad: 0.0,
          penalizaciones: 0,
          puntos: 0,
          puntos_pos: 0,
          ranking: 0,
          subcategoria: 0,
        );

        // 3. Guardar el objeto Usuario en Firestore
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
    _clearError(); // Limpiar errores antes de cerrar sesión
    try {
      await _auth.signOut();
      notifyListeners(); // Notificar para actualizar la UI si depende del estado de auth
    } catch (e) {
      // En general, signOut no debería fallar catastróficamente,
      // pero es bueno tener un catch por si acaso.
      // Podrías loggear este error si es necesario.
      _errorMessage = "Error al cerrar sesión: ${e.toString()}";
      notifyListeners(); // Notificar si hay error para mostrarlo
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

  // Nueva función para obtener los datos del usuario actual
  Future<Usuario?> obtenerDatosUsuarioActual() async {
    _clearError();
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      try {
        DocumentSnapshot<Map<String, dynamic>> userDoc =
            await _firestore.collection('usuarios').doc(firebaseUser.uid).get();
        if (userDoc.exists) {
          return Usuario.fromJson(userDoc.data()!);
        } else {
          _errorMessage = "No se encontraron datos para este usuario.";
          notifyListeners();
          return null;
        }
      } catch (e) {
        _errorMessage = "Error al obtener datos del usuario: ${e.toString()}";
        notifyListeners();
        return null;
      }
    } else {
      _errorMessage = "No hay usuario autenticado.";
      notifyListeners();
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
      // Opcional: podrías querer actualizar algún estado local del usuario si lo mantienes en el AuthViewModel
      // o notificar a los listeners que los datos del usuario podrían haber cambiado.
      // Por ahora, solo notificamos que la carga ha terminado.
      notifyListeners(); // Para actualizar isLoading y cualquier widget que dependa de ello.
      return true;
    } catch (e) {
      _errorMessage = "Error al actualizar datos del usuario: ${e.toString()}";
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }
}
