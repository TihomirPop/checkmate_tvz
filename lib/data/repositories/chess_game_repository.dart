import 'package:flutter/foundation.dart';
import '../../domain/chess_board.dart';
import '../../domain/chess_piece.dart';
import '../../domain/chess_position.dart';
import '../models/move_dto.dart';
import '../models/move_result.dart';
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
      Failure(message: final msg, statusCode: final code) => Failure(
        msg,
        statusCode: code,
      ),
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
      print(
        '[Repository] Transformed ${pieces.length} pieces from board array',
      );
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

  /// Make a move and get the updated board state with optional end game message
  /// Converts ChessPosition to board indices, calls backend, transforms response
  Future<Result<MoveResult>> makeMove({
    required ChessPosition from,
    required ChessPosition to,
  }) async {
    final fromIndex = _positionToIndex(from);
    final toIndex = _positionToIndex(to);

    if (kDebugMode) {
      print(
        '[Repository] Making move: from $from (index $fromIndex) to $to (index $toIndex)',
      );
    }

    final result = await _apiService.makeMove(
      fromIndex: fromIndex,
      toIndex: toIndex,
      thinkingTime: 600,
    );

    return switch (result) {
      Success(data: final response) => _transformToMoveResult(response),
      Failure(message: final msg, statusCode: final code) => Failure(
        msg,
        statusCode: code,
      ),
    };
  }

  Result<MoveResult> _transformToMoveResult(
    dynamic /* ChessGameResponse */ response,
  ) {
    final boardResult = _transformToChessBoard(response.board);

    return switch (boardResult) {
      Success(data: final board) => Success(
        MoveResult(
          board: board,
          endGameMessage: response.endGameMessage,
        ),
      ),
      Failure(message: final msg, statusCode: final code) => Failure(
        msg,
        statusCode: code,
      ),
    };
  }

  /// Get all valid moves for the current game state
  /// Returns a map where key = source position, value = set of valid destinations
  Future<Result<Map<ChessPosition, Set<ChessPosition>>>>
  getAllValidMoves() async {
    final result = await _apiService.getAllMoves();
    return switch (result) {
      Success(data: final moves) => _transformToValidMovesMap(moves),
      Failure(message: final msg, statusCode: final code) => Failure(
        msg,
        statusCode: code,
      ),
    };
  }

  /// Transform list of MoveDto to Map with ChessPosition keys and Set values
  /// Groups moves by source position for efficient lookup
  Result<Map<ChessPosition, Set<ChessPosition>>> _transformToValidMovesMap(
    List<MoveDto> moves,
  ) {
    final validMoves = <ChessPosition, Set<ChessPosition>>{};

    for (final move in moves) {
      final fromPosition = _indexToPosition(move.from);
      final toPosition = _indexToPosition(move.to);
      validMoves
          .putIfAbsent(fromPosition, () => <ChessPosition>{})
          .add(toPosition);
    }

    if (kDebugMode) {
      print(
        '[Repository] Transformed ${moves.length} moves into ${validMoves.length} source positions',
      );
    }

    return Success(validMoves);
  }

  /// Convert 0-63 board index to ChessPosition
  /// Backend uses 0=a8, 7=h8, 56=a1, 63=h1
  ChessPosition _indexToPosition(int index) {
    final row = index ~/ 8;
    final col = index % 8;
    return ChessPosition(row, col);
  }

  /// Convert ChessPosition to 0-63 board index
  /// Inverse of _indexToPosition
  int _positionToIndex(ChessPosition position) {
    return position.row * 8 + position.col;
  }

  /// Dispose resources
  void dispose() {
    _apiService.dispose();
  }
}
