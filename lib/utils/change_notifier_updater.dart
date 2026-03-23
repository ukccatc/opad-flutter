import 'package:flutter/foundation.dart';

/// Mixin for logic classes that provides a convenient update method
mixin ChangeNotifierUpdater on ChangeNotifier {
  /// Update state and notify listeners
  void update() {
    notifyListeners();
  }
  
  /// Perform an action that updates state
  void updateState(VoidCallback fn) {
    fn();
    notifyListeners();
  }
}
