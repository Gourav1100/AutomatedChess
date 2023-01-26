import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'chess_board.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {'/': (context) => ChessBoard()},
    );
  }
}

// comment1
