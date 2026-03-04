import 'package:audioplayers/audioplayers.dart';
import 'dart:developer' show print;

class SpikeAudioService {
  late final AudioPlayer _plantPlayer;
  late final AudioPlayer _defusePlayer;
  late final AudioPlayer _explosionPlayer;
  late final AudioPlayer _roundStartPlayer;
  late final AudioPlayer _roundEndPlayer;

  // Contexte Android jeu (priorité)
  static final AudioContext _gameContext = AudioContext(
    android: AudioContextAndroid(
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.game,
      audioFocus: AndroidAudioFocus.gainTransientMayDuck,
    ),
  );

  SpikeAudioService() {
    _plantPlayer = AudioPlayer()..setAudioContext(_gameContext);
    _defusePlayer = AudioPlayer()..setAudioContext(_gameContext);
    _explosionPlayer = AudioPlayer()..setAudioContext(_gameContext);
    _roundStartPlayer = AudioPlayer()..setAudioContext(_gameContext);
    _roundEndPlayer = AudioPlayer()..setAudioContext(_gameContext);
  }

  Future<void> playRoundStart() async {
    try {
      await _roundStartPlayer.play(AssetSource('sounds/round_start.mp3'));
    } catch (e) {
      print('Round start audio error: $e');
    }
  }

  Future<void> playRoundEnd() async {
    try {
      await _roundEndPlayer.play(AssetSource('sounds/round_end.mp3'));
    } catch (e) {
      print('Round end audio error: $e');
    }
  }

  Future<void> playPlant() async {
    print('🔍 Plant sound...');
    try {
      await _plantPlayer.play(
        AssetSource('sounds/valorant_spike_plant_beep.mp3'),
      );
      print('✅ Plant joué');
    } catch (e) {
      print('❌ Plant erreur: $e');
    }
  }

  Future<void> playDefuseStart() async {
    print('🔍 Defuse sound...');
    try {
      await _defusePlayer.play(AssetSource('sounds/valorant_spike_defuse.mp3'));
      print('✅ Defuse joué');
    } catch (e) {
      print('❌ Defuse erreur: $e');
    }
  }

  Future<void> playExplosion() async {
    print('🔍 Explosion sound...');
    try {
      await _explosionPlayer.play(
        AssetSource('sounds/valorant_spike_explosion.mp3'),
      );
      print('✅ Explosion jouée');
    } catch (e) {
      print('❌ Explosion erreur: $e');
    }
  }

  Future<void> stopPlant() async {
    await _plantPlayer.stop();
    print('🛑 Plant stopped');
  }

  void dispose() {
    _plantPlayer.dispose();
    _defusePlayer.dispose();
    _explosionPlayer.dispose();
    _roundStartPlayer.dispose();
    _roundEndPlayer.dispose();
  }
}
