import 'package:flutter/foundation.dart';
import 'package:nextbus/firebase/firebase_options_dev.dart';
import 'package:nextbus/firebase/firebase_options_prod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nextbus/common.dart';

// 1. Smart Default: If release mode, default to 'prod'. If debug, default to 'dev'.
const String _defaultEnv = kReleaseMode ? 'prod' : 'dev';

// 2. Allow manual override via command line if needed
const String _environment = String.fromEnvironment(
  'ENVIRONMENT',
  defaultValue: _defaultEnv,
);

const String _localApiUrl = String.fromEnvironment('API_LINK');

class Config {
  static String get apiUrl {
    return _localApiUrl;
  }

  static FirebaseOptions get firebaseOptions {
    AppLogger.onlyLocal("Build Mode: ${kReleaseMode ? 'Release' : 'Debug'}");
    AppLogger.onlyLocal("Environment: $_environment");

    // 3. Select Options based on Environment
    if (_environment == 'prod') {
      return ProdFirebaseOptions.currentPlatform;
    }
    return DevFirebaseOptions.currentPlatform;
  }
}
