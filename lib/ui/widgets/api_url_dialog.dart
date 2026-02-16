import 'package:flutter/material.dart';

/// Dialog for setting the Chess API base URL.
///
/// Features:
/// - Text field with current URL pre-filled
/// - Default placeholder showing http://localhost:8080
/// - Basic validation (non-empty, starts with http)
/// - Cancel/Save actions
class ApiUrlDialog extends StatefulWidget {
  final String currentUrl;
  final void Function(String url) onSubmit;

  const ApiUrlDialog({
    super.key,
    required this.currentUrl,
    required this.onSubmit,
  });

  @override
  State<ApiUrlDialog> createState() => _ApiUrlDialogState();
}

class _ApiUrlDialogState extends State<ApiUrlDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentUrl);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    final url = _controller.text.trim();

    if (url.isEmpty) {
      setState(() {
        _errorText = 'URL cannot be empty';
      });
      return;
    }

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      setState(() {
        _errorText = 'URL must start with http:// or https://';
      });
      return;
    }

    Navigator.pop(context);
    widget.onSubmit(url);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set API URL'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter the base URL for the Chess Engine API:',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'API URL',
              hintText: 'http://localhost:8080',
              border: const OutlineInputBorder(),
              errorText: _errorText,
            ),
            autofocus: true,
            onChanged: (_) {
              // Clear error when user types
              if (_errorText != null) {
                setState(() {
                  _errorText = null;
                });
              }
            },
            onSubmitted: (_) => _validateAndSubmit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _validateAndSubmit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
