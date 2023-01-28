import 'package:chess_app_1/pieces/bishop.dart';
import 'package:collection/collection.dart';
import 'pieces/chess_piece.dart';

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
      Bishop(PlayerColor.black, Location(5, 7))
    ]);
  }
}
