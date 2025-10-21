import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:padel_app/data/models/user_model.dart';
import 'package:padel_app/data/repositories/auth_repository.dart';

class RankingRepository {
  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  RankingRepository(
      {FirebaseFirestore? firestore, required AuthRepository authRepository})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _authRepository = authRepository;

  Future<List<Usuario>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection('usuarios').get();
      return snapshot.docs.map((doc) => Usuario.fromJson(doc.data())).toList();
    } catch (e) {
      // Re-throw the exception to be handled by the ViewModel
      throw Exception('Error al obtener la lista de usuarios: $e');
    }
  }

  Future<void> saveRanking({
    required String name,
    required String collectionName,
    required Map<String, dynamic> playersMap,
  }) async {
    try {
      final currentUser = await _authRepository.obtenerDatosUsuarioActual();
      if (currentUser == null || !currentUser.admin) {
        throw Exception('No tienes permisos de administrador.');
      }
      String fieldName;
      switch (collectionName) {
        case 'rank_ciudades':
          fieldName = 'ciudad';
          break;
        case 'rank_clubes':
          fieldName = 'club';
          break;
        case 'rank_whatsapp':
          fieldName = 'nombre_grupo';
          break;
        default:
          fieldName = 'nombre';
      }

      String mapKey;
      switch (collectionName) {
        case 'rank_clubes':
        case 'rank_ciudades':
          mapKey = 'jugadores';
          break;
        case 'rank_whatsapp':
          mapKey = 'integrantes';
          break;
        default:
          mapKey = 'jugadores';
      }

      await _firestore.collection(collectionName).add({
        fieldName: name,
        mapKey: playersMap,
      });
    } catch (e) {
      throw Exception('Error al guardar el ranking: $e');
    }
  }

  Future<void> addPlayersToRanking({
    required String collectionName,
    required String docId,
    required List<String> selectedUserIds,
  }) async {
    try {
      final currentUser = await _authRepository.obtenerDatosUsuarioActual();
      if (currentUser == null || !currentUser.admin) {
        throw Exception('No tienes permisos de administrador.');
      }

      String mapKey;
      switch (collectionName) {
        case 'rank_clubes':
        case 'rank_ciudades':
          mapKey = 'jugadores';
          break;
        case 'rank_whatsapp':
          mapKey = 'integrantes';
          break;
        default:
          mapKey = 'jugadores';
      }

      final playersMap = <String, dynamic>{};
      for (var userId in selectedUserIds) {
        final userDoc = await _firestore.collection('usuarios').doc(userId).get();
        if (userDoc.exists) {
          final user = Usuario.fromJson(userDoc.data()!);
          playersMap['$mapKey.$userId'] = JugadorStats(
            nombre: user.nombre,
            puntos: 0,
            asistencias: 0,
            subcategoria: 0,
            bonificaciones: 0,
            penalizacion: 0,
            uid: user.uid,
          ).toJson();
        }
      }

      await _firestore.collection(collectionName).doc(docId).update(playersMap);
    } catch (e) {
      throw Exception('Error al añadir jugadores al ranking: $e');
    }
  }
}