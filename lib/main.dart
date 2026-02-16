import 'package:flutter/material.dart';
import 'ui/widgets/api_url_dialog.dart';
import 'ui/widgets/chess_board_widget.dart';
import 'ui/widgets/fen_input_dialog.dart';
import 'ui/widgets/game_drawer.dart';
import 'ui/widgets/saved_positions_dialog.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // GlobalKey allows direct access to ChessBoardWidget's state
    final chessBoardKey = GlobalKey<ChessBoardWidgetState>();

    return MaterialApp(
      title: 'Checkmate TVZ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      home: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Checkmate TVZ'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          drawer: GameDrawer(
            onNewGame: () => chessBoardKey.currentState?.resetGame(),
            onLoadFen: () {
              showDialog<void>(
                context: context,
                builder: (context) => FenInputDialog(
                  onSubmit: (fen) {
                    chessBoardKey.currentState?.loadFromFen(fen);
                  },
                ),
              );
            },
            onLoadSavedPositions: () {
              showDialog<void>(
                context: context,
                builder: (context) => SavedPositionsDialog(
                  onLoadPosition: (fen) {
                    chessBoardKey.currentState?.loadFromFen(fen);
                  },
                ),
              );
            },
            onSetApiUrl: () {
              final currentUrl = chessBoardKey.currentState?.getApiUrl() ?? 'http://localhost:8080';
              showDialog<void>(
                context: context,
                builder: (context) => ApiUrlDialog(
                  currentUrl: currentUrl,
                  onSubmit: (url) {
                    chessBoardKey.currentState?.setApiUrl(url);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('API URL updated to: $url'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          body: ChessBoardWidget(key: chessBoardKey),
        ),
      ),
    );
  }
}
