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
    List<Location?> possibleCaptures = List<Location?>.generate(8, (index) {
      Location newPos =
          Location(x + _possibleMoves[index].x, y + _possibleMoves[index].y);
      ChessPiece? pieceAvailable = otherPieces.firstWhereOrNull((p) =>
          p.x == newPos.x && p.y == newPos.y && p.pieceColor != pieceColor);
      return pieceAvailable != null ? newPos : null;
    });
    possibleCaptures.removeWhere((locations) => isUnderCheckAt(locations?.x, locations?.y, otherPieces).isNotEmpty);
    return possibleCaptures; 
  }

  List<Location?> _generateLegalMoves(
      int x, int y, List<ChessPiece> otherPieces
  ){
    List<Location?> possibleMoves = List<Location?>.generate(8, (index) {
      Location newPos =
          Location(x + _possibleMoves[index].x, y + _possibleMoves[index].y);
      ChessPiece? pieceAvailable = otherPieces.firstWhereOrNull((p) {
        return p.x == newPos.x && p.y == newPos.y;
      });
      return pieceAvailable == null ? newPos : null;
    });
    possibleMoves.removeWhere((locations) =>
        isUnderCheckAt(locations?.x, locations?.y, otherPieces).isNotEmpty);
    return possibleMoves;
  }

  List<Location?> isUnderCheckAt(int? x, int? y, List<ChessPiece> otherPieces) {
    return [
      ...isPawnCheck(x, y, otherPieces),
      ...isKnightCheck(x, y, otherPieces)
    ].toList();
  }

  List<Location?> isPawnCheck(int? x, int? y, List<ChessPiece> otherPieces) {
    if (x == null || y == null) return [];
    List<Location?> pawnChecks = [];
    for (int i = 0; i < otherPieces.length; i++) {
      if (otherPieces[i].name == "pawn" &&
          pieceColor != otherPieces[i].pieceColor) {
        int dx = otherPieces[i].location.x - x;
        int dy = otherPieces[i].location.y - y;

        if (pieceColor == PlayerColor.white && dx.abs() == 1 && dy == 1) {
          pawnChecks.add(otherPieces[i].location);
        } else if (pieceColor == PlayerColor.black &&
            dx.abs() == 1 &&
            dy == -1) {
          pawnChecks.add(otherPieces[i].location);
        }
      }
    }
    return pawnChecks;
  }

  List<Location?> isKnightCheck(int? x, int? y, List<ChessPiece> otherPieces) {
    if (x == null || y == null) return [];
    List<Location?> knightChecks = [];
    for (int i = 0; i < otherPieces.length; i++) {
      if (otherPieces[i].name == "pawn" &&
          pieceColor != otherPieces[i].pieceColor) {
        int dx = otherPieces[i].location.x - x;
        int dy = otherPieces[i].location.y - y;
        if ((dx.abs() == 2 && dy.abs() == 1) ||
            (dx.abs() == 1 && dy.abs() == 2)) {
          knightChecks.add(otherPieces[i].location);
        }
      }
    }
    return knightChecks;
  }
}
