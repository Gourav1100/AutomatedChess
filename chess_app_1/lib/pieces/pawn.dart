import 'package:collection/collection.dart';
import "chess_piece.dart";

class Pawn extends ChessPiece {
  late final Location initialLocation;

  Pawn(PlayerColor playerColor, Location location)
      : super(playerColor, location) {
    initialLocation = location;
  }

  @override
  String get name => "pawn";
  @override
  List<Location?> legalMoves(List<ChessPiece> otherPieces) {
    return _generatePawnMoves(location == initialLocation, otherPieces);
  }

  @override
  List<Location?> legalCaptures(List<ChessPiece> otherPieces) {
    final locations = [
      ..._generatePawnCaptures(false, otherPieces),
      ..._generatePawnCaptures(true, otherPieces)
    ].toList();
    return locations;
  }

  List<Location?> _generatePawnMoves(bool firstMove, List<ChessPiece> others) {
    bool obstructed = false;
    int n = firstMove ? 2 : 1;
    return List<Location?>.generate(n, (index) {
      if (obstructed) return null;
      int dy = 1 * (index+1);
      if (pieceColor == PlayerColor.black) dy *= -1;
      final newPos = Location(x, y + dy);
      final pieceOnLocation = others.any((piece) => piece.location == newPos);

      if (pieceOnLocation && location != newPos) obstructed = true;
      return obstructed ? null : newPos;
    }).whereType<Location>().where((location) => location.isValid).toList();
  }

  List<Location?> _generatePawnCaptures(bool dir, List<ChessPiece> allPieces) {
    bool hasFoundCapture = false;
    return List<Location?>.generate(1, (index) {
      if (hasFoundCapture) return null;
      int dy = 1;
      int dx = dir ? 1 : -1;
      if (pieceColor == PlayerColor.black) dy *= -1;
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
