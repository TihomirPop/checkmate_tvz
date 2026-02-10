import 'package:flutter/material.dart';
import '../models/chess_piece.dart';
import '../models/chess_position.dart';
import 'chess_piece_widget.dart';

class ChessField extends StatelessWidget {
  final bool isLight;
  final int row;
  final int col;
  final ChessPiece? piece;
  final Function(ChessPiece, ChessPosition)? onPieceDropped;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragCompleted;

  const ChessField({
    super.key,
    required this.isLight,
    required this.row,
    required this.col,
    this.piece,
    this.onPieceDropped,
    this.onDragStarted,
    this.onDragCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<ChessPiece>(
      onAcceptWithDetails: (details) {
        final position = ChessPosition(row, col);
        onPieceDropped?.call(details.data, position);
      },
      builder: (context, candidateData, rejectedData) {
        final showHighlight = candidateData.isNotEmpty;

        return Container(
          decoration: BoxDecoration(
            color: isLight ? const Color(0xFFEEEED2) : const Color(0xFF769656),
            border: showHighlight
                ? Border.all(color: Colors.yellow, width: 3)
                : null,
          ),
          child: piece != null
              ? ChessPieceWidget(
                  piece: piece!,
                  onDragStarted: onDragStarted,
                  onDragCompleted: onDragCompleted,
                  onDraggableCanceled: onDragCompleted,
                )
              : null,
        );
      },
    );
  }
}
