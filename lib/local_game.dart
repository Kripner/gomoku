import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gomoku/board/board.dart';
import 'package:gomoku/board/board_content.dart';
import 'package:gomoku/board/board_painter.dart';
import 'package:gomoku/time_control.dart';
import 'package:gomoku/utils/utils.dart';

class Player {
  GomokuSymbol symbol;
  Duration timeRemaining;
  bool timeBoxRotated = false;
  bool endActor;

  Player(this.symbol, this.timeRemaining);

  void reset(GomokuSymbol newSymbol, Duration baseTime) {
    endActor = null;
    timeRemaining = baseTime;
    symbol = newSymbol;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Player &&
              runtimeType == other.runtimeType &&
              symbol == other.symbol;

  @override
  int get hashCode => symbol.hashCode;

  @override
  String toString() {
    return 'Player with ${symbol.toString()}es';
  }
}

class LocalGame extends StatefulWidget {
  final Player _firstPlayer;
  final Player _secondPlayer;
  final TimeControl _timeControl;

  LocalGame(this._timeControl)
      : _firstPlayer = new Player(GomokuSymbol.CROSS, _timeControl.baseTime),
        _secondPlayer = new Player(GomokuSymbol.NODE, _timeControl.baseTime);

  @override
  State<StatefulWidget> createState() {
    return new LocalGameState();
  }
}

class LocalGameState extends State<LocalGame> {
  static final Duration _timeControllerSleep = new Duration(milliseconds: 100);

  final BoardContent _boardContent = new BoardContent.empty(BoardPainter.numOfCells);
  Timer _timeController;
  Player _playerToMove;
  Player _lastStartedPlayer;

  @override
  void initState() {
    super.initState();
    _playerToMove = _lastStartedPlayer = widget._firstPlayer;
  }


  @override
  void dispose() {
    _boardContent.gameState = GameStatus.TERMINATED;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          new RotatedBox(
            quarterTurns: 2,
            child: _buildHeader(context, widget._secondPlayer),
          ),
          new AspectRatio(
            aspectRatio: 1.0,
            child: new Board(_boardContent, _playerToMove.symbol, onMovePlayed, onGameEnd, onNewGame),
          ),
          _buildHeader(context, widget._firstPlayer),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Player player) {
    String infoString = _boardContent.gameState == GameStatus.IN_PROGRESS
        ? formatTimeControl(player.timeRemaining)
        : statusToMessages[_boardContent.gameState][player.endActor ? 0 : 1];
    String turnString =
        _boardContent.gameState == GameStatus.IN_PROGRESS && _playerToMove == player ? 'Your turn!' : '\n';
    Widget infoWidget = new Listener(
      child: new Container(
        margin: const EdgeInsets.all(10.0),
        child: new Column(
          children: <Widget>[
            new Text(infoString),
            new Text(turnString),
          ],
        ),
      ),
      onPointerDown: (PointerDownEvent e) => timeRotationRequested(player),
    );
    return new IconTheme(
      data: new IconThemeData(color: Theme.of(context).accentColor),
      child: new Container(
        margin: const EdgeInsets.all(10.0),
        child: new RotatedBox(
          quarterTurns: player.timeBoxRotated ? 2 : 0,
          child: infoWidget,
        ),
      ),
    );
  }

  void timeRotationRequested(Player player) {
    setState(() {
      player.timeBoxRotated = !player.timeBoxRotated;
    });
  }

  void onMovePlayed(GomokuSymbol symbol) {
    Player actor = getPlayer(symbol);
    Player otherPlayer = getPlayer(otherSymbol(symbol));

    print("Player $actor played a move!");
    if (_boardContent.gameState == GameStatus.IN_PROGRESS) {
      setState(() {
        _playerToMove = _playerToMove == widget._firstPlayer ? widget._secondPlayer : widget._firstPlayer;
        actor.timeRemaining += widget._timeControl.increment;
      });
      startTimer(otherPlayer);
    }
  }

  void onGameEnd(GomokuSymbol actorSymbol) {
    _timeController.cancel();

    Player actor = getPlayer(actorSymbol);
    Player otherPlayer = getPlayer(otherSymbol(actorSymbol));

    setState(() {
      actor.endActor = true;
      otherPlayer.endActor = false;
    });
  }

  void onNewGame() {
    setState(() {
      _boardContent.reset();
      _playerToMove =
          _lastStartedPlayer = _lastStartedPlayer == widget._firstPlayer ? widget._secondPlayer : widget._firstPlayer;
      GomokuSymbol firstPlayerSymbol = widget._firstPlayer.symbol;
      widget._firstPlayer.reset(widget._secondPlayer.symbol, widget._timeControl.baseTime);
      widget._secondPlayer.reset(firstPlayerSymbol, widget._timeControl.baseTime);
    });
  }

  void startTimer(Player playingPlayer) {
    if (_timeController != null) {
      _timeController.cancel();
    }
    _timeController =
        new Timer.periodic(_timeControllerSleep, (Timer _) => decrementTime(playingPlayer, _timeControllerSleep));
  }

  void decrementTime(Player player, Duration time) {
    setState(() {
      player.timeRemaining -= _timeControllerSleep;
      if (player.timeRemaining.inMilliseconds <= 0) {
        _boardContent.gameState = GameStatus.LOST_ON_TIME;
        player.endActor = true;
        onGameEnd(player.symbol);
      }
    });
  }

  Player getPlayer(GomokuSymbol symbol) {
    return symbol == widget._firstPlayer.symbol ? widget._firstPlayer : widget._secondPlayer;
  }
}
