import 'package:audioplayers/audioplayers.dart';
import 'dart:developer' show print;

class SpikeAudioService {
  late final AudioPlayer _plantPlayer;
  late final AudioPlayer _defusePlayer;
  late final AudioPlayer _explosionPlayer;

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
  }
}
