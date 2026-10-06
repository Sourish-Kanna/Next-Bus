import 'package:flutter_test/flutter_test.dart';
import 'package:nextbus/constant.dart';
import 'package:nextbus/providers/navigation_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('NavigationProvider', () {
    test('initial destination is home', () async {
      final provider = NavigationProvider();
      expect(provider.current, equals(NavigationDestinations.home));
    });

    test('navigateTo changes current destination', () async {
      final provider = NavigationProvider();
      var notified = false;
      provider.addListener(() {
        notified = true;
      });

      await provider.navigateTo(NavigationDestinations.route);

      expect(provider.current, equals(NavigationDestinations.route));
      expect(notified, isTrue);
    });

    test('navigateTo ignores navigation if already at destination', () async {
      final provider = NavigationProvider();
      var notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      await provider.navigateTo(NavigationDestinations.home);

      expect(notifyCount, equals(0));
      expect(provider.current, equals(NavigationDestinations.home));
    });

    test('resetIfInvalid resets to home if current destination is invalid', () async {
      final provider = NavigationProvider();
      await provider.navigateTo(NavigationDestinations.route);

      provider.resetIfInvalid({NavigationDestinations.home, NavigationDestinations.settings});

      expect(provider.current, equals(NavigationDestinations.home));
    });

    test('clearNavigationCache resets destination to home', () async {
      final provider = NavigationProvider();
      await provider.navigateTo(NavigationDestinations.settings);

      await provider.clearNavigationCache();

      expect(provider.current, equals(NavigationDestinations.home));
    });
  });
}
