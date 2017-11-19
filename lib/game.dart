import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gomoku/board/board.dart';
import 'package:gomoku/board/board_content.dart';
import 'package:gomoku/board/board_painter.dart';
import 'package:gomoku/time_control.dart';

class Player {
  GomokuSymbol symbol;
  Duration timeRemaining;

  Player(this.symbol, this.timeRemaining);

  void reset(GomokuSymbol newSymbol, Duration baseTime) {
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

abstract class Game extends StatefulWidget {
  final Player firstPlayer;
  final Player secondPlayer;
  final TimeControl timeControl;

  Game(this.firstPlayer, this.secondPlayer, [this.timeControl]);
}

abstract class GameState extends State<Game> {
  static final Duration _timeControllerSleep = new Duration(milliseconds: 100);

  final BoardContent boardContent = new BoardContent.empty(BoardPainter.numOfCells);
  Timer _timeController;
  Player playerToMove;
  Player endActor;

  Player getStartingPlayer();

  @override
  void initState() {
    super.initState();
    playerToMove = getStartingPlayer();
  }

  @override
  void dispose() {
    boardContent.gameState = GameStatus.TERMINATED;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          buildTopHeader(context),
          new AspectRatio(
            aspectRatio: 1.0,
            child: new Board(boardContent, playerToMove.symbol, onMovePlayed, onGameEnd, onNewGame),
          ),
          buildBottomHeader(context),
        ],
      ),
    );
  }

  Widget buildTopHeader(BuildContext context);
  Widget buildBottomHeader(BuildContext context);

  void onMovePlayed() {
    print("Player $playerToMove played a move!");
    if (boardContent.gameState == GameStatus.IN_PROGRESS) {
      setState(() {
        playerToMove.timeRemaining += widget.timeControl.increment;
        playerToMove = playerToMove == widget.firstPlayer ? widget.secondPlayer : widget.firstPlayer;
      });
      startTimer(playerToMove);
    }
  }

  void onGameEnd() {
    _timeController.cancel();
    setState(() {
      endActor = playerToMove;
    });
  }

  void onNewGame() {
    setState(() {
      boardContent.reset();
      GomokuSymbol firstPlayerSymbol = widget.firstPlayer.symbol;
      widget.firstPlayer.reset(widget.secondPlayer.symbol, widget.timeControl.baseTime);
      widget.secondPlayer.reset(firstPlayerSymbol, widget.timeControl.baseTime);
      endActor = null;
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
        boardContent.gameState = GameStatus.LOST_ON_TIME;
        endActor = player;
        onGameEnd();
      }
    });
  }
}
