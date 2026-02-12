import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/chess_game_request.dart';
import '../models/chess_game_response.dart';
import '../result/result.dart';

class ChessApiService {
  final String baseUrl;
  final http.Client _client;
  static const Duration _timeout = Duration(seconds: 10);

  ChessApiService({
    this.baseUrl = 'http://localhost:8080',
    http.Client? client,
  }) : _client = client ?? http.Client();

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
          print('[ChessAPI] Success - Board size: ${gameResponse.board.length}');
        }

        return Success(gameResponse);
      } else if (response.statusCode == 400) {
        final errorBody = response.body.isNotEmpty ? response.body : 'Invalid FEN position';
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

  // Placeholder methods for future endpoints

  /// Make a move in the current game
  Future<Result<ChessGameResponse>> makeMove({
    required String from,
    required String to,
    String? promotion,
  }) async {
    // TODO: Implement when backend endpoint is ready
    throw UnimplementedError('makeMove endpoint not yet implemented');
  }

  /// Get legal moves for a piece at the given position
  Future<Result<List<String>>> getLegalMoves({
    required String position,
  }) async {
    // TODO: Implement when backend endpoint is ready
    throw UnimplementedError('getLegalMoves endpoint not yet implemented');
  }

  /// Dispose of the HTTP client
  void dispose() {
    _client.close();
  }
}
