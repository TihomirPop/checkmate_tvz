import 'package:checkmate_tvz/domain/chess_piece.dart';
import 'package:checkmate_tvz/domain/chess_position.dart';

class ChessBoard {
  Map<ChessPosition, ChessPiece> pieces = {};

  void init() {
    pieces.clear();

    pieces[const ChessPosition(0, 0)] = ChessPiece(
      type: PieceType.rook,
      color: PieceColor.dark,
    );
    pieces[const ChessPosition(0, 1)] = ChessPiece(
      type: PieceType.knight,
      color: PieceColor.dark,
    );
    pieces[const ChessPosition(0, 2)] = ChessPiece(
      type: PieceType.bishop,
      color: PieceColor.dark,
    );
    pieces[const ChessPosition(0, 3)] = ChessPiece(
      type: PieceType.queen,
      color: PieceColor.dark,
    );
    pieces[const ChessPosition(0, 4)] = ChessPiece(
      type: PieceType.king,
      color: PieceColor.dark,
    );
    pieces[const ChessPosition(0, 5)] = ChessPiece(
      type: PieceType.bishop,
      color: PieceColor.dark,
    );
    pieces[const ChessPosition(0, 6)] = ChessPiece(
      type: PieceType.knight,
      color: PieceColor.dark,
    );
    pieces[const ChessPosition(0, 7)] = ChessPiece(
      type: PieceType.rook,
      color: PieceColor.dark,
    );
    for (int col = 0; col < 8; col++) {
      pieces[ChessPosition(1, col)] = ChessPiece(
        type: PieceType.pawn,
        color: PieceColor.dark,
      );
      pieces[ChessPosition(6, col)] = ChessPiece(
        type: PieceType.pawn,
        color: PieceColor.light,
      );
    }
    pieces[const ChessPosition(7, 0)] = ChessPiece(
      type: PieceType.rook,
      color: PieceColor.light,
    );
    pieces[const ChessPosition(7, 1)] = ChessPiece(
      type: PieceType.knight,
      color: PieceColor.light,
    );
    pieces[const ChessPosition(7, 2)] = ChessPiece(
      type: PieceType.bishop,
      color: PieceColor.light,
    );
    pieces[const ChessPosition(7, 3)] = ChessPiece(
      type: PieceType.queen,
      color: PieceColor.light,
    );
    pieces[const ChessPosition(7, 4)] = ChessPiece(
      type: PieceType.king,
      color: PieceColor.light,
    );
    pieces[const ChessPosition(7, 5)] = ChessPiece(
      type: PieceType.bishop,
      color: PieceColor.light,
    );
    pieces[const ChessPosition(7, 6)] = ChessPiece(
      type: PieceType.knight,
      color: PieceColor.light,
    );
    pieces[const ChessPosition(7, 7)] = ChessPiece(
      type: PieceType.rook,
      color: PieceColor.light,
    );
  }

  String toFen() {
    final buffer = StringBuffer();

    // Part 1: Piece placement (from rank 8 to rank 1)
    for (int row = 0; row < 8; row++) {
      int emptyCount = 0;

      for (int col = 0; col < 8; col++) {
        final position = ChessPosition(row, col);
        final piece = pieces[position];

        if (piece == null) {
          emptyCount++;
        } else {
          // Append empty count before piece if any
          if (emptyCount > 0) {
            buffer.write(emptyCount);
            emptyCount = 0;
          }
          buffer.write(piece.toFenChar());
        }
      }

      // Append remaining empty count at end of rank
      if (emptyCount > 0) {
        buffer.write(emptyCount);
      }

      // Add rank separator except after last rank
      if (row < 7) {
        buffer.write('/');
      }
    }

    // Parts 2-6: Default values (board state doesn't track these yet)
    buffer.write(' w'); // Active color (default: white to move)
    buffer.write(' KQkq'); // Castling rights (default: all available)
    buffer.write(' -'); // En passant (default: none)
    buffer.write(' 0'); // Halfmove clock (default: 0)
    buffer.write(' 1'); // Fullmove number (default: 1)

    return buffer.toString();
  }
}
