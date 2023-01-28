import "chess_piece.dart";

class Bishop extends ChessPiece {
  Bishop(PlayerColor playerColor, Location location)
      : super(playerColor, location);

  @override
  String get name => "bishop";

  @override
  List<Location?> legalMoves(List<ChessPiece> others) {
    final locations = [
      ..._generateMovesOnDiagonal(true, true, others),
      ..._generateMovesOnDiagonal(false, true, others),
      ..._generateMovesOnDiagonal(false, false, others),
      ..._generateMovesOnDiagonal(true, false, others)
    ].toList();

    return locations;
  }

  @override
  List<Location?> legalCaptures(List<ChessPiece> others) {
    final locations = [
      ..._generateCapturesOnDiagonal(true, true, others),
      ..._generateCapturesOnDiagonal(false, true, others),
      ..._generateCapturesOnDiagonal(false, false, others),
      ..._generateCapturesOnDiagonal(true, false, others)
    ].toList();

    return locations;
  }

  List<Location?> _generateMovesOnDiagonal(
      bool isUp, bool isRight, List<ChessPiece> others) {
    bool obstructed = false;
    return List<Location?>.generate(8, (index) {
      if (obstructed) return null; 
      int dy = (isUp ? 1 : -1) * index;
      int dx = (isRight ? 1 : -1) * index;

      final newPos = Location(x + dx, y + dy);
      final pieceOnLocation = others.any((piece) => piece.location == newPos);

      if (pieceOnLocation && location != newPos) obstructed = true;
      return obstructed ? null : newPos;
    }).whereType<Location>().where((location) => location.isValid).toList();
  }

  List<Location?> _generateCapturesOnDiagonal(
      bool isUp, bool isRight, List<ChessPiece> allPieces) {
    bool hasFoundCapture = false;
    return List<Location?>.generate(8, (index) {
      if (hasFoundCapture) return null;
      int dy = (isUp ? 1 : -1) * index;
      int dx = (isRight ? 1 : -1) * index;

      final newPos = Location(x + dx, y + dy);
      final pieceOnLocation = allPieces.any((piece) => piece.location == newPos && piece.pieceColor != pieceColor);

      if (pieceOnLocation && location != newPos) {
        hasFoundCapture = true;
        return newPos;
      }
    }).whereType<Location>().where((location) => location.isValid).toList();
  }
}
