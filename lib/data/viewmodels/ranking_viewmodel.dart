import 'package:flutter/material.dart';
import 'package:padel_app/data/models/user_model.dart';
import 'package:padel_app/data/jugador_stats.dart';
import 'package:padel_app/data/repositories/ranking_repository.dart';

class RankingViewModel extends ChangeNotifier {
  final RankingRepository _repository;

  RankingViewModel({required RankingRepository repository}) : _repository = repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<Usuario> _allUsers = [];
  List<Usuario> get allUsers => _allUsers;

  List<Usuario> _filteredUsers = [];
  List<Usuario> get filteredUsers => _filteredUsers;

  final List<String> _selectedUserIds = [];
  List<String> get selectedUserIds => _selectedUserIds;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  Future<void> getUsers() async {
    _setLoading(true);
    _clearError();
    try {
      _allUsers = await _repository.getAllUsers();
      _filteredUsers = _allUsers;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void filterUsers(String query) {
    final lowerCaseQuery = query.toLowerCase();
    _filteredUsers = _allUsers.where((user) {
      final nameMatches = user.nombre.toLowerCase().contains(lowerCaseQuery);
      final documentMatches = user.documento.toLowerCase().contains(lowerCaseQuery);
      return nameMatches || documentMatches;
    }).toList();
    notifyListeners();
  }

  void toggleUserSelection(String userId) {
    if (_selectedUserIds.contains(userId)) {
      _selectedUserIds.remove(userId);
    } else {
      _selectedUserIds.add(userId);
    }
    notifyListeners();
  }

  Future<bool> saveRanking({
    required String name,
    required String collectionName,
  }) async {
    if (name.isEmpty || _selectedUserIds.isEmpty) {
      _errorMessage = "El nombre no puede estar vacío y debes seleccionar al menos un jugador.";
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final playersMap = <String, dynamic>{};
      for (var userId in _selectedUserIds) {
        final user = _allUsers.firstWhere((u) => u.uid == userId);
        playersMap[userId] = JugadorStats(
          nombre: user.nombre,
          puntos: 0,
          asistencias: 0,
          subcategoria: 0,
          bonificaciones: 0,
          penalizacion: 0,
          uid: user.uid,
        ).toJson();
      }

      await _repository.saveRanking(
        name: name,
        collectionName: collectionName,
        playersMap: playersMap,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }
}