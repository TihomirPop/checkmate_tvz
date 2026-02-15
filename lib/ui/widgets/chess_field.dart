import 'package:flutter/material.dart';
import '../../domain/chess_piece.dart';
import '../../domain/chess_position.dart';
import 'chess_piece_widget.dart';

class ChessField extends StatelessWidget {
  final bool isLight;
  final int row;
  final int col;
  final ChessPiece? piece;
  final Function(ChessPiece, ChessPosition)? onPieceDropped;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragCompleted;
  final bool isDraggingEnabled;
  final bool Function(ChessPosition)? canAcceptPiece;
  final bool isValidMoveTarget;

  const ChessField({
    super.key,
    required this.isLight,
    required this.row,
    required this.col,
    this.piece,
    this.onPieceDropped,
    this.onDragStarted,
    this.onDragCompleted,
    this.isDraggingEnabled = true,
    this.canAcceptPiece,
    this.isValidMoveTarget = false,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<ChessPiece>(
      onWillAcceptWithDetails: (details) {
        if (canAcceptPiece != null) {
          final position = ChessPosition(row, col);
          return canAcceptPiece!(position);
        }

        return true;
      },
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
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (piece != null) _buildPieceWidget(),
              if (isValidMoveTarget) _buildValidMoveIndicator(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPieceWidget() {
    return ChessPieceWidget(
      piece: piece!,
      onDragStarted: onDragStarted,
      onDragCompleted: onDragCompleted,
      onDraggableCanceled: onDragCompleted,
      enabled: isDraggingEnabled,
    );
  }

  Widget _buildValidMoveIndicator() {
    return Center(
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: Colors.green.withAlpha(179), // 70% opacity
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1),
        ),
      ),
    );
  }
}
