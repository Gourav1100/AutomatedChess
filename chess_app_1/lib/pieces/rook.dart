import "chess_piece.dart";

class Rook extends ChessPiece {
  Rook(PlayerColor playerColor, Location location)
      : super(playerColor, location);

  @override
  String get name => "rook";

  @override
  List<Location?> legalMoves(List<ChessPiece> others) {
    final locations = [
      ..._generateRookMoves(false, false, others), 
      ..._generateRookMoves(false, true, others),
      ..._generateRookMoves(true, false, others),
      ..._generateRookMoves(true, true, others), 
    ].toList();

    return locations;
  }

  @override
  List<Location?> legalCaptures(List<ChessPiece> others) {
    final locations = [
      ..._generateRookCaptures(false, false, others),
      ..._generateRookCaptures(false, true, others),
      ..._generateRookCaptures(true, false, others),
      ..._generateRookCaptures(true, true, others),
    ].toList();

    return locations;
  }

  List<Location?> _generateRookMoves(
      bool isUp, bool isPositive, List<ChessPiece> others) {
    bool obstructed = false;
    return List<Location?>.generate(8, (index) {
      if (obstructed) return null;
      int dy = 0, dx = 0;
      if (isUp) {
        dy = index;
      } else {
        dx = index;
      }
      if (!isPositive) {
        dy = dy * -1;
        dx = dx * -1;
      }
      final newPos = Location(x + dx, y + dy);
      final pieceOnLocation = others.any((piece) => piece.location == newPos);

      if (pieceOnLocation && location != newPos) obstructed = true;
      return obstructed ? null : newPos;
    }).whereType<Location>().where((location) => location.isValid).toList();
  }

  List<Location?> _generateRookCaptures(
      bool isUp, bool isPositive, List<ChessPiece> allPieces) {
    bool hasFoundCapture = false;
    return List<Location?>.generate(8, (index) {
      if (hasFoundCapture) return null;
    int dy = 0, dx = 0;
      if (isUp) {
        dy = index;
      } else {
        dx = index;
      }
      if (!isPositive) {
        dy = dy * -1;
        dx = dx * -1;
      }

      final newPos = Location(x + dx, y + dy);
      final pieceOnLocation = allPieces.any((piece) =>
          piece.location == newPos && piece.pieceColor != pieceColor);

      if (pieceOnLocation && location != newPos) {
        hasFoundCapture = true;
        return newPos;
      }
    }).whereType<Location>().where((location) => location.isValid).toList();
  }
}
