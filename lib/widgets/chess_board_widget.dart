import 'package:flutter/material.dart';
import '../models/chess_piece.dart';
import '../models/chess_position.dart';
import 'chess_field.dart';

class ChessBoardWidget extends StatefulWidget {
  const ChessBoardWidget({super.key});

  @override
  State<ChessBoardWidget> createState() => _ChessBoardWidgetState();
}

class _ChessBoardWidgetState extends State<ChessBoardWidget> {
  Map<ChessPosition, ChessPiece> pieces = {};
  ChessPosition? dragSourcePosition;

  @override
  void initState() {
    super.initState();
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

  void _onPieceDropped(ChessPiece piece, ChessPosition targetPosition) {
    setState(() {
      // Remove piece from source position
      if (dragSourcePosition != null) {
        pieces.remove(dragSourcePosition);
      }
      // Add piece to target position
      pieces[targetPosition] = piece;
      // Clear drag source
      dragSourcePosition = null;
    });
  }

  void _onDragStarted(ChessPosition position) {
    setState(() {
      dragSourcePosition = position;
    });
  }

  void _onDragCompleted() {
    setState(() {
      dragSourcePosition = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
            childAspectRatio: 1.0,
          ),
          itemCount: 64,
          itemBuilder: (context, index) {
            final row = index ~/ 8;
            final col = index % 8;
            final isLight = (row + col) % 2 == 0;
            final position = ChessPosition(row, col);
            final piece = pieces[position];

            return ChessField(
              isLight: isLight,
              row: row,
              col: col,
              piece: piece,
              onPieceDropped: _onPieceDropped,
              onDragStarted: () => _onDragStarted(position),
              onDragCompleted: _onDragCompleted,
            );
          },
        ),
      ),
    );
  }
}
