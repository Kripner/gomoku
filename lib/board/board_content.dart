import 'dart:math';

import 'package:gomoku/board/board_painter.dart';

enum GomokuSymbol { CROSS, NODE }

GomokuSymbol otherSymbol(GomokuSymbol symbol) {
  return symbol == GomokuSymbol.CROSS ? GomokuSymbol.NODE : GomokuSymbol.CROSS;
}

enum GameStatus { IN_PROGRESS, WON, DRAWN, LOST_ON_TIME, TERMINATED }

final Map<GameStatus, List<String>> statusToMessages = {
  GameStatus.WON: ["You won!", "You lost!"],
  GameStatus.DRAWN: ["Its a draw!", "Its a draw!"],
  GameStatus.LOST_ON_TIME: ["You lost on time!", "You won on time!"]
};

class WinInfo {
  final RowColumn fromPosition;
  final RowColumn toPosition;
  final GomokuSymbol symbol;

  WinInfo(this.fromPosition, this.toPosition, this.symbol);
}

class RowColumn {
  final int column;
  final int row;

  RowColumn(this.row, this.column);

  RowColumn plus({int row = 0, int column = 0}) {
    return new RowColumn(this.row + row, this.column + column);
  }

  int distance(RowColumn other) {
    return max((column - other.column).abs(), (row - other.row).abs());
  }
}

class BoardContent {
  static final int symbolsForWin = 5;

  final int _numOfUnits;

  List<List<GomokuSymbol>> _boardContent;
  List<WinInfo> wins;
  GameStatus gameState;

  BoardContent.empty(this._numOfUnits) {
    _boardContent = new List<List<GomokuSymbol>>(_numOfUnits);
    reset();
  }

  void placeSymbol(int row, int column, GomokuSymbol symbol) {
    if (gameState != GameStatus.IN_PROGRESS) throw new Exception("Illegal game state");
    _boardContent[row][column] = symbol;
    var position = new RowColumn(row, column);
    wins = _checkWins(position, symbol);
    if (wins.length > 0)
      gameState = GameStatus.WON;
    else if (_checkDraw(position)) gameState = GameStatus.DRAWN;
  }

  List<WinInfo> _checkWins(RowColumn position, GomokuSymbol newSymbol) {
    List<WinInfo> wins = [];
    var bases = [
      [0, -1],
      [1, -1],
      [1, 0],
      [1, 1]
    ];

    for (var base in bases) {
      int dRow = base[0], dColumn = base[1];
      RowColumn from = position, to = position;
      RowColumn tmp = position;
      while (inRange(tmp) && getFromPosition(tmp) == newSymbol) {
        from = tmp;
        tmp = tmp.plus(row: dRow, column: dColumn);
      }
      tmp = position;
      while (inRange(tmp) && getFromPosition(tmp) == newSymbol) {
        to = tmp;
        tmp = tmp.plus(row: -dRow, column: -dColumn);
      }
      if (from.distance(to) + 1 >= symbolsForWin) {
        wins.add(new WinInfo(from, to, newSymbol));
      }
    }
    return wins;
  }

  bool _checkDraw(RowColumn position) {
    // TODO
    return numOfSymbols() == _numOfUnits * _numOfUnits;
  }

  bool inRange(RowColumn position) {
    return position.row >= 0 &&
        position.row < BoardPainter.numOfCells &&
        position.column >= 0 &&
        position.column < BoardPainter.numOfCells;
  }

  GomokuSymbol get(int row, int column) {
    return _boardContent[row][column];
  }

  GomokuSymbol getFromPosition(RowColumn position) {
    return get(position.row, position.column);
  }

  void reset() {
    for (int i = 0; i < _numOfUnits; ++i) {
      _boardContent[i] = new List<GomokuSymbol>(_numOfUnits);
      for (int j = 0; j < _numOfUnits; ++j) {
        _boardContent[i][j] = null;
      }
    }
    gameState = GameStatus.IN_PROGRESS;
    wins = null;
  }

  bool same(BoardContent other) {
    if (other._numOfUnits != _numOfUnits) return false;
    for (int i = 0; i < _numOfUnits; ++i) {
      for (int j = 0; j < _numOfUnits; ++j) {
        if (_boardContent[i][j] != other._boardContent[i][j]) return false;
      }
    }
    return true;
  }

  // for debugging only
  int numOfSymbols() {
    return _boardContent
        .map((row) => row.fold(0, (previous, element) => previous + (element == null ? 0 : 1)))
        .fold(0, (previous, element) => (previous + element).toInt());
  }
}
