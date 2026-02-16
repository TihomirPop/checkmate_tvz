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
  ChessBoardWidgetState createState() => ChessBoardWidgetState();
}

enum BoardMode {
  edit, // User is arranging pieces
  play, // Normal gameplay with backend
}

/// Public state class to allow external access via GlobalKey
class ChessBoardWidgetState extends State<ChessBoardWidget> {
  final ChessGameRepository _repository = ChessGameRepository();
  ChessBoard chessBoard = ChessBoard();
  ChessPosition? dragSourcePosition;
  bool _isLoading = false;
  String? _errorMessage;
  BoardMode _boardMode = BoardMode.edit;
  bool _hasStartedGame = false;
  Map<ChessPosition, Set<ChessPosition>> _validMoves = {};
  String? _gameOverMessage; // "Player wins", "Opponent wins", or "Stalemate"
  bool _playerIsWhite = true;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
    _loadSavedApiUrl();
  }

  /// Load saved API URL from preferences on app start
  Future<void> _loadSavedApiUrl() async {
    final result = await _repository.getSavedApiUrl();

    switch (result) {
      case Success(data: final url?):
        _repository.apiService.baseUrl = url;
        if (kDebugMode) {
          print('[ChessBoard] Loaded saved API URL: $url');
        }
      case Success(data: null):
        if (kDebugMode) {
          print('[ChessBoard] No saved API URL, using default');
        }
      case Failure(message: final msg):
        if (kDebugMode) {
          print('[ChessBoard] Failed to load API URL: $msg');
        }
    }
  }

  /// Public method to reset the game
  void resetGame() {
    _initializeBoard();
  }

  /// Public method to get the current API base URL
  String getApiUrl() {
    return _repository.apiService.baseUrl;
  }

  /// Public method to update the API base URL
  void setApiUrl(String url) {
    if (kDebugMode) {
      print('[ChessBoard] Updating API URL to: $url');
    }
    _repository.apiService.baseUrl = url;
    _repository.saveApiUrl(url).then((result) {
      if (result is Failure && kDebugMode) {
        print('[ChessBoard] Failed to save API URL: ${result.message}');
      }
    });
  }

  /// Public method to load board from FEN string
  /// Loads the position but keeps the board in Edit Mode for manual adjustments
  Future<void> loadFromFen(String fen) async {
    if (kDebugMode) {
      print('[ChessBoard] Loading from FEN: $fen');
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Use existing repository method
    final result = await _repository.startGameFromFen(
      fen: fen,
      isWhite: _playerIsWhite,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;

      switch (result) {
        case Success(data: final board):
          chessBoard = board;
          _boardMode = BoardMode.edit; // Keep in edit mode!
          _hasStartedGame = false;
          _gameOverMessage = null;
          _validMoves = {};

          if (kDebugMode) {
            print('[ChessBoard] Loaded FEN successfully, staying in Edit Mode');
          }

        case Failure(message: final msg):
          _errorMessage = null; // Don't show error screen for FEN loading
          if (kDebugMode) {
            print('[ChessBoard] Failed to load FEN: $msg');
          }

          // Show error to user via SnackBar
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Invalid FEN: $msg'),
                backgroundColor: Colors.red,
              ),
            );
          }
      }
    });
  }

  void _initializeBoard() {
    setState(() {
      chessBoard.init();
      _boardMode = BoardMode.edit;
      _hasStartedGame = false;
      _gameOverMessage = null;
      _validMoves = {};
      _playerIsWhite = true; // Reset to default
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

    final result = await _repository.startGameFromFen(
      fen: fen,
      isWhite: _playerIsWhite,
    );

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

  /// Save the current board position to local storage
  Future<void> _saveCurrentPosition() async {
    setState(() {
      _isLoading = true;
    });

    final fen = chessBoard.toFen();

    if (kDebugMode) {
      print('[ChessBoard] Saving position: $fen');
    }

    final result = await _repository.saveCurrentPosition(fen);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    switch (result) {
      case Success():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Position saved successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        if (kDebugMode) {
          print('[ChessBoard] Position saved successfully');
        }
      case Failure(message: final msg):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $msg'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        if (kDebugMode) {
          print('[ChessBoard] Failed to save position: $msg');
        }
    }
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
            print(
              '[ChessBoard] Loaded ${moves.length} source positions with valid moves',
            );
          }

        case Failure(message: final msg):
          if (kDebugMode) {
            print('[ChessBoard] Failed to fetch moves: $msg');
          }
          _validMoves = {};
      }
    });
  }

  Future<void> _onPieceDropped(
    ChessPiece piece,
    ChessPosition targetPosition,
  ) async {
    if (_boardMode != BoardMode.play) {
      setState(() {
        if (dragSourcePosition != null) {
          chessBoard.pieces.remove(dragSourcePosition);
        }
        chessBoard.pieces[targetPosition] = piece;
        dragSourcePosition = null;
      });
      return;
    }

    final fromPosition = dragSourcePosition;
    if (fromPosition == null) return;

    setState(() {
      chessBoard.pieces.remove(fromPosition);
      chessBoard.pieces[targetPosition] = piece;
      dragSourcePosition = null;
      _isLoading = true;
    });

    if (kDebugMode) {
      print(
        '[ChessBoard] Sending move to backend: $fromPosition -> $targetPosition',
      );
    }

    final result = await _repository.makeMove(
      from: fromPosition,
      to: targetPosition,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;

      switch (result) {
        case Success(data: final moveResult):
          chessBoard = moveResult.board;
          _gameOverMessage = moveResult.endGameMessage;

          if (kDebugMode) {
            print('[ChessBoard] Board updated after AI move');
            if (moveResult.endGameMessage != null) {
              print('[ChessBoard] Game over: ${moveResult.endGameMessage}');
            }
          }

          if (moveResult.endGameMessage == null) {
            _fetchValidMoves();
          }

        case Failure(message: final msg):
          if (kDebugMode) {
            print('[ChessBoard] Move failed: $msg');
          }
          _errorMessage = msg;
      }
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

  bool _isGameOver() {
    return _gameOverMessage != null;
  }

  Widget? _buildGameOverOverlay() {
    if (!_isGameOver()) return null;

    return Positioned.fill(
      child: Container(
        color: Colors.black.withAlpha(204),
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(32),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _gameOverMessage!.contains('Player wins')
                        ? Icons.emoji_events
                        : Icons.handshake,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _gameOverMessage!,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _initializeBoard,
                    child: const Text('New Game'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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

    return SingleChildScrollView(
      child: Column(
        children: [
          board(),
          if (_boardMode == BoardMode.play && _gameOverMessage == null)
            turnIndicator(context),

          if (_boardMode == BoardMode.edit) ...[
            const SizedBox(height: 16),
            // Piece spawner for adding pieces to the board
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: PieceSpawnerWidget(
                onPieceDeleted: _onPieceDeletedFromBoard,
              ),
            ),
            const SizedBox(height: 16),
            // Player color selection toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Play as:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 12),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: true,
                      label: Text('Light'),
                      icon: Icon(Icons.light_mode),
                    ),
                    ButtonSegment(
                      value: false,
                      label: Text('Dark'),
                      icon: Icon(Icons.dark_mode),
                    ),
                  ],
                  selected: {_playerIsWhite},
                  onSelectionChanged: (Set<bool> newSelection) {
                    setState(() {
                      _playerIsWhite = newSelection.first;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _saveCurrentPosition,
              icon: const Icon(Icons.save),
              label: const Text('Save Starting Position'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _startGame,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Game'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ],
      ),
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

  Padding turnIndicator(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
                ),
              ),
            ),
          Text(
            _isLoading ? 'Opponent Thinking...' : 'Your Turn',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withAlpha(_isLoading ? 180 : 240),
            ),
          ),
        ],
      ),
    );
  }

  Widget board() {
    return Stack(
      children: [
        Padding(
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
                  isDraggingEnabled: !_isLoading && _gameOverMessage == null,
                  canAcceptPiece: _boardMode == BoardMode.edit
                      ? _canAcceptPieceInEditMode
                      : _canAcceptPieceInPlayMode,
                  isValidMoveTarget: _isValidMoveTarget(position),
                );
              },
            ),
          ),
        ),

        // Game over overlay
        if (_isGameOver()) _buildGameOverOverlay()!,
      ],
    );
  }
}
