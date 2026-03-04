import 'dart:async';

typedef RoundTickCallback = void Function(Duration remaining);
typedef RoundEndCallback = void Function();

class RoundTimer {
  RoundTimer({
    required this.onTick,
    required this.onEnd,
  });

  final RoundTickCallback onTick;
  final RoundEndCallback onEnd;

  Timer? _timer;
  Duration _duration = const Duration(minutes: 1, seconds: 40);
  bool _isPaused = false;
  Duration get remaining => _duration;
  bool get isRunning => _timer != null;
  bool get isPaused => _isPaused;
  int get totalSeconds => _duration.inSeconds;

  void setDuration(int minutes, int seconds) {
    _duration = Duration(minutes: minutes, seconds: seconds);
  }

  void start() {
    if (_isPaused) {
      _isPaused = false;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _duration -= const Duration(seconds: 1);
        onTick(_duration);
        if (_duration.inSeconds <= 0) {
          stop();
          onEnd();
        }
      });
    } else {
      stop();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _duration -= const Duration(seconds: 1);
        onTick(_duration);
        if (_duration.inSeconds <= 0) {
          stop();
          onEnd();
        }
      });
    }
  }

  void pause() {
    if (isRunning) {
      stop();
      _isPaused = true;
    }
  }

  void resume() {
    if (_isPaused) {
      _isPaused = false;
      start();
    }
  }

  void resetToCurrent() {
    stop();
    _isPaused = false;
    onTick(_duration);
  }

  void reset() {
    stop();
    _duration = const Duration(minutes: 1, seconds: 40);
    onTick(_duration);
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    stop();
  }
}
