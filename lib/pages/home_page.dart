import 'package:flutter/material.dart';
import 'package:nextbus/widgets/widgets.dart' show TimetableDisplay, ReportBusSheet, TimetableDisplayState;
import 'package:provider/provider.dart' show Provider;
import 'package:nextbus/providers/providers.dart' show RouteProvider, TimetableProvider, UserDetails;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String? _currentRoute;
  bool _isUserDataFetched = false;
  final GlobalKey<TimetableDisplayState> _timetableKey = GlobalKey<TimetableDisplayState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final routeProvider = Provider.of<RouteProvider>(context);
    final timetableProvider = Provider.of<TimetableProvider>(context); // Listen to data status
    final newRoute = routeProvider.route;

    if (newRoute != _currentRoute) {
      _currentRoute = newRoute;
      Future.microtask(() {
        if (!mounted) return;
        Provider.of<TimetableProvider>(context, listen: false).fetchTimetable(newRoute);
      });
    }

    // SCROLL LOGIC: If data is loaded and we haven't scrolled yet
    if (!timetableProvider.isLoading && timetableProvider.timetables.containsKey(newRoute)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _timetableKey.currentState?.scrollToNow();
        }
      });
    }

    // Fetch user data once
    if (!_isUserDataFetched) {
      _isUserDataFetched = true;
      Future.microtask(() {
        if (!mounted) return;
        Provider.of<UserDetails>(context, listen: false).fetchUserDetails();
      });
    }
  }

  void _showReportModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return const ReportBusSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final routeProvider = Provider.of<RouteProvider>(context);
    final userDetails = Provider.of<UserDetails>(context);

    String route = routeProvider.route;
    bool isGuest = userDetails.isGuest;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("TMT Bus Route $route", style: const TextStyle(fontWeight: FontWeight.bold)),
            const Text("From Thane Station to Tikuji-ni-wadi", style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: TimetableDisplay(key: _timetableKey, route: route),),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              _timetableKey.currentState?.refreshData();
              _timetableKey.currentState?.scrollToNow();
              },
            backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
            child: const Icon(Icons.refresh),
          ),

          const SizedBox(height: 12),

          if (!isGuest)
            FloatingActionButton(
              onPressed: () => _showReportModal(context),
              backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
              child: const Icon(Icons.add),
            ),
        ],
      ),
    );
  }
}