import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextbus/providers/connectivity.dart';
import 'package:nextbus/widgets/connectivity_banner.dart';
import 'package:provider/provider.dart';

class MockConnectivityProvider extends ChangeNotifier
    implements ConnectivityProvider {
  bool _online;

  MockConnectivityProvider({bool isOnline = true}) : _online = isOnline;

  @override
  bool get isOnline => _online;

  void setOnline(bool online) {
    _online = online;
    notifyListeners();
  }

  @override
  Future<bool> checkConnection() async {
    return _online;
  }
}

void main() {
  Widget createWidgetUnderTest(ConnectivityProvider connectivityProvider) {
    return MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider<ConnectivityProvider>.value(
          value: connectivityProvider,
          child: const ConnectivityBanner(),
        ),
      ),
    );
  }

  group('ConnectivityBanner', () {
    testWidgets('shows nothing when online', (WidgetTester tester) async {
      final mockProvider = MockConnectivityProvider(isOnline: true);

      await tester.pumpWidget(createWidgetUnderTest(mockProvider));

      expect(find.text('No connection. Tap to retry.'), findsNothing);
    });

    testWidgets('shows banner when offline', (WidgetTester tester) async {
      final mockProvider = MockConnectivityProvider(isOnline: false);

      await tester.pumpWidget(createWidgetUnderTest(mockProvider));

      expect(find.text('No connection. Tap to retry.'), findsOneWidget);
    });
  });
}
