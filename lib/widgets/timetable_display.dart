import 'dart:async';
import 'package:dynamic_color/dynamic_color.dart' show ColorHarmonization;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart' show Consumer, Provider;
import 'package:nextbus/providers/providers.dart'
    show TimetableProvider, RouteProvider;
import 'package:scroll_to_index/scroll_to_index.dart';

class TimetableDisplay extends StatefulWidget {
  final String route;
  const TimetableDisplay({super.key, required this.route});
  @override
  State<TimetableDisplay> createState() => TimetableDisplayState();
}

class TimetableDisplayState extends State<TimetableDisplay>
    with AutomaticKeepAliveClientMixin {
  late AutoScrollController _autoController;
  final double _itemHeight = 110.0;
  bool _hasInitialScrolled = false;
  Timer? _refreshTimer;
  bool _showScrollToNowFab = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _autoController = AutoScrollController();

    // Refresh UI every minute to keep "isPast" and "NOW" divider accurate
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) setState(() {});
    });

    // Listen to scroll changes
    _autoController.addListener(() {
      final threshold =
          200.0; // Show FAB if scrolled more than 200px from "Now"
      // Simple logic: if offset is significant, show the button
      if (_autoController.offset > threshold && !_showScrollToNowFab) {
        setState(() => _showScrollToNowFab = true);
      } else if (_autoController.offset <= threshold && _showScrollToNowFab) {
        setState(() => _showScrollToNowFab = false);
      }
    });

    // Auto-scroll on initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasInitialScrolled) {
        scrollToNow();
        _hasInitialScrolled = true;
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _autoController.dispose();
    super.dispose();
  }

  // Scroll logic
  void scrollToNow() {
    final timetableProvider = Provider.of<TimetableProvider>(
      context,
      listen: false,
    );
    final timetable = timetableProvider.timetables[widget.route] ?? [];
    // Find where the divider would be
    int nowDividerIndex =
        timetable.indexWhere((entry) => !_isPast(entry['time'])) - 1;

    if (nowDividerIndex != -1) {
      // Scroll to the divider index specifically
      _autoController.scrollToIndex(
        nowDividerIndex,
        preferPosition: AutoScrollPosition.begin,
        duration: const Duration(milliseconds: 500),
      );
    }
  }

  // THE REFRESH FUNCTION
  Future<void> refreshData() async {
    final routeProvider = Provider.of<RouteProvider>(context, listen: false);
    final timetableProvider = Provider.of<TimetableProvider>(
      context,
      listen: false,
    );
    // 1. Fetch the new data
    await timetableProvider.fetchTimetable(routeProvider.route);

    // 2. Trigger a rebuild to update "isPast" calculations and the "NOW" divider
    if (mounted) {
      setState(() {
        // This empty setState forces build() to run again with the new DateTime.now()
      });
    }
  }

  bool _isPast(String timeStr) {
    try {
      final now = DateTime.now();
      final arrivalTime = DateFormat("h:mm a").parse(timeStr);
      final fullArrival = DateTime(
        now.year,
        now.month,
        now.day,
        arrivalTime.hour,
        arrivalTime.minute,
      );
      return fullArrival.isBefore(now);
    } catch (e) {
      return false;
    }
  }

  (String, Color) getDelayInfo(num seconds, bool departed, ColorScheme colors) {
    // Use M3 Harmonization dynamically based on the current theme's primary
    final Color earlyColor = Colors.green.harmonizeWith(colors.primary);
    final Color lateColor = Colors.orange.harmonizeWith(colors.primary);
    final Color vLateColor = colors.error; // Use the built-in M3 Error slot

    double minutes = (seconds / 60.0).abs();
    String durationStr = minutes.toStringAsFixed(minutes < 1 ? 0 : 1);

    // Departed logic: use high-contrast text color with transparency
    if (departed) {
      return (_getLabel(seconds, durationStr), colors.outline);
    }

    // Active logic
    if (seconds < -60) return ("${durationStr}m early", earlyColor);
    if (seconds <= 60) return ("On Time", earlyColor);
    if (seconds < 180) return ("${durationStr}m late", lateColor);
    return ("${durationStr}m late", vLateColor);
  }

  String _getLabel(num seconds, String duration) {
    if (seconds < -60) return "${duration}m early";
    if (seconds <= 60) return "On Time";
    return "${duration}m late";
  }

  void resetScrollFlag() {
    _hasInitialScrolled = false;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colors = Theme.of(context).colorScheme;
    final String currentTimeStr = DateFormat('h:mm a').format(DateTime.now());

    return Consumer<TimetableProvider>(
      builder: (context, timetableProvider, child) {
        if (timetableProvider.isLoading) return const Center(child: CircularProgressIndicator());

        final timetable = timetableProvider.timetables[widget.route] ?? [];
        if (timetable.isEmpty) return const Center(child: Text('No timetable data available.'));

        int nowDividerIndex = timetable.indexWhere(
          (entry) => !_isPast(entry['time']),
        );

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                await refreshData();
                scrollToNow();
                await Future.delayed(const Duration(seconds: 1));
              },
              child: ListView.builder(
                controller: _autoController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 80), // Space for FAB
                itemCount: timetable.length + (nowDividerIndex != -1 ? 1 : 0),
                itemBuilder: (context, index) {
                  return AutoScrollTag(
                    key: ValueKey(index),
                    controller: _autoController,
                    index: index,
                    child: _buildItem(
                      index,
                      nowDividerIndex,
                      timetable,
                      currentTimeStr,
                      colors,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildItem(
    int index,
    int nowDividerIndex,
    List timetable,
    String currentTimeStr,
    ColorScheme colors,
  ) {
    if (nowDividerIndex != -1 && index == nowDividerIndex) {
      return _buildNowDivider(currentTimeStr, colors);
    }

    final actualIndex = (nowDividerIndex != -1 && index > nowDividerIndex)
        ? index - 1
        : index;
    final entry = timetable[actualIndex];
    final bool departed = _isPast(entry['time']);
    final (delayText, delayColor) = getDelayInfo(
      entry['delay'] as num,
      departed,
      colors,
    );
    final bool isLast = actualIndex == timetable.length - 1;

    return SizedBox(
      height: _itemHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTimeline(departed, isLast, colors),
          const SizedBox(width: 16),
          Expanded(
            child: _buildCard(entry, departed, delayText, delayColor, colors),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(bool departed, bool isLast, ColorScheme colors) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: departed ? colors.outlineVariant : colors.primary,
            shape: BoxShape.circle,
          ),
        ),
        if (!isLast)
          Expanded(child: Container(width: 2, color: colors.outlineVariant)),
      ],
    );
  }

  Widget _buildCard(
    dynamic entry,
    bool departed,
    String delayText,
    Color delayColor,
    ColorScheme colors,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: departed
              ? colors.primaryContainer.withValues(alpha: 0.4)
              : colors.primaryContainer.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    entry['time'],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: departed
                          ? colors.outline
                          : colors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'No. of entries: ${entry['count']}',
                    style: TextStyle(
                      fontSize: 13,
                      color: departed
                          ? colors.outline
                          : colors.onSurfaceVariant,
                    ),
                  ),
                  // Tooltip(
                  //   message: "${entry['time']} ($delayText)",
                  //   triggerMode: TooltipTriggerMode.longPress,
                  //   child: Text(
                  //     delayText,
                  //     maxLines: 1,
                  //     overflow: TextOverflow.ellipsis,
                  //     style: TextStyle(color: departed ? colors.outline : colors.onSurfaceVariant, fontSize: 13),
                  //   ),
                  // ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: departed
                    ? Colors.transparent
                    : delayColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: delayColor.withValues(alpha: 0.2)),
              ),
              child: Text(
                delayText,
                style: TextStyle(
                  color: delayColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNowDivider(String time, ColorScheme colors) {
    return SizedBox(
      height: 60,
      child: Row(
        children: [
          Expanded(child: Divider(color: colors.outlineVariant, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              "NOW • $time",
              style: TextStyle(
                color: colors.outline,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Expanded(child: Divider(color: colors.outlineVariant, thickness: 1)),
        ],
      ),
    );
  }
}
