import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  CurrentUser _currentUser = CurrentUser('');

  void changeSelectedIndex(String value) {
    _currentUser = CurrentUser(value);
    notifyListeners();
  }

  CurrentUser get selectedIndex => _currentUser;
}

class CurrentUser {
  final String current;

  CurrentUser(this.current);
}
