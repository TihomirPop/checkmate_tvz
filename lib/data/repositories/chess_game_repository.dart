import 'package:flutter/foundation.dart';
import '../../domain/chess_board.dart';
import '../../domain/chess_piece.dart';
import '../../domain/chess_position.dart';
import '../result/result.dart';
import '../services/chess_api_service.dart';

class ChessGameRepository {
  final ChessApiService _apiService;

  ChessGameRepository({ChessApiService? apiService})
      : _apiService = apiService ?? ChessApiService();

  /// Start a new game from a FEN position
  /// Transforms the API response (64-character array) into ChessBoard domain model
  Future<Result<ChessBoard>> startGameFromFen({
    required String fen,
    required bool isWhite,
  }) async {
    final result = await _apiService.startFromFen(fen: fen, isWhite: isWhite);

    return switch (result) {
      Success(data: final response) => _transformToChessBoard(response.board),
      Failure(message: final msg, statusCode: final code) =>
        Failure(msg, statusCode: code),
    };
  }

  /// Transform 64-character board array to ChessBoard with `Map<ChessPosition, ChessPiece>`
  Result<ChessBoard> _transformToChessBoard(List<String> boardArray) {
    if (boardArray.length != 64) {
      return Failure('Invalid board size: ${boardArray.length}, expected 64');
    }

    final pieces = <ChessPosition, ChessPiece>{};

    for (int index = 0; index < 64; index++) {
      final char = boardArray[index];
      if (char == ' ') continue; // Empty square

      final row = index ~/ 8;
      final col = index % 8;
      final position = ChessPosition(row, col);

      final piece = _parsePieceFromChar(char);
      if (piece == null) {
        continue; // Skip empy space and unknown
      }

      pieces[position] = piece;
    }

    if (kDebugMode) {
      print('[Repository] Transformed ${pieces.length} pieces from board array');
    }

    return Success(ChessBoard()..pieces = pieces);
  }

  /// Parse a single character from the board array into a ChessPiece
  /// Uppercase = white (light), Lowercase = black (dark)
  /// K/k = King, Q/q = Queen, R/r = Rook, B/b = Bishop, N/n = Knight, P/p = Pawn
  ChessPiece? _parsePieceFromChar(String char) {
    if (char.isEmpty) return null;

    final isWhite = char == char.toUpperCase();
    final color = isWhite ? PieceColor.light : PieceColor.dark;
    final lowerChar = char.toLowerCase();

    final type = switch (lowerChar) {
      'k' => PieceType.king,
      'q' => PieceType.queen,
      'r' => PieceType.rook,
      'b' => PieceType.bishop,
      'n' => PieceType.knight,
      'p' => PieceType.pawn,
      _ => null,
    };

    if (type == null) return null;

    return ChessPiece(type: type, color: color);
  }

  // Placeholder methods for future endpoints

  /// Make a move and get the updated board state
  Future<Result<ChessBoard>> makeMove({
    required String from,
    required String to,
    String? promotion,
  }) async {
    // TODO: Implement when backend endpoint is ready
    throw UnimplementedError('makeMove not yet implemented');
  }

  /// Get legal moves for a piece at the given position
  Future<Result<List<String>>> getLegalMoves({
    required String position,
  }) async {
    // TODO: Implement when backend endpoint is ready
    throw UnimplementedError('getLegalMoves not yet implemented');
  }

  /// Dispose resources
  void dispose() {
    _apiService.dispose();
  }
}
