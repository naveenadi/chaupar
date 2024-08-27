import 'package:flame_audio/flame_audio.dart';

class AudioService {
  static AudioService? _instance;

  static AudioService get instance {
    _instance ??= AudioService();
    return _instance!;
  }

  static const diceThrow1 = "sfx/dice-throw-1.ogg";
  static const diceThrow2 = "sfx/dice-throw-2.ogg";
  static const diceThrow3 = "sfx/dice-throw-3.ogg";

  void play(String file) => FlameAudio.play(file);
}