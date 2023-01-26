import 'package:chess_app_1/pieces/bishop.dart';

import 'pieces/chess_piece.dart';

class GameCoordinator {
  late final List<ChessPiece> whitepieces;
  late final List<ChessPiece> blackpieces;

  List<ChessPiece> get pieces => [
    ...whitepieces, 
    ...blackpieces
  ].toList() ; 

  late PlayerColor currentTurn = PlayerColor.white;

  GameCoordinator(this.whitepieces, this.blackpieces);

  factory GameCoordinator.newGame() {
    return GameCoordinator([

      Bishop(PlayerColor.white, Location(2,0)),
      Bishop(PlayerColor.white, Location(5,0))


    ], [
      Bishop(PlayerColor.black, Location(2, 7)),
      Bishop(PlayerColor.black, Location(5, 7))
    ]);
  }
}
