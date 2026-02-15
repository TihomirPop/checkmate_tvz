import 'package:checkmate_tvz/domain/chess_board.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../data/repositories/chess_game_repository.dart';
import '../../data/result/result.dart';
import '../../domain/chess_piece.dart';
import '../../domain/chess_position.dart';
import 'chess_field.dart';
import 'piece_spawner_widget.dart';

class ChessBoardWidget extends StatefulWidget {
  const ChessBoardWidget({super.key});

  @override
  State<ChessBoardWidget> createState() => _ChessBoardWidgetState();
}

enum BoardMode {
  edit, // User is arranging pieces
  play, // Normal gameplay with backend
}

class _ChessBoardWidgetState extends State<ChessBoardWidget> {
  final ChessGameRepository _repository = ChessGameRepository();
  ChessBoard chessBoard = ChessBoard();
  ChessPosition? dragSourcePosition;
  bool _isLoading = false;
  String? _errorMessage;
  BoardMode _boardMode = BoardMode.edit;
  bool _hasStartedGame = false;
  Map<ChessPosition, Set<ChessPosition>> _validMoves = {};

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  void _initializeBoard() {
    setState(() {
      chessBoard.init();
      _boardMode = BoardMode.edit;
      _hasStartedGame = false;
    });

    if (kDebugMode) {
      print('[ChessBoard] Initialized in Edit Mode');
    }
  }

  Future<void> _startGame() async {
    if (_hasStartedGame) return; // Prevent double-starts

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final fen = chessBoard.toFen();

    if (kDebugMode) {
      print('[ChessBoard] Starting game with FEN: $fen');
    }

    final result = await _repository.startGameFromFen(fen: fen, isWhite: true);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _hasStartedGame = true;

      switch (result) {
        case Success(data: final board):
          chessBoard = board;
          _boardMode = BoardMode.play; // Transition to play mode
          if (kDebugMode) {
            print(
              '[ChessBoard] Game started successfully, switched to Play Mode',
            );
          }
          // Fetch valid moves asynchronously (don't await)
          _fetchValidMoves();
        case Failure(message: final msg):
          _errorMessage = msg;
          _boardMode = BoardMode.edit; // Stay in edit mode on error
          _hasStartedGame = false; // Allow retry
      }
    });
  }

  Future<void> _fetchValidMoves() async {
    if (_boardMode != BoardMode.play) return;

    if (kDebugMode) {
      print('[ChessBoard] Fetching valid moves...');
    }

    final result = await _repository.getAllValidMoves();
    if (!mounted) return;

    setState(() {
      switch (result) {
        case Success(data: final moves):
          _validMoves = moves;
          if (kDebugMode) {
            print('[ChessBoard] Loaded ${moves.length} source positions with valid moves');
          }
        case Failure(message: final msg):
          if (kDebugMode) {
            print('[ChessBoard] Failed to fetch moves: $msg');
          }
          _validMoves = {};
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

  void _onPieceDeletedFromBoard() {
    setState(() {
      // Remove piece from its source position
      if (dragSourcePosition != null) {
        chessBoard.pieces.remove(dragSourcePosition);
        dragSourcePosition = null;
      }
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

  bool _canAcceptPieceInEditMode(ChessPosition position) {
    // In edit mode, only allow drops on empty squares
    return !chessBoard.pieces.containsKey(position);
  }

  bool _canAcceptPieceInPlayMode(ChessPosition targetPosition) {
    if (dragSourcePosition == null) return false;
    final validDestinations = _validMoves[dragSourcePosition];
    return validDestinations?.contains(targetPosition) ?? false;
  }

  bool _isValidMoveTarget(ChessPosition position) {
    if (_boardMode != BoardMode.play) return false;
    if (dragSourcePosition == null) return false;
    return _validMoves[dragSourcePosition]?.contains(position) ?? false;
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return error(context);
    }

    return Column(
      children: [
        board(), // Existing board widget

        if (_boardMode == BoardMode.edit) ...[
          const SizedBox(height: 16),
          // Piece spawner for adding pieces to the board
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: PieceSpawnerWidget(onPieceDeleted: _onPieceDeletedFromBoard),
          ),
          const SizedBox(height: 16),
          // Start game button (fixed: removed Positioned wrapper)
          FloatingActionButton.extended(
            onPressed: _startGame,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Game'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ],
    );
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

            // Retry with current board position
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _errorMessage = null; // Clear error, try again
                });
                _startGame(); // Retry with current position (NOT _initializeGame)
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
            const SizedBox(height: 8),
            Text(
              'Custom position preserved - click Retry to start with current board',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget board() {
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
              isDraggingEnabled: !_isLoading,
              canAcceptPiece: _boardMode == BoardMode.edit
                  ? _canAcceptPieceInEditMode
                  : _canAcceptPieceInPlayMode,
              isValidMoveTarget: _isValidMoveTarget(position),
            );
          },
        ),
      ),
    );
  }
}
