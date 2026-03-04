import 'package:flutter/material.dart';
import '../../../core/timers/spike_timer.dart';
import '../../../core/audio/spike_audio_service.dart';
import '../../../core/timers/defuse_timer.dart';
import '../../../core/timers/round_timer.dart';

class SpikeTimerPage extends StatefulWidget {
  const SpikeTimerPage({super.key});

  @override
  State<SpikeTimerPage> createState() => _SpikeTimerPageState();
}

class _SpikeTimerPageState extends State<SpikeTimerPage> {
  static const int _spikeDurationSeconds = 49;
  late SpikeTimer _spikeTimer;
  int _remainingSeconds = _spikeDurationSeconds;
  late SpikeAudioService _audioService;
  late DefuseTimer _defuseTimer;
  double _defuseProgress = 0.0;
  bool get isDefusing => _defuseTimer.isRunning;
  late RoundTimer _roundTimer;
  Duration _roundRemaining = const Duration(minutes: 1, seconds: 40);
  int _roundMinutes = 1;
  int _roundSeconds = 40;
  bool get isRoundPaused => _roundTimer.isPaused;
  bool _roundEnded = false;

  @override
  void initState() {
    super.initState();
    _roundTimer = RoundTimer(
      onTick: (duration) {
        setState(() {
          _roundRemaining = duration;
        });
      },
      onEnd: () {
        debugPrint('🏁 Round time up!');
      },
    );
    _spikeTimer = SpikeTimer(
      totalSeconds: _spikeDurationSeconds,
      onTick: (seconds) {
        setState(() {
          _remainingSeconds = seconds;
        });
      },
      onEnd: () async {
        await _audioService.playExplosion(); // Son d'explosion
        debugPrint('Spike exploded');
      },
    );
    _audioService = SpikeAudioService();
    _defuseTimer = DefuseTimer(
      onTick: (progress) {
        setState(() {
          _defuseProgress = progress;
        });
      },
      onEnd: () async {
        await _audioService.stopPlant(); // ← ARRÊT plant
        setState(() {
          _defuseProgress = 0.0;
        });
        _spikeTimer.stop(); // Succès defuse → arrête le spike
        debugPrint('Defuse successful!');
      },
    );
  }

  @override
  void dispose() {
    _spikeTimer.dispose();
    _audioService.dispose();
    _defuseTimer.dispose();
    _roundTimer.dispose();

    super.dispose();
  }

  void _onDefusePressDown() async {
    if (!_spikeTimer.isRunning) return;
    await _audioService.playDefuseStart();
    _defuseTimer.startHold();
  }

  void _adjustRoundTime(int deltaMinutes, int deltaSeconds) {
    _roundMinutes = (_roundMinutes + deltaMinutes).clamp(0, 10);
    _roundSeconds = (_roundSeconds + deltaSeconds).clamp(0, 59);
    _roundTimer.setDuration(_roundMinutes, _roundSeconds);
    setState(() {});
  }

  void _startRoundTimer() {
    _roundTimer.start();
  }

  void _resetDefuse() {
    _defuseTimer.stop();
    setState(() {
      _defuseProgress = 0.0;
      _roundEnded = false;
    });
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(d.inMinutes);
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  void _onDefusePressUp() {
    _defuseTimer.stop();
  }

  void _startSpikeTimer() async {
    if (_defuseTimer.isRunning) _defuseTimer.stop(); // ← Utilise le getter
    await _audioService.playPlant();
    _spikeTimer.start();
  }

  void _pauseRoundTimer() {
    _roundTimer.pause();
    setState(() {});
  }

  void _resumeRoundTimer() {
    _roundTimer.resume();
    setState(() {});
  }

  void _resetRoundTimer() {
    _roundMinutes = 1;
    _roundSeconds = 40;
    _roundTimer.setDuration(1, 40);
    _roundTimer.resetToCurrent();
    setState(() {});
  }

  Widget _timeAdjustButton(IconData icon, int deltaMin, int deltaSec) {
    return IconButton(
      onPressed: () => _adjustRoundTime(deltaMin, deltaSec),
      icon: Icon(icon, color: Colors.white, size: 28),
      style: IconButton.styleFrom(
        backgroundColor: Colors.blue[700],
        padding: const EdgeInsets.all(12),
      ),
    );
  }

  Widget _timeDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue[600],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$_roundMinutes:${_roundSeconds.toString().padLeft(2, '0')}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _controlButton(String label, VoidCallback? onPressed, {Color? color}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Colors.blue[600],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 14)),
    );
  }

  String _formatSeconds(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    final mm = minutes.toString().padLeft(2, '0');
    final ss = secs.toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Valorant Timers')),
      body: SingleChildScrollView(
        // ← Scroll si petit écran
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ROUND TIMER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.blue[800],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    _formatDuration(_roundRemaining),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    // ← Responsive auto
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _timeAdjustButton(Icons.remove, -1, 0),
                      _timeDisplay(),
                      _timeAdjustButton(Icons.add, 1, 0),
                      _timeAdjustButton(Icons.remove, 0, -10),
                      _timeAdjustButton(Icons.add, 0, 10),
                      _controlButton(
                        'Start',
                        _roundTimer.isRunning ? null : _startRoundTimer,
                      ),
                      _controlButton(
                        _roundTimer.isPaused ? 'Resume' : 'Pause',
                        _roundTimer.isRunning
                            ? () => _roundTimer.isPaused
                                  ? _resumeRoundTimer()
                                  : _pauseRoundTimer()
                            : null,
                      ),
                      _controlButton(
                        'Reset',
                        _resetRoundTimer,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // SPIKE TIMER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.red[800],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    _formatSeconds(_spikeTimer.remainingSeconds),
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // BOUTONS VERTICAUX ← FIX OVERFLOW
                  Column(
                    children: [
                      // Planter Spike
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SizedBox(
                          width: double.infinity, // ← Pleine largeur
                          child: ElevatedButton(
                            onPressed: _spikeTimer.isRunning
                                ? null
                                : _startSpikeTimer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              '🟢 Planter Spike',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ),

                      // Tenir Defuse
                      Listener(
                        onPointerDown: (_) => _onDefusePressDown(),
                        onPointerUp: (_) => _onDefusePressUp(),
                        onPointerCancel: (_) => _onDefusePressUp(),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 20,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.withOpacity(0.3),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      '🟠 Tenir pour Defuse',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      '${(_defuseProgress * 100).toInt()}%',
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_roundEnded)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: ElevatedButton(
                                  onPressed: _resetDefuse,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text('🔄 Reset Defuse'),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
