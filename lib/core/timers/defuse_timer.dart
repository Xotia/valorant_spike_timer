import 'dart:async';

typedef DefuseTickCallback = void Function(double progress);
typedef DefuseEndCallback = void Function();

class DefuseTimer {
  static const double breakpointSeconds = 3.5;
  static const double totalSeconds = 7.0;

  final DefuseTickCallback onTick;
  final DefuseEndCallback onEnd;

  Timer? _timer;
  double _progress = 0.0;
  double _savedProgressAtBreakpoint = 0.0;
  bool _isHolding = false;

  double get progress => _progress;
  bool get isRunning => _timer != null;
  bool get passedBreakpoint => _progress >= breakpointSeconds;

  double get breakpointProgress => breakpointSeconds / totalSeconds; // 0.5

  DefuseTimer({required this.onTick, required this.onEnd});

  void startHold() {
    _isHolding = true;
    if (!isRunning) {
      _progress = passedBreakpoint ? _savedProgressAtBreakpoint : 0.0;
      _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (_isHolding) {
          _progress += 0.1;
          onTick(_progress / totalSeconds);

          if (_progress >= breakpointSeconds) {
            _savedProgressAtBreakpoint = 0.5 * totalSeconds; // 3.5 seconds
          }

          if (_progress >= totalSeconds) {
            onTick(1.0);
            stop();
            // Reset internal progress so subsequent defuse attempts start from 0%
            _progress = 0.0;
            _savedProgressAtBreakpoint = 0.0;
            onEnd();
          }
        }
      });
    }
  }

  void stop() {
    // ← AJOUTÉ
    _timer?.cancel();
    _timer = null;
    _isHolding = false;
  }

  void dispose() {
    stop();
  }
}
