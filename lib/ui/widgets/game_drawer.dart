import 'package:flutter/material.dart';

/// Navigation drawer for the chess application.
///
/// Provides consistent access to game controls regardless of current game state.
/// Currently includes:
/// - New Game: Resets the board to Edit Mode
///
/// Designed to be extensible for future features (settings, history, etc.)
class GameDrawer extends StatelessWidget {
  /// Callback invoked when user taps "New Game"
  final VoidCallback? onNewGame;

  const GameDrawer({super.key, this.onNewGame});

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
          const Divider(),
          // Future features can be added here:
          // - Settings
          // - Game History
          // - About/Help
        ],
      ),
    );
  }
}
