import '../../domain/chess_board.dart';

class MoveResult {
  final ChessBoard board;
  final String? endGameMessage;

  const MoveResult({
    required this.board,
    this.endGameMessage,
  });
}
