final Duration _timeFloatingPointThreshold = new Duration(seconds: 15);

String formatTimeControl(Duration time) {
  int hours = time.inHours.toInt();
  int minutes = time.inMinutes % 60;
  int seconds = time.inSeconds % 60;

  String timeString = hours == 0 ? '' : (hours.toString().padLeft(2, '0') + ':');
  timeString += minutes.toString().padLeft(2, '0') + ':';
  timeString += seconds.toString().padLeft(2, '0');

  if (time < _timeFloatingPointThreshold)
    timeString += '.' + ((time.inMilliseconds % 1000) ~/ 100).toString();
  return timeString;
}