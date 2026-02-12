class ChessGameRequest {
  final String fen;
  final bool isWhite;

  const ChessGameRequest({required this.fen, required this.isWhite});

  Map<String, dynamic> toJson() => {'fen': fen, 'isWhite': isWhite};
}
