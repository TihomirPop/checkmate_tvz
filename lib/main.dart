import 'package:flutter/material.dart';
import 'ui/widgets/chess_board_widget.dart';
import 'ui/widgets/game_drawer.dart';

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
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Checkmate TVZ'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        drawer: GameDrawer(
          onNewGame: () => chessBoardKey.currentState?.resetGame(),
        ),
        body: ChessBoardWidget(key: chessBoardKey),
      ),
    );
  }
}
