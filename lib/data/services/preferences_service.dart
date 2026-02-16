import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../result/result.dart';

/// Service for managing saved chess positions using SharedPreferences.
///
/// Handles storage operations for FEN strings representing chess board positions.
/// All methods return [Result<T>] for consistent error handling.
class PreferencesService {
  static const String _savedPositionsKey = 'saved_chess_positions';

  SharedPreferences? _prefs;

  Future<Result<void>> _ensureInitialized() async {
    if (_prefs != null) {
      return const Success(null);
    }

    try {
      _prefs = await SharedPreferences.getInstance();
      if (kDebugMode) {
        print('[PreferencesService] Initialized SharedPreferences');
      }
      return const Success(null);
    } catch (e) {
      final message = 'Failed to initialize preferences: $e';
      if (kDebugMode) {
        print('[PreferencesService] $message');
      }
      return Failure(message);
    }
  }

  /// Retrieves all saved chess positions as FEN strings.
  ///
  /// Returns empty list if no positions are saved.
  /// Returns [Failure] if storage access fails.
  Future<Result<List<String>>> getSavedPositions() async {
    final initResult = await _ensureInitialized();
    if (initResult is Failure) {
      return Failure(initResult.message);
    }

    try {
      final positions = _prefs!.getStringList(_savedPositionsKey) ?? [];

      if (kDebugMode) {
        print(
          '[PreferencesService] Loaded ${positions.length} saved positions',
        );
      }

      return Success(positions);
    } catch (e) {
      final message = 'Failed to load saved positions: $e';
      if (kDebugMode) {
        print('[PreferencesService] $message');
      }
      return Failure(message);
    }
  }

  /// Saves a new chess position (FEN string) to storage.
  ///
  /// Appends the position to the existing list of saved positions.
  /// Returns [Success] if save operation completes successfully.
  /// Returns [Failure] if storage operation fails.
  Future<Result<void>> savePosition(String fen) async {
    final initResult = await _ensureInitialized();
    if (initResult is Failure) {
      return Failure(initResult.message);
    }

    try {
      final positionsResult = await getSavedPositions();
      final positions = switch (positionsResult) {
        Success(data: final list) => List<String>.from(list),
        Failure(message: final msg) => throw Exception(msg),
      };

      positions.add(fen);

      final success = await _prefs!.setStringList(_savedPositionsKey, positions);

      if (!success) {
        throw Exception('SharedPreferences.setStringList returned false');
      }

      if (kDebugMode) {
        print('[PreferencesService] Saved position: $fen');
        print(
          '[PreferencesService] Total saved positions: ${positions.length}',
        );
      }

      return const Success(null);
    } catch (e) {
      final message = 'Failed to save position: $e';
      if (kDebugMode) {
        print('[PreferencesService] $message');
      }
      return Failure(message);
    }
  }

  /// Deletes a saved position at the specified index.
  ///
  /// Returns [Success] if deletion completes successfully.
  /// Returns [Failure] if index is out of bounds or storage operation fails.
  Future<Result<void>> deletePosition(int index) async {
    final initResult = await _ensureInitialized();
    if (initResult is Failure) {
      return Failure(initResult.message);
    }

    try {
      final positionsResult = await getSavedPositions();
      final positions = switch (positionsResult) {
        Success(data: final list) => List<String>.from(list),
        Failure(message: final msg) => throw Exception(msg),
      };

      if (index < 0 || index >= positions.length) {
        throw RangeError(
          'Index $index out of bounds (0-${positions.length - 1})',
        );
      }

      final removed = positions.removeAt(index);
      final success = await _prefs!.setStringList(_savedPositionsKey, positions);

      if (!success) {
        throw Exception('SharedPreferences.setStringList returned false');
      }

      if (kDebugMode) {
        print(
          '[PreferencesService] Deleted position at index $index: $removed',
        );
        print('[PreferencesService] Remaining positions: ${positions.length}');
      }

      return const Success(null);
    } catch (e) {
      final message = 'Failed to delete position: $e';
      if (kDebugMode) {
        print('[PreferencesService] $message');
      }
      return Failure(message);
    }
  }
}
