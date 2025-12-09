import 'package:flutter/foundation.dart';

class GameController extends ChangeNotifier {
  bool _isPaused = false;
  int _score = 0;

  void startGame() {
    _score = 0;
    _isPaused = false;
    notifyListeners();
  }

  void addScore(int points) {
    _score += points;
    notifyListeners(); // Notify listeners to update UI
  }

  void togglePause() {
    _isPaused = !_isPaused;
    notifyListeners();
  }

  bool get isPaused => _isPaused;
  int get score => _score;
}
