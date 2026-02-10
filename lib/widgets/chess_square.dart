import 'package:flutter/material.dart';

class ChessSquare extends StatelessWidget {
  final bool isLight;
  final int row;
  final int col;

  const ChessSquare({
    super.key,
    required this.isLight,
    required this.row,
    required this.col,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isLight ? const Color(0xFFEEEED2) : const Color(0xFF769656),
    );
  }
}
