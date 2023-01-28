import 'package:chess_app_1/game_coordinator.dart';
import 'package:chess_app_1/pieces/chess_piece.dart';
import "package:flutter/material.dart";

class ChessBoard extends StatefulWidget {
  const ChessBoard({super.key});

  @override
  State<ChessBoard> createState() => _ChessBoardState();
}

class _ChessBoardState extends State<ChessBoard> {
  @override
  late final double tileSize = MediaQuery.of(context).size.width / 8.0;
  final Color green = const Color.fromRGBO(118, 150, 86, 100);
  final Color lightGreen = const Color.fromRGBO(238, 238, 210, 100);
  final Color blackBackground = const Color.fromRGBO(54, 69, 79, 100);

  final GameCoordinator coordinator = GameCoordinator.newGame();

  List<ChessPiece> get pieces => coordinator.pieces;

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Chess Board")),
        backgroundColor: blackBackground,
        body: buildBoard());
  }

  Color getColor(int x, int y) {
    int value = x;
    if (y.isOdd) {
      value++;
    }
    return value.isEven ? lightGreen : green;
  }

  Column buildBoard() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...List.generate(
            8,
            (y) => Row(
                  children: [...List.generate(8, (x) => buildDragTarget(x, y))],
                )).reversed
      ],
    );
  }

  DragTarget<ChessPiece> buildDragTarget(int x, int y) {
    return DragTarget<ChessPiece>(
      onAccept: (piece) {
        final capturedPiece = coordinator.pieceOfTile(x, y);
        setState(() {
          piece.location = Location(x, y);
          if (capturedPiece != null) {
            // print("$capturedPiece captured!!");
            // removing captured piece
            pieces.remove(capturedPiece);
          }
          if (coordinator.currentTurn == PlayerColor.white) {
            coordinator.currentTurn = PlayerColor.black; 
          }
          else {
            coordinator.currentTurn = PlayerColor.white; 
          }
        });
      },
      onWillAccept: (piece) {
        if (piece == null) return false;
        if(coordinator.currentTurn != piece.pieceColor) return false; 
        bool canMoveTo = piece.canMoveTo(x, y, pieces);
        bool canCapture = piece.canCapture(x, y, pieces);

        bool ans = canMoveTo || canCapture;
        // print("${ans ? "can move " : "cannot move"} ${piece.pieceColor.toString()} ${piece.name} to ($x, $y)");
        return canMoveTo || canCapture;
      },
      builder: (context, data, rejects) => InkWell(
        child: Container(
          width: tileSize,
          height: tileSize,
          decoration: BoxDecoration(
            color: getColor(x, y),
          ),
          child: _buildChessPiece(x, y),
        ),
        onTap: () {
          print('coordinates are $x and $y');
        },
      ),
    );
  }

  Widget? _buildChessPiece(int x, int y) {
    final piece = coordinator.pieceOfTile(x, y);
    if (piece != null) {
      final child = Image.asset(piece.fileName);

      return Draggable<ChessPiece>(
        data: piece,
        feedback: child,
        childWhenDragging: const SizedBox.shrink(),
        child: child,
      );
    }
  }
}
