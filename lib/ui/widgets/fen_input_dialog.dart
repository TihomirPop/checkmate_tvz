import 'package:flutter/material.dart';

/// Dialog for inputting FEN (Forsyth-Edwards Notation) strings
/// to load custom chess positions onto the board.
///
/// Features:
/// - Multi-line text field for long FEN strings
/// - Hint text showing example FEN
/// - Basic validation (non-empty)
/// - Cancel/Load actions
class FenInputDialog extends StatefulWidget {
  final void Function(String fen) onSubmit;

  const FenInputDialog({super.key, required this.onSubmit});

  @override
  State<FenInputDialog> createState() => _FenInputDialogState();
}

class _FenInputDialogState extends State<FenInputDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Load from FEN'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'FEN String',
          hintText: 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
          border: OutlineInputBorder(),
        ),
        maxLines: 3,
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final fen = _controller.text.trim();
            if (fen.isNotEmpty) {
              Navigator.pop(context);
              widget.onSubmit(fen);
            }
          },
          child: const Text('Load'),
        ),
      ],
    );
  }
}
