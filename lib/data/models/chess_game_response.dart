class ChessGameResponse {
  final List<String> board; // 64-character board representation
  final String? endGameMessage; // null, "Stalemate", "Player wins", or "Opponent wins"

  const ChessGameResponse({required this.board, this.endGameMessage});

  factory ChessGameResponse.fromJson(Map<String, dynamic> json) {
    return ChessGameResponse(
      board: List<String>.from(json['board']),
      endGameMessage: json['endGameMessage'],
    );
  }
}
