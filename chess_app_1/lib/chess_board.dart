import 'package:chess_app_1/game_coordinator.dart';
import 'package:chess_app_1/pieces/chess_piece.dart';
import "package:flutter/material.dart";
import 'package:collection/collection.dart';
import 'package:chess_app_1/pieces/chess_piece.dart';

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

  late final ChessPiece whiteKing = coordinator.pieces.firstWhere(
      (piece) => piece.name == "king" && piece.pieceColor == PlayerColor.white);
  late final ChessPiece blackKing = coordinator.pieces.firstWhere(
      (piece) => piece.name == "king" && piece.pieceColor == PlayerColor.black);

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
          } else {
            coordinator.currentTurn = PlayerColor.white;
          }
        });
      },
      onWillAccept: (piece) {
        if (piece == null) return false;
        if (coordinator.currentTurn != piece.pieceColor) return false;

        List<Location>? whiteKingCheckLocations = isKingUnderCheck(whiteKing);
        List<Location>? blackKingCheckLocations = isKingUnderCheck(blackKing);

        if (coordinator.currentTurn == PlayerColor.white &&
            whiteKingCheckLocations!.isNotEmpty) {
          //resolve double check
          if (piece != whiteKing) {
            if (whiteKingCheckLocations.length > 1) {
              return false;
            }
            Location checkLocation = whiteKingCheckLocations[0];
            bool check = piece.canCapture(
                checkLocation.x, checkLocation.y, coordinator.pieces);
            if (!check) {
              // piece cannot capture at that location
              // print("piece cannot capture at that location");
              return false;
            }
            return checkLocation == Location(x, y);
          } else {
            //king moves
            // -> move => pieces of other color are not attacking the square
            // -> capture => pieces of other color not on that square not protecting
            return (whiteKing.canMoveTo(x, y, coordinator.pieces) ||
                    whiteKing.canMoveTo(x, y, coordinator.pieces)) &&
                canKingCaptureOrMove(x, y, whiteKing);
          }
          // add how the king moves in check and doubleCheck
        } else if (coordinator.currentTurn == PlayerColor.black &&
            blackKingCheckLocations!.isNotEmpty) {
          //resolve double check
          if (piece != blackKing) {
            if (blackKingCheckLocations.length > 1) {
              return false;
            }
            Location checkLocation = blackKingCheckLocations[0];
            bool check = piece.canCapture(
                checkLocation.x, checkLocation.y, coordinator.pieces);
            if (!check) {
              // piece cannot capture at that location
              // print("piece cannot capture at that location");
              return false;
            }
            return checkLocation == Location(x, y);
          } else {
            //king moves
            // -> move => pieces of other color are not attacking the square
            // -> capture => pieces of other color not on that square not protecting
            return (blackKing.canMoveTo(x, y, coordinator.pieces) ||
                    blackKing.canMoveTo(x, y, coordinator.pieces)) &&
                canKingCaptureOrMove(x, y, blackKing);
          }
          // add how the king moves in check and doubleCheck
        }

        if(piece==whiteKing) {
          //king moves
          // -> move => pieces of other color are not attacking the square
          // -> capture => pieces of other color not on that square not protecting
          return (whiteKing.canMoveTo(x, y, coordinator.pieces) ||
                  whiteKing.canMoveTo(x, y, coordinator.pieces)) &&
              canKingCaptureOrMove(x, y, whiteKing);
        }

        if (piece == blackKing) {
          //king moves
          // -> move => pieces of other color are not attacking the square
          // -> capture => pieces of other color not on that square not protecting
          return (blackKing.canMoveTo(x, y, coordinator.pieces) ||
                  blackKing.canMoveTo(x, y, coordinator.pieces)) &&
              canKingCaptureOrMove(x, y, blackKing);
        }

        bool canMoveTo = piece.canMoveTo(x, y, pieces);
        bool canCapture = piece.canCapture(x, y, pieces);

        // bool ans = canMoveTo || canCapture;
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
          // print('coordinates are $x and $y');
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
    return null;
  }

  List<Location>? isKingUnderCheck(
    ChessPiece king,
  ) {
    // to check if king under check or not
    // check all pieces of opposite color
    List<ChessPiece>? piecesCheckingKing = [];
    for (int i = 0; i < coordinator.pieces.length; i++) {
      ChessPiece piece = coordinator.pieces[i];
      if (piece.pieceColor != king.pieceColor &&
          (piece.canCapture(
                  king.location.x, king.location.y, coordinator.pieces) ||
              piece.canMoveTo(
                  king.location.x, king.location.y, coordinator.pieces))) {
        piecesCheckingKing.add(piece);
      }
    }
    List<Location>? locationsOfCheckingPieces = [];
    for (int i = 0; i < piecesCheckingKing.length; i++) {
      locationsOfCheckingPieces.add(piecesCheckingKing[i].location);
    }
    return locationsOfCheckingPieces;
  }

  bool canKingCaptureOrMove(
    int x,
    int y,
    ChessPiece king,
  ) {
    List<ChessPiece> pieces = coordinator.pieces;
    for (int i = 0; i < pieces.length; i++) {
      if (pieces[i].pieceColor != king.pieceColor &&
          (pieces[i].canCapture(x, y, pieces) ||
              pieces[i].canMoveTo(x, y, pieces))) {
        return false;
      }
    }
    return true;
  }
}
