import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:padel_app/data/models/unified_stats_model.dart';
import 'package:padel_app/data/models/user_model.dart';
import '../jugador_stats.dart';

// Helper class to hold combined profile data, accessible to the UI
class ProfileData {
  final Usuario basicInfo;
  final UnifiedStats bestStats;

  ProfileData({required this.basicInfo, required this.bestStats});
}

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // The new method to get combined profile data
  Future<ProfileData> getProfileData() async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      throw Exception("No hay usuario autenticado.");
    }

    try {
      final userId = firebaseUser.uid;

      // 1. Fetch base user data
      final userDoc = await _firestore.collection('usuarios').doc(userId).get();
      if (!userDoc.exists) {
        throw Exception('El documento del usuario no existe.');
      }
      final usuario = Usuario.fromJson(userDoc.data()!);

      // 2. Fetch all stats from all sources
      List<UnifiedStats> allUserStats = [];
      allUserStats.add(UnifiedStats.fromUsuario(usuario));

      Future<void> processRankCollection(String collectionName, String mapKey) async {
        final snapshot = await _firestore.collection(collectionName).get();
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final statsMap = data[mapKey] as Map<String, dynamic>? ?? {};
          if (statsMap.containsKey(userId)) {
            final statsData = statsMap[userId] as Map<String, dynamic>;
            // Ensure UID is in the stats, important for older data
            if (statsData['uid'] == null || statsData['uid'] == '') {
              statsData['uid'] = userId;
            }
            final stats = JugadorStats.fromJson(statsData);
            allUserStats.add(UnifiedStats.fromJugadorStats(stats, doc.id));
          }
        }
      }

      await Future.wait([
        processRankCollection('rank_clubes', 'jugadores'),
        processRankCollection('rank_ciudades', 'jugadores'),
        processRankCollection('rank_whatsapp', 'integrantes'),
      ]);

      // 3. Find the best stats
      if (allUserStats.isEmpty) {
        throw Exception('No se encontraron estadísticas para el usuario.');
      }
      allUserStats.sort((a, b) => b.puntos.compareTo(a.puntos));
      final bestStats = allUserStats.first;

      return ProfileData(basicInfo: usuario, bestStats: bestStats);

    } catch (e) {
      throw Exception("Error al obtener datos del perfil: ${e.toString()}");
    }
  }

  Future<User?> registrarUsuario({
    required String email,
    required String password,
    required String nombre,
    required String descripcionPerfil,
    required String documento,
    required String profesion,
  }) async {
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
          profesion: profesion,
          asistencias: 0,
          bonificaciones: 0,
          efectividad: 0.0,
          penalizaciones: 0,
          puntos: 0,
          subcategoria: 0,
          documento: documento,
        );

        await _firestore
            .collection('usuarios')
            .doc(firebaseUser.uid)
            .set(nuevoUsuario.toJson());
        return firebaseUser;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseAuthException(e.code));
    } catch (e) {
      throw Exception("Ocurrió un error inesperado: ${e.toString()}");
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

  Future<User?> iniciarSesion(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseAuthException(e.code));
    } catch (e) {
      throw Exception("Ocurrió un error inesperado: ${e.toString()}");
    }
  }

  Future<void> cerrarSesion() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception("Error al cerrar sesión: ${e.toString()}");
    }
  }

  Future<Usuario?> obtenerDatosUsuarioActual() async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      try {
        DocumentSnapshot<Map<String, dynamic>> userDoc =
            await _firestore.collection('usuarios').doc(firebaseUser.uid).get();
        if (userDoc.exists) {
          return Usuario.fromJson(userDoc.data()!);
        } else {
          throw Exception("No se encontraron datos para este usuario.");
        }
      } catch (e) {
        throw Exception("Error al obtener datos del usuario: ${e.toString()}");
      }
    }
    return null;
  }

  Future<void> actualizarDatosUsuario(Usuario usuario) async {
    try {
      await _firestore
          .collection('usuarios')
          .doc(usuario.uid)
          .update(usuario.toJson());
    } catch (e) {
      throw Exception("Error al actualizar datos del usuario: ${e.toString()}");
    }
  }
}