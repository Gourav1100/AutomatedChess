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
  late final Location location;

  String get name;

  int get x => location.x;
  int get y => location.y; 

  String get fileName => "${pieceColor.toString().split('.').last}_${name}";


  ChessPiece(this.pieceColor, this.location);
  List<Location> legalMoves(List<ChessPiece> otherPieces);
}
