import 'package:chess_app_1/pieces/bishop.dart';
import 'package:collection/collection.dart';
import 'pieces/chess_piece.dart';
import 'package:chess_app_1/pieces/knight.dart';
import 'package:chess_app_1/pieces/rook.dart';
import 'package:chess_app_1/pieces/queen.dart';
import 'package:chess_app_1/pieces/king.dart';
import 'package:chess_app_1/pieces/pawn.dart';

class GameCoordinator {
  final List<ChessPiece> pieces;

  late PlayerColor currentTurn = PlayerColor.white;
  GameCoordinator(this.pieces);

  ChessPiece? pieceOfTile(int x, int y) =>
      pieces.firstWhereOrNull((p) => p.x == x && p.y == y);

  factory GameCoordinator.newGame() {
    return GameCoordinator([
      Bishop(PlayerColor.white, Location(2, 0)),
      Bishop(PlayerColor.white, Location(5, 0)),
      Bishop(PlayerColor.black, Location(2, 7)),
      Bishop(PlayerColor.black, Location(5, 7)),
      Knight(PlayerColor.white, Location(1, 0)),
      Knight(PlayerColor.white, Location(6, 0)),
      Knight(PlayerColor.black, Location(1, 7)),
      Knight(PlayerColor.black, Location(6, 7)),
      Rook(PlayerColor.white, Location(0, 0)),
      Rook(PlayerColor.white, Location(7, 0)),
      Rook(PlayerColor.black, Location(0, 7)),
      Rook(PlayerColor.black, Location(7, 7)),
      Queen(PlayerColor.white, Location(3, 0)),
      Queen(PlayerColor.black, Location(3, 7)),
      King(PlayerColor.white, Location(4, 0)),
      King(PlayerColor.black, Location(4, 7)),
      Pawn(PlayerColor.white, Location(0,1)),
      Pawn(PlayerColor.white, Location(0, 1)),
      Pawn(PlayerColor.white, Location(1, 1)),
      Pawn(PlayerColor.white, Location(2, 1)),
      Pawn(PlayerColor.white, Location(3, 1)),
      Pawn(PlayerColor.white, Location(4, 1)),
      Pawn(PlayerColor.white, Location(5, 1)),
      Pawn(PlayerColor.white, Location(6, 1)),
      Pawn(PlayerColor.white, Location(7, 1)),
      Pawn(PlayerColor.black, Location(0, 6)),
      Pawn(PlayerColor.black, Location(1, 6)),
      Pawn(PlayerColor.black, Location(2, 6)),
      Pawn(PlayerColor.black, Location(3, 6)),
      Pawn(PlayerColor.black, Location(4, 6)),
      Pawn(PlayerColor.black, Location(5, 6)),
      Pawn(PlayerColor.black, Location(6, 6)),
      Pawn(PlayerColor.black, Location(7, 6)),
    ]);
  }

}
