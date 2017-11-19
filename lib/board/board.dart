import 'package:flutter/material.dart';
import 'package:gomoku/board/board_content.dart';
import 'package:gomoku/board/board_painter.dart';
import 'package:gomoku/utils/pair.dart';

typedef MoveNotificationFunction(GomokuSymbol actor);
typedef EndNotificationFunction(GomokuSymbol actor);
typedef NewGameNotificationFunction();

class Board extends StatefulWidget {
  final MoveNotificationFunction _onMovePlayed;
  final EndNotificationFunction _onGameEnd;
  final BoardContent _boardContent;
  final NewGameNotificationFunction _onNewGame;
  final GomokuSymbol _symbolToPlay;

  Board(this._boardContent, this._symbolToPlay, this._onMovePlayed, this._onGameEnd, this._onNewGame);

  @override
  BoardState createState() => new BoardState();
}

class BoardState extends State<Board> {
  final GlobalKey _paintKey = new GlobalKey();

  BoardPainter _boardPainter;

  @override
  void initState() {
    super.initState();
    _boardPainter = new BoardPainter(widget._boardContent);
  }

  @override
  Widget build(BuildContext context) {
    return new AspectRatio(
      aspectRatio: 1.0,
      child: new GestureDetector(
        onTapUp: (TapUpDetails details) => _onTapUp(context, details),
        child: new CustomPaint(
          key: _paintKey,
          painter: _boardPainter,
        ),
      ),
    );
  }

  void _onTapUp(BuildContext context, TapUpDetails details) {
    if (widget._boardContent.gameState != GameStatus.IN_PROGRESS) {
      _newGameRequest(context);
    } else {
      RenderBox renderBox = _paintKey.currentContext.findRenderObject();
      Offset localPosition = renderBox.globalToLocal(details.globalPosition);

      Pair<int, int> rowColumn = _boardPainter.computeRowColumn(localPosition.dx, localPosition.dy);
      if (rowColumn != null) _playMove(context, rowColumn.first, rowColumn.last);
    }
  }

  void _playMove(BuildContext context, int row, int column) {
    GomokuSymbol actorSymbol = widget._symbolToPlay;

    if (widget._boardContent.get(row, column) != null) return;
    widget._boardContent.placeSymbol(row, column, actorSymbol);
    _boardPainter.contentChanged();

    if (widget._boardContent.gameState != GameStatus.IN_PROGRESS) {
      widget._onGameEnd(actorSymbol);
    }
    widget._onMovePlayed(actorSymbol);
  }

  void _newGameRequest(BuildContext context) {
    showDialog<bool>(context: context, child: new NewGameDialog(), barrierDismissible: true).then((bool wantNewGame) {
      if (wantNewGame != null && wantNewGame) {
        widget._onNewGame();
        _boardPainter.contentChanged();
      }
    });
  }
}

class NewGameDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      title: new Text('Play again?'),
      actions: <Widget>[
        new FlatButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: new Text('Cancel'),
        ),
        new FlatButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: new Text('Play'),
        ),
      ],
    );
  }
}
