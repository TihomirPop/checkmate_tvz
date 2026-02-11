import 'package:checkmate_tvz/models/chess_board.dart';
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
  ChessBoard chessBoard = ChessBoard();
  ChessPosition? dragSourcePosition;

  @override
  void initState() {
    super.initState();
    chessBoard.init();
  }

  void _onPieceDropped(ChessPiece piece, ChessPosition targetPosition) {
    setState(() {
      // Remove piece from source position
      if (dragSourcePosition != null) {
        chessBoard.pieces.remove(dragSourcePosition);
      }
      // Add piece to target position
      chessBoard.pieces[targetPosition] = piece;
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
            final piece = chessBoard.pieces[position];

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
