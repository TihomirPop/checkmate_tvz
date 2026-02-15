import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../domain/chess_piece.dart';

/// Widget that provides an infinite supply of chess pieces for edit mode.
///
/// Displays two rows of draggable pieces (white and black), excluding kings.
/// Pieces can be dragged onto the board to add them during edit mode.
/// Unlike normal dragging, pieces remain visible in the spawner after being dragged.
class PieceSpawnerWidget extends StatelessWidget {
  const PieceSpawnerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Define pieces for spawner (excluding kings)
    final lightPieces = [
      const ChessPiece(type: PieceType.pawn, color: PieceColor.light),
      const ChessPiece(type: PieceType.knight, color: PieceColor.light),
      const ChessPiece(type: PieceType.bishop, color: PieceColor.light),
      const ChessPiece(type: PieceType.rook, color: PieceColor.light),
      const ChessPiece(type: PieceType.queen, color: PieceColor.light),
    ];

    final darkPieces = [
      const ChessPiece(type: PieceType.pawn, color: PieceColor.dark),
      const ChessPiece(type: PieceType.knight, color: PieceColor.dark),
      const ChessPiece(type: PieceType.bishop, color: PieceColor.dark),
      const ChessPiece(type: PieceType.rook, color: PieceColor.dark),
      const ChessPiece(type: PieceType.queen, color: PieceColor.dark),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // White pieces row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: lightPieces
                .map((piece) => _buildDraggablePiece(piece))
                .toList(),
          ),
          const SizedBox(height: 8),
          // Black pieces row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: darkPieces
                .map((piece) => _buildDraggablePiece(piece))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggablePiece(ChessPiece piece) {
    final pieceImage = SvgPicture.asset(
      piece.assetPath,
      width: 50,
      height: 50,
      fit: BoxFit.contain,
    );

    return Draggable<ChessPiece>(
      data: piece,
      feedback: SizedBox(
        width: 60,
        height: 60,
        child: Opacity(
          opacity: 0.8,
          child: SvgPicture.asset(piece.assetPath, fit: BoxFit.contain),
        ),
      ),
      childWhenDragging: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        child: Opacity(
          opacity: 1.0,
          child: pieceImage,
        ),
      ),
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        child: pieceImage,
      ),
    );
  }
}
