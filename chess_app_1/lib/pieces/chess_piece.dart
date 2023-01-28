enum PlayerColor { black, white }

class Location {
  int x;
  int y;

  Location(this.x, this.y);

  bool get isValid => x <= 7 && y <= 7 && x >= 0 && y >= 0;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  @override
  bool operator ==(Object other) {
    return (other is Location) && (other.x == x && other.y == y);
  }
}

abstract class ChessPiece {
  late final PlayerColor pieceColor;
  Location location;

  String get name;

  int get x => location.x;
  int get y => location.y;

  String get fileName =>
      "assets/${pieceColor.toString().split('.').last}_${name}.png";

  ChessPiece(this.pieceColor, this.location);
  List<Location?> legalMoves(List<ChessPiece> otherPieces);
  List<Location?> legalCaptures(List<ChessPiece> otherPieces);

  bool canMoveTo(int x, int y, List<ChessPiece> others) =>
      legalMoves(others).contains(Location(x, y));

  bool canCapture(int x, int y, List<ChessPiece> others) =>
      legalCaptures(others).contains(Location(x, y));

  @override
  String toString() => "$name($x, $y)";
}
