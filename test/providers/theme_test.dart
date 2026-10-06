import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextbus/constant.dart';
import 'package:nextbus/providers/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ThemeProvider', () {
    test('initial state defaults', () {
      final provider = ThemeProvider();

      expect(provider.themeMode, equals(ThemeMode.system));
      expect(provider.isDynamicColor, isTrue);
      expect(provider.selectedSeedColor, equals(fallbackColor));
    });

    test('setThemeMode updates themeMode and notifies listeners', () {
      final provider = ThemeProvider();
      var notified = false;

      provider.addListener(() {
        notified = true;
      });

      provider.setThemeMode(ThemeMode.dark);

      expect(provider.themeMode, equals(ThemeMode.dark));
      expect(notified, isTrue);
    });

    test('setSelectedSeedColor sets seed color and disables dynamic color', () {
      final provider = ThemeProvider();
      const testColor = Colors.purple;

      provider.setSelectedSeedColor(testColor);

      expect(provider.selectedSeedColor, equals(testColor));
      expect(provider.isDynamicColor, isFalse);
    });

    test('setDynamicColor true clears seed color', () {
      final provider = ThemeProvider();
      provider.setSelectedSeedColor(Colors.purple);

      provider.setDynamicColor(true);

      expect(provider.isDynamicColor, isTrue);
      expect(provider.selectedSeedColor, isNull);
    });
  });
}
