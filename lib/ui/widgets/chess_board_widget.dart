import 'package:checkmate_tvz/domain/chess_board.dart';
import 'package:flutter/material.dart';
import '../../data/repositories/chess_game_repository.dart';
import '../../data/result/result.dart';
import '../../domain/chess_piece.dart';
import '../../domain/chess_position.dart';
import 'chess_field.dart';

class ChessBoardWidget extends StatefulWidget {
  const ChessBoardWidget({super.key});

  @override
  State<ChessBoardWidget> createState() => _ChessBoardWidgetState();
}

class _ChessBoardWidgetState extends State<ChessBoardWidget> {
  final ChessGameRepository _repository = ChessGameRepository();
  ChessBoard chessBoard = ChessBoard();
  ChessPosition? dragSourcePosition;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final fen = chessBoard.toFen();
    final result = await _repository.startGameFromFen(fen: fen, isWhite: true);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      switch (result) {
        case Success(data: final board):
          chessBoard = board;
        case Failure(message: final msg):
          _errorMessage = msg;
          // Fallback to local initialization for offline functionality
          chessBoard.init();
      }
    });
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
  void dispose() {
    _repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return error(context);
    }

    return success();
  }

    Widget error(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to connect to game server',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _initializeGame,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
            const SizedBox(height: 8),
            Text(
              'Playing offline with local board',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget success() {
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
