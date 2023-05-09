import 'dart:math';
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
  List<Location>? whiteKingCheckLocations = [], blackKingCheckLocations = [];
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
          whiteKingCheckLocations = isKingUnderCheck(whiteKing);
          blackKingCheckLocations = isKingUnderCheck(blackKing);
          if (coordinator.currentTurn == PlayerColor.white) {
            coordinator.currentTurn = PlayerColor.black;
            if (blackKingCheckLocations!.isNotEmpty)
              print('Black King in Check');
          } else {
            coordinator.currentTurn = PlayerColor.white;
            if (whiteKingCheckLocations!.isNotEmpty)
              print('White King in Check');
          }
        });
      },
      onWillAccept: (piece) {
        if (piece == null) return false;
        if (coordinator.currentTurn != piece.pieceColor) return false;
        if (coordinator.currentTurn == PlayerColor.white &&
            whiteKingCheckLocations!.isNotEmpty) {
          //resolve double check
          if (piece != whiteKing) {
            if (whiteKingCheckLocations!.length > 1) {
              return false;
            }
            Location checkLocation = whiteKingCheckLocations![0];
            bool checkBlock = false;
            List<Location>? checkPath = pathBetweenKingAndPiece(whiteKing,
                coordinator.pieceOfTile(checkLocation.x, checkLocation.y));
            print(coordinator.pieceOfTile(checkLocation.x, checkLocation.y));
            if (checkPath!.isNotEmpty) {
              print('checking path');
              for (int i = 0; i < checkPath.length && !checkBlock; i++) {
                print('${checkPath[i].x}, ${checkPath[i].y}');
                // checkBlock = checkBlock ||
                //     piece.canMoveTo(
                //         checkPath[i].x, checkPath[i].y, coordinator.pieces);
                if (piece.canMoveTo(
                    checkPath[i].x, checkPath[i].y, coordinator.pieces)) {
                  bool ans = checkPath[i] == Location(x, y);
                  if (ans) return true;
                }
              }
              // if (checkBlock) return true;
            }
            bool check = piece.canCapture(
                checkLocation.x, checkLocation.y, coordinator.pieces);
            if (!check) {
              // piece cannot capture at that location
              print("piece cannot capture at that location");
              return false;
            }
            // case where check path can be blocked
            return false;
          } else {
            //king moves
            // -> move => pieces of other color are not attacking the square
            // -> capture => pieces of other color not on that square not protecting
            return (whiteKing.canMoveTo(x, y, coordinator.pieces) ||
                    whiteKing.canCapture(x, y, coordinator.pieces)) &&
                canKingCaptureOrMove(x, y, whiteKing);
          }
          // add how the king moves in check and doubleCheck
        } else if (coordinator.currentTurn == PlayerColor.black &&
            blackKingCheckLocations!.isNotEmpty) {
          //resolve double check
          if (piece != blackKing) {
            if (blackKingCheckLocations!.length > 1) {
              return false;
            }
            Location checkLocation = blackKingCheckLocations![0];
            bool checkBlock = false;
            List<Location>? checkPath = pathBetweenKingAndPiece(blackKing,
                coordinator.pieceOfTile(checkLocation.x, checkLocation.y));
            print(coordinator.pieceOfTile(checkLocation.x, checkLocation.y));
            if (checkPath!.isNotEmpty) {
              print('checking path');
              for (int i = 0; i < checkPath.length && !checkBlock; i++) {
                print('${checkPath[i].x}, ${checkPath[i].y}');
                if (piece.canMoveTo(
                    checkPath[i].x, checkPath[i].y, coordinator.pieces)) {
                  bool ans = checkPath[i] == Location(x, y); 
                  if(ans) return true; 
                }
              }
              // if (checkBlock) return true;
            }
            bool check = piece.canCapture(
                checkLocation.x, checkLocation.y, coordinator.pieces);
            if (!check) {
              // piece cannot capture at that location
              print("piece cannot capture at that location");
              return false;
            }
            // case where check path can be blocked
            return false;
          } else {
            //king moves
            // -> move => pieces of other color are not attacking the square
            // -> capture => pieces of other color not on that square not protecting
            return (blackKing.canMoveTo(x, y, coordinator.pieces) ||
                    blackKing.canCapture(x, y, coordinator.pieces)) &&
                canKingCaptureOrMove(x, y, blackKing);
          }
          // add how the king moves in check and doubleCheck
        }

        if (piece == whiteKing) {
          //king moves
          // -> move => pieces of other color are not attacking the square
          // -> capture => pieces of other color not on that square not protecting
          return (whiteKing.canMoveTo(x, y, coordinator.pieces) ||
                  whiteKing.canCapture(x, y, coordinator.pieces)) &&
              canKingCaptureOrMove(x, y, whiteKing);
        }

        if (piece == blackKing) {
          //king moves
          // -> move => pieces of other color are not attacking the square
          // -> capture => pieces of other color not on that square not protecting
          return (blackKing.canMoveTo(x, y, coordinator.pieces) ||
                  blackKing.canCapture(x, y, coordinator.pieces)) &&
              canKingCaptureOrMove(x, y, blackKing);
        }

        bool canMoveTo = piece.canMoveTo(x, y, pieces);
        bool canCapture = piece.canCapture(x, y, pieces);

        bool ans = canMoveTo || canCapture;
        print(
            "${ans ? "can move " : "cannot move"} ${piece.pieceColor.toString()} ${piece.name} to ($x, $y)");
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

  List<Location>? pathBetweenKingAndPiece(
      ChessPiece king, ChessPiece? attackingPiece) {
    List<Location>? ans = [];
    if (attackingPiece!.name == "knight") {
      return ans;
    }

    int dx = attackingPiece.location.x - king.location.x;
    int dy = attackingPiece.location.y - king.location.y;

    if (dx == 0 || dy == 0) {
      if (dy == 0) {
        int stRow = min(attackingPiece.location.x, king.location.x) + 1;
        int enRow = max(attackingPiece.location.x, king.location.x);
        List<Location>? blockableSquares = [];
        while (stRow < enRow) {
          blockableSquares.add(Location(stRow, king.location.y));
          stRow++;
        }
        return ans;
      } else {
        int stCol = min(attackingPiece.location.y, king.location.y) + 1;
        int enCol = max(attackingPiece.location.y, king.location.y);
        List<Location>? blockableSquares = [];
        while (stCol < enCol) {
          blockableSquares.add(Location(king.location.x, stCol));
          stCol++;
        }
        return ans;
      }
    }
    List<Location>? blockableSquares = [];
    int st_row = attackingPiece.location.x;
    int st_col = attackingPiece.location.y;
    while (st_row != king.location.x) {
      if (st_row < king.location.x) {
        st_row++;
      } else {
        st_row--;
      }
      if (st_col < king.location.y) {
        st_col++;
      } else {
        st_col--;
      }
      if (st_row != king.location.x)
        blockableSquares.add(Location(st_row, st_col));
    }
    return blockableSquares;
    // return ans;
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
              pieces[i].canMoveTo(x, y, pieces)) &&
          coordinator.pieceOfTile(x, y) != pieces[i]) {
        print(pieces[i]);
        return false;
      }
    }
    return true;
  }
}
