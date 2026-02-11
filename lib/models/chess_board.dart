import 'package:checkmate_tvz/models/chess_piece.dart';
import 'package:checkmate_tvz/models/chess_position.dart';

class ChessBoard {
  Map<ChessPosition, ChessPiece> pieces = {};
  
  void init() {
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
    return "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";
  }
}