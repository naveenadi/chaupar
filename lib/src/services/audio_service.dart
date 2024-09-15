import 'package:flame_audio/flame_audio.dart';

import '../constants/constant.dart';

class AudioService {
  static AudioService? _instance;

  static AudioService get instance {
    _instance ??= AudioService();
    return _instance!;
  }

  Future<void> init() async {
    await FlameAudio.audioCache.loadAll([
      SoundAssets.diceThrow1,
      SoundAssets.diceThrow2,
      SoundAssets.diceThrow3
    ]);
  }

  void play(String file) => FlameAudio.play(file);
}
