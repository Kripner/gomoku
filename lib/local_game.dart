import 'package:flutter/material.dart';
import 'package:gomoku/board/board_content.dart';
import 'package:gomoku/game.dart';
import 'package:gomoku/time_control.dart';
import 'package:gomoku/utils/utils.dart';

class LocalGame extends Game {
  LocalGame(TimeControl _timeControl)
      : super(new Player(GomokuSymbol.CROSS, _timeControl.baseTime),
            new Player(GomokuSymbol.NODE, _timeControl.baseTime), _timeControl);

  @override
  State<StatefulWidget> createState() {
    return new LocalGameState();
  }
}

class LocalGameState extends GameState {
  Player _lastStartedPlayer;
  final Map<Player, bool> _timeRotated = {};

  @override
  void initState() {
    super.initState();
    _lastStartedPlayer = widget.firstPlayer;
    _timeRotated.addAll({widget.firstPlayer: false, widget.secondPlayer: false});
  }

  @override
  Player getStartingPlayer() {
    return widget.firstPlayer;
  }

  @override
  Widget buildTopHeader(BuildContext context) {
    return new RotatedBox(
      quarterTurns: 2,
      child: _buildHeader(context, widget.secondPlayer),
    );
  }

  @override
  Widget buildBottomHeader(BuildContext context) {
    return _buildHeader(context, widget.firstPlayer);
  }

  Widget _buildHeader(BuildContext context, Player player) {
    String infoString = boardContent.gameState == GameStatus.IN_PROGRESS
        ? formatTimeControl(player.timeRemaining)
        : statusToMessages[boardContent.gameState][player == endActor ? 0 : 1];
    String turnString =
        boardContent.gameState == GameStatus.IN_PROGRESS && playerToMove == player ? 'Your turn!' : '\n';
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
          quarterTurns: _timeRotated[player] ? 2 : 0,
          child: infoWidget,
        ),
      ),
    );
  }

  void timeRotationRequested(Player player) {
    setState(() {
      _timeRotated[player] = !_timeRotated[player];
    });
  }

  void onNewGame() {
    super.onNewGame();
    setState(() {
      playerToMove =
          _lastStartedPlayer = _lastStartedPlayer == widget.firstPlayer ? widget.secondPlayer : widget.firstPlayer;
    });
  }
}
