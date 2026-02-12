enum PieceType { pawn, knight, bishop, rook, queen, king }

enum PieceColor { light, dark }

class ChessPiece {
  final PieceType type;
  final PieceColor color;

  const ChessPiece({required this.type, required this.color});

  String get assetPath {
    final typeChar = switch (type) {
      PieceType.pawn => 'p',
      PieceType.knight => 'n',
      PieceType.bishop => 'b',
      PieceType.rook => 'r',
      PieceType.queen => 'q',
      PieceType.king => 'k',
    };
    final colorChar = switch (color) {
      PieceColor.light => 'l',
      PieceColor.dark => 'd',
    };
    return 'assets/images/chess_pieces/Chess_$typeChar${colorChar}t45.svg';
  }

  String toFenChar() {
    final baseChar = switch (type) {
      PieceType.pawn => 'p',
      PieceType.knight => 'n',
      PieceType.bishop => 'b',
      PieceType.rook => 'r',
      PieceType.queen => 'q',
      PieceType.king => 'k',
    };

    return color == PieceColor.light
        ? baseChar.toUpperCase()
        : baseChar;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChessPiece &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          color == other.color;

  @override
  int get hashCode => type.hashCode ^ color.hashCode;

  @override
  String toString() => 'ChessPiece(${color.name} ${type.name})';
}
