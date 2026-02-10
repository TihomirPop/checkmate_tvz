import 'package:flutter/material.dart';
import 'widgets/chess_board.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
        body: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxSize = constraints.maxWidth < constraints.maxHeight
                  ? constraints.maxWidth
                  : constraints.maxHeight;

              return SizedBox(
                width: maxSize,
                height: maxSize,
                child: const ChessBoard(),
              );
            },
          ),
        ),
      ),
    );
  }
}
