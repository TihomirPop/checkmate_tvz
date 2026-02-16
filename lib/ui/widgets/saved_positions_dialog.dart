import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:checkmate_tvz/data/repositories/chess_game_repository.dart';
import 'package:checkmate_tvz/data/result/result.dart';

/// Dialog for displaying and managing saved chess positions.
///
/// Features:
/// - Displays scrollable list of saved FEN positions
/// - Load a position by tapping it
/// - Delete positions with confirmation dialog
/// - Shows empty state when no positions exist
/// - Handles loading and error states
class SavedPositionsDialog extends StatefulWidget {
  /// Callback invoked when user selects a position to load
  final void Function(String fen) onLoadPosition;

  const SavedPositionsDialog({
    super.key,
    required this.onLoadPosition,
  });

  @override
  State<SavedPositionsDialog> createState() => _SavedPositionsDialogState();
}

class _SavedPositionsDialogState extends State<SavedPositionsDialog> {
  late final ChessGameRepository _repository;
  bool _isLoading = true;
  List<String> _positions = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _repository = ChessGameRepository();
    _loadPositions();
  }

  /// Loads all saved positions from repository
  Future<void> _loadPositions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _repository.getSavedPositions();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      switch (result) {
        case Success(data: final positions):
          _positions = positions;
          _errorMessage = null;
          if (kDebugMode) {
            print('[SavedPositionsDialog] Loaded ${positions.length} positions');
          }
        case Failure(message: final msg):
          _errorMessage = msg;
          _positions = [];
          if (kDebugMode) {
            print('[SavedPositionsDialog] Failed to load positions: $msg');
          }
      }
    });
  }

  /// Deletes a position after showing confirmation dialog
  Future<void> _deletePosition(int index, String fen) async {
    final confirmed = await _showDeleteConfirmation(index, fen);
    if (!confirmed) return;

    final result = await _repository.deletePosition(index);

    if (!mounted) return;

    switch (result) {
      case Success():
        if (kDebugMode) {
          print('[SavedPositionsDialog] Deleted position at index $index');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Position deleted'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        _loadPositions(); // Refresh the list
      case Failure(message: final msg):
        if (kDebugMode) {
          print('[SavedPositionsDialog] Failed to delete position: $msg');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete position: $msg'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
    }
  }

  /// Shows confirmation dialog before deleting a position
  /// Returns true if user confirms deletion
  Future<bool> _showDeleteConfirmation(int index, String fen) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Position?'),
        content: Text(
          'Are you sure you want to delete this position?\n\n',
          style: const TextStyle(fontFamily: 'monospace'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Saved Positions'),
      content: SizedBox(
        width: double.maxFinite,
        child: _buildContent(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadPositions,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_positions.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bookmark_border,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'No saved positions yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Save a position from the board to see it here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 400),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _positions.length,
        itemBuilder: (context, index) {
          final fen = _positions[index];
          return ListTile(
            leading: const Icon(Icons.grid_on),
            title: Text(fen),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _deletePosition(index, fen),
              tooltip: 'Delete position',
            ),
            onTap: () {
              // Close dialog and load position
              Navigator.pop(context);
              widget.onLoadPosition(fen);
              if (kDebugMode) {
                print('[SavedPositionsDialog] Loading position: $fen');
              }
            },
          );
        },
      ),
    );
  }
}
