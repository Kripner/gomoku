import 'package:flutter/material.dart';
import 'package:gomoku/board/board_content.dart';
import 'package:gomoku/utils/pair.dart';

double unitWidth;

class BoardPainter extends ChangeNotifier implements CustomPainter {
  static final int numOfCells = 15;
  static final double safeRegionRatio = 0.10;

  static final double crossWidthToUnit = 0.70;
  static final double nodeWidthToUnit = 0.9;

  static final double crossStokeWidth = 5.0;
  static final double nodeStokeWidth = 4.0;

  static final Color nodeColor = Colors.blue;
  static final Color crossColor = Colors.red;
  static final Color winMarkColor = Colors.green;

  BoardContent _boardContent;

  BoardPainter(this._boardContent);

  @override
  void paint(Canvas canvas, Size size) {
    unitWidth = size.width / numOfCells;
    final Paint paint = new Paint()..color = Colors.grey;
    paint.strokeWidth = 1.0;
    for (int i = 0; i <= numOfCells; ++i) {
      double x = unitWidth * i;
      canvas.drawLine(new Offset(x, 0.0), new Offset(x, size.height), paint);
    }
    for (int i = 0; i <= numOfCells; ++i) {
      double y = unitWidth * i;
      canvas.drawLine(new Offset(0.0, y), new Offset(size.width, y), paint);
    }

    double crossWidth = unitWidth * crossWidthToUnit;
    double nodeWidth = unitWidth * nodeWidthToUnit;
    for (int row = 0; row < numOfCells; ++row) {
      for (int column = 0; column < numOfCells; ++column) {
        GomokuSymbol symbol = _boardContent.get(row, column);
        if (symbol != null) {
          Offset symbolPosition = computePosition(row, column);
          if (symbol == GomokuSymbol.CROSS)
            _paintCross(canvas, symbolPosition, crossWidth);
          else if (symbol == GomokuSymbol.NODE)
            _paintNode(canvas, symbolPosition, nodeWidth);
        }
      }
    }

    if (_boardContent.gameState == GameStatus.WON) {
      markWins(canvas, _boardContent.wins);
    }
  }

  void _paintCross(Canvas canvas, Offset center, double width) {
    final Paint paint = new Paint()..color = crossColor;
    paint.strokeWidth = crossStokeWidth;
    Path path = new Path();
    path.moveTo(center.dx - width / 2, center.dy - width / 2); // left top of the cross
    path.relativeLineTo(width, width); // line from left top to right bottom
    path.relativeMoveTo(0.0, -width); // right top of the cross
    path.relativeLineTo(-width, width); // line from right top to left bottom
    canvas.drawPath(path, paint);

    Offset topLeft = center.translate(-width / 2, - width / 2);
    canvas.drawLine(topLeft, topLeft.translate(width, width), paint);
    canvas.drawLine(topLeft.translate(width, 0.0), topLeft.translate(0.0, width), paint);
  }

  void _paintNode(Canvas canvas, Offset center, double width) {
    final Paint paint = new Paint()..color = nodeColor;
    paint.strokeWidth = nodeStokeWidth;
    paint.style = PaintingStyle.stroke;
    width -= nodeStokeWidth;
//    Offset topLeft = center.translate(-width / 2, -width / 2);
//    canvas.drawArc(topLeft & new Size.square(width), 0.0, 2 * PI, false, paint);
    canvas.drawCircle(center, width / 2, paint);
  }

  void contentChanged() {
    notifyListeners();
  }

  void markWins(Canvas canvas, List<WinInfo> wins) {
    final Paint paint = new Paint()..color = winMarkColor;
    paint.strokeWidth = 3.0;
    for (WinInfo win in wins) {
      Offset lineStart = computePosition(win.fromPosition.row, win.fromPosition.column);
      Offset lineEnd = computePosition(win.toPosition.row, win.toPosition.column);
      canvas.drawLine(lineStart, lineEnd, paint);
    }
  }

  @override
  bool shouldRepaint(BoardPainter oldDelegate) {
    print('shouldRepaint');
    return true;
//    return !_boardContent.same(oldDelegate._boardContent);
  }

  Pair<int, int> computeRowColumn(double x, double y) {
    double row = y / unitWidth;
    double column = x / unitWidth;
    double yProximity = (row - row.round()).abs(), xProximity = (column - column.round()).abs();
    if (yProximity < safeRegionRatio || xProximity < safeRegionRatio) return null;
    return new Pair<int, int>(row.toInt(), column.toInt());
  }

  Offset computePosition(int row, int column) {
    double x = (column + 0.5) * unitWidth;
    double y = (row + 0.5) * unitWidth;
    return new Offset(x, y);
  }

  bool hitTest(Offset position) => null;
}
