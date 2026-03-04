import 'dart:async';

typedef SpikeTickCallback = void Function(int remainingSeconds);
typedef SpikeEndCallback = void Function();

class SpikeTimer {
  SpikeTimer({
    required this.totalSeconds,
    required this.onTick,
    required this.onEnd,
  });

  final int totalSeconds;
  final SpikeTickCallback onTick;
  final SpikeEndCallback onEnd;

  Timer? _timer;
  int _remainingSeconds = 49;
  bool get isRunning => _timer != null;

  int get remainingSeconds => _remainingSeconds;

  void start() {
    stop();
    _remainingSeconds = totalSeconds;
    onTick(_remainingSeconds);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remainingSeconds -= 1;
      if (_remainingSeconds <= 0) {
        onTick(0);
        stop();
        onEnd();
      } else {
        onTick(_remainingSeconds);
      }
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    stop();
  }
}
