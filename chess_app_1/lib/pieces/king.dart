import 'package:collection/collection.dart';
import "chess_piece.dart";

class King extends ChessPiece {
  King(PlayerColor playerColor, Location location)
      : super(playerColor, location);

  @override
  String get name => "king";

  final List<Location> _possibleMoves = [
    Location(1, 0),
    Location(0, -1),
    Location(0, 1),
    Location(-1, 0),
    Location(1, 1),
    Location(1, -1),
    Location(-1, 1),
    Location(-1, -1),
  ];


  @override
  List<Location?> legalMoves(List<ChessPiece> otherPieces) {
    List<Location?> movesAllowed = _generateLegalMoves(x, y, otherPieces);
    return movesAllowed;
  }

  @override
  List<Location?> legalCaptures(List<ChessPiece> otherPieces) {
    return _generateCaptures(x, y, otherPieces);
  }

  List<Location?> _generateCaptures(
      int x, int y, List<ChessPiece> otherPieces) {
    // only those moves where black piece present
    return List<Location?>.generate(8, (index) {
      Location newPos =
          Location(x + _possibleMoves[index].x, y + _possibleMoves[index].y);
      ChessPiece? pieceAvailable = otherPieces.firstWhereOrNull((p) =>
          p.x == newPos.x && p.y == newPos.y && p.pieceColor != pieceColor);
      return pieceAvailable != null ? newPos : null;
    });
  }

  List<Location?> _generateLegalMoves(
      int x, int y, List<ChessPiece> otherPieces) {
    return List<Location?>.generate(8, (index) {
      Location newPos =
          Location(x + _possibleMoves[index].x, y + _possibleMoves[index].y);
      ChessPiece? pieceAvailable = otherPieces.firstWhereOrNull((p) {
        return p.x == newPos.x && p.y == newPos.y;
      });
      return pieceAvailable == null ? newPos : null;
    });
  }
}
