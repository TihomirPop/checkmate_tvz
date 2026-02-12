import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../domain/chess_piece.dart';

class ChessPieceWidget extends StatelessWidget {
  final ChessPiece piece;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragCompleted;
  final VoidCallback? onDraggableCanceled;

  const ChessPieceWidget({
    super.key,
    required this.piece,
    this.onDragStarted,
    this.onDragCompleted,
    this.onDraggableCanceled,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<ChessPiece>(
      data: piece,
      onDragStarted: onDragStarted,
      onDragCompleted: onDragCompleted,
      onDraggableCanceled: (_, _) => onDraggableCanceled?.call(),
      feedback: SizedBox(
        width: 60,
        height: 60,
        child: Opacity(
          opacity: 0.8,
          child: SvgPicture.asset(piece.assetPath, fit: BoxFit.contain),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: SvgPicture.asset(piece.assetPath, fit: BoxFit.contain),
      ),
      child: SvgPicture.asset(piece.assetPath, fit: BoxFit.contain),
    );
  }
}
