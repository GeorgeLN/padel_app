import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:padel_app/data/models/user_model.dart';

class RankingRepository {
  final FirebaseFirestore _firestore;

  RankingRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

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
}