import 'package:flutter/material.dart';

/// Navigation drawer for the chess application.
///
/// Provides consistent access to game controls regardless of current game state.
/// Currently includes:
/// - New Game: Resets the board to Edit Mode
/// - Load from FEN: Loads a custom position from FEN string
/// - Load Saved Position: Loads a previously saved position
/// - Set API URL: Configure the Chess Engine backend URL
///
/// Designed to be extensible for future features (settings, history, etc.)
class GameDrawer extends StatelessWidget {
  /// Callback invoked when user taps "New Game"
  final VoidCallback? onNewGame;

  final VoidCallback? onLoadFen;

  final VoidCallback? onLoadSavedPositions;

  final VoidCallback? onSetApiUrl;

  const GameDrawer({
    super.key,
    this.onNewGame,
    this.onLoadFen,
    this.onLoadSavedPositions,
    this.onSetApiUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.sports_esports,
                  size: 48,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Checkmate TVZ',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('New Game'),
            onTap: () {
              // Close drawer first for smooth UX
              Navigator.pop(context);
              // Then invoke callback if provided
              onNewGame?.call();
            },
          ),
          ListTile(
            leading: const Icon(Icons.input),
            title: const Text('Load from FEN'),
            onTap: () {
              Navigator.pop(context);
              onLoadFen?.call();
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Load Saved Position'),
            onTap: () {
              Navigator.pop(context);
              onLoadSavedPositions?.call();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_ethernet),
            title: const Text('Set API URL'),
            onTap: () {
              Navigator.pop(context);
              onSetApiUrl?.call();
            },
          ),
          // Future features can be added here:
          // - Settings
          // - Game History
          // - About/Help
        ],
      ),
    );
  }
}
