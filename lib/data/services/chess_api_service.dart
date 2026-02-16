import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/chess_game_request.dart';
import '../models/chess_game_response.dart';
import '../models/make_move_request.dart';
import '../models/move_dto.dart';
import '../result/result.dart';

class ChessApiService {
  String baseUrl;
  final http.Client _client;
  static const Duration _timeout = Duration(seconds: 10);

  ChessApiService({this.baseUrl = 'http://localhost:8080', http.Client? client})
    : _client = client ?? http.Client();

  /// Start a new chess game from a FEN position
  Future<Result<ChessGameResponse>> startFromFen({
    required String fen,
    required bool isWhite,
  }) async {
    final request = ChessGameRequest(fen: fen, isWhite: isWhite);

    if (kDebugMode) {
      print('[ChessAPI] POST /chess/start/fen - FEN: $fen, isWhite: $isWhite');
    }

    try {
      final uri = Uri.parse('$baseUrl/chess/start/fen');
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(_timeout);

      if (kDebugMode) {
        print('[ChessAPI] Response status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final gameResponse = ChessGameResponse.fromJson(json);

        if (kDebugMode) {
          print(
            '[ChessAPI] Success - Board size: ${gameResponse.board.length}',
          );
        }

        return Success(gameResponse);
      } else if (response.statusCode == 400) {
        final errorBody = response.body.isNotEmpty
            ? response.body
            : 'Invalid FEN position';
        return Failure(
          'Bad request: $errorBody',
          statusCode: response.statusCode,
        );
      } else if (response.statusCode >= 500) {
        return Failure(
          'Server error: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      } else {
        return Failure(
          'Unexpected error: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      if (kDebugMode) {
        print('[ChessAPI] Request timeout');
      }
      return const Failure('Request timed out. Please check your connection.');
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        print('[ChessAPI] Network error: $e');
      }
      return Failure('Network error: ${e.message}');
    } on FormatException catch (e) {
      if (kDebugMode) {
        print('[ChessAPI] JSON parse error: $e');
      }
      return Failure('Invalid response format: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('[ChessAPI] Unexpected error: $e');
      }
      return Failure('Unexpected error: $e');
    }
  }


  /// Make a move and get the updated board state after AI response
  /// Parameters:
  ///   - fromIndex: Source square (0-63)
  ///   - toIndex: Destination square (0-63)
  ///   - thinkingTime: AI thinking time in milliseconds (typically 600)
  Future<Result<ChessGameResponse>> makeMove({
    required int fromIndex,
    required int toIndex,
    int thinkingTime = 600,
  }) async {
    final request = MakeMoveRequest(
      from: fromIndex,
      to: toIndex,
      thinkingTime: thinkingTime,
    );

    if (kDebugMode) {
      print(
        '[ChessAPI] POST /chess/move - from: $fromIndex, to: $toIndex, thinking: $thinkingTime ms',
      );
    }

    try {
      final uri = Uri.parse('$baseUrl/chess/move');
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(_timeout);

      if (kDebugMode) {
        print('[ChessAPI] Response status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final gameResponse = ChessGameResponse.fromJson(json);

        if (kDebugMode) {
          print(
            '[ChessAPI] Success - Board updated, endGame: ${gameResponse.endGameMessage}',
          );
        }

        return Success(gameResponse);
      } else if (response.statusCode == 400) {
        final errorBody = response.body.isNotEmpty
            ? response.body
            : 'Invalid move';
        return Failure(
          'Bad request: $errorBody',
          statusCode: response.statusCode,
        );
      } else if (response.statusCode >= 500) {
        return Failure(
          'Server error: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      } else {
        return Failure(
          'Unexpected error: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      if (kDebugMode) {
        print('[ChessAPI] Request timeout');
      }
      return const Failure('Request timed out. Please check your connection.');
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        print('[ChessAPI] Network error: $e');
      }
      return Failure('Network error: ${e.message}');
    } on FormatException catch (e) {
      if (kDebugMode) {
        print('[ChessAPI] JSON parse error: $e');
      }
      return Failure('Invalid response format: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('[ChessAPI] Unexpected error: $e');
      }
      return Failure('Unexpected error: $e');
    }
  }

  /// Get all legal moves for the current game state
  /// Returns all valid moves across the entire board
  Future<Result<List<MoveDto>>> getAllMoves() async {
    if (kDebugMode) {
      print('[ChessAPI] GET /chess/moves');
    }

    try {
      final uri = Uri.parse('$baseUrl/chess/moves');
      final response = await _client.get(uri, headers: {"ngrok-skip-browser-warning": "true"}).timeout(_timeout);

      if (kDebugMode) {
        print('[ChessAPI] Response status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final jsonList = jsonDecode(response.body) as List;
        final moves = jsonList
            .map((json) => MoveDto.fromJson(json as Map<String, dynamic>))
            .toList();

        if (kDebugMode) {
          print('[ChessAPI] Success - Loaded ${moves.length} moves');
        }

        return Success(moves);
      } else if (response.statusCode == 400) {
        final errorBody = response.body.isNotEmpty
            ? response.body
            : 'Bad request';
        return Failure(
          'Bad request: $errorBody',
          statusCode: response.statusCode,
        );
      } else if (response.statusCode >= 500) {
        return Failure(
          'Server error: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      } else {
        return Failure(
          'Unexpected error: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      if (kDebugMode) {
        print('[ChessAPI] Request timeout');
      }
      return const Failure('Request timed out. Please check your connection.');
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        print('[ChessAPI] Network error: $e');
      }
      return Failure('Network error: ${e.message}');
    } on FormatException catch (e) {
      if (kDebugMode) {
        print('[ChessAPI] JSON parse error: $e');
      }
      return Failure('Invalid response format: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('[ChessAPI] Unexpected error: $e');
      }
      return Failure('Unexpected error: $e');
    }
  }

  /// Dispose of the HTTP client
  void dispose() {
    _client.close();
  }
}
