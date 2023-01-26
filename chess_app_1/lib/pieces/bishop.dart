import "chess_piece.dart";

class Bishop extends ChessPiece {
  Bishop(PlayerColor playerColor, Location location)
      : super(playerColor, location);

  @override
  String get name => "bishop";

  @override
  List<Location> legalMoves(List<ChessPiece> others) {
    final bool obstructedUp;
    final locations = [
      ..._generateMovesOnDiagonal(true, true, others),
      ..._generateMovesOnDiagonal(false, true, others),
      ..._generateMovesOnDiagonal(false, false, others),
      ..._generateMovesOnDiagonal(true, false, others)
    ].toList();

    return locations;
  }

  List<Location> _generateMovesOnDiagonal(
      bool isUp, bool isRight, List<ChessPiece> others) {
    bool obstructed = false;
    return List<Location?>.generate(8, (index) {
      int dy = isUp ? 1 : -1;
      int dx = isRight ? 1 : -1;

      final newPos = Location(x + dx, y + dy);
      final pieceOnLocation = others.any((piece) => piece.location == newPos);

      if (pieceOnLocation) obstructed = true;
      return obstructed ? null : newPos; 
    }).whereType<Location>().where((location) => location.isValid).toList();
  }
}
