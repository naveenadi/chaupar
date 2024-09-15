import 'package:chaupar_chakravyuh/src/services/audio_service.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.fullScreen();
  Flame.device.setPortraitUpOnly();
  AudioService.instance.init();
  runApp(const GameApp());
}



