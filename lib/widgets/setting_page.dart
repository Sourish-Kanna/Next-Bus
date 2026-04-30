import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show Provider;
import 'package:nextbus/providers/providers.dart' show ThemeProvider;
import 'package:nextbus/constant.dart' show mobileBreakpoint, seedColorList;

class SettingsGroupCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const SettingsGroupCard({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      // Expressive shape with a large corner radius
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28.0),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    // fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class ThemeSettings extends StatelessWidget {
  const ThemeSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ThemeModeSelector(),
        Divider(height: 32),
        MaterialYouSettings(),
      ],
    );
  }
}

class ThemeModeSelector extends StatelessWidget {
  const ThemeModeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Using a more prominent text style
        Text('Theme Mode', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12.0),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<ThemeMode>(
            showSelectedIcon: false,
            segments: const <ButtonSegment<ThemeMode>>[
              ButtonSegment<ThemeMode>(
                value: ThemeMode.system,
                label: Text('System'),
                icon: Icon(Icons.settings_suggest_rounded),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.light,
                label: Text('Light'),
                icon: Icon(Icons.light_mode_rounded),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.dark,
                label: Text('Dark'),
                icon: Icon(Icons.dark_mode_rounded),
              ),
            ],
            selected: {themeProvider.themeMode},
            onSelectionChanged: (Set<ThemeMode> newSelection) {
              themeProvider.setThemeMode(newSelection.first);
            },
          ),
        ),
      ],
    );
  }
}

class MaterialYouSettings extends StatelessWidget {
  const MaterialYouSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < mobileBreakpoint;
        final double boxSize = isMobile ? 48.0 : 64.0;
        final double iconSize = isMobile ? 24.0 : 32.0;
        final double spacing = isMobile ? 10.0 : 16.0;
        final squircleRadius = BorderRadius.circular(isMobile ? 12.0 : 16.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Color Scheme', style: Theme.of(context).textTheme.titleLarge),
            SwitchListTile(
              title: const Text('Use Dynamic Color'),
              subtitle: const Text('Android 12+'),
              value: themeProvider.isDynamicColor,
              onChanged: (value) => themeProvider.setDynamicColor(value),
              secondary: const Icon(Icons.palette_rounded),
              contentPadding: EdgeInsets.zero,
            ),
            if (!themeProvider.isDynamicColor) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: seedColorList.map((color) {
                  final isSelected = themeProvider.selectedSeedColor == color;

                  return InkWell(
                    onTap: () => themeProvider.setSelectedSeedColor(color),
                    borderRadius: squircleRadius,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: boxSize,
                      height: boxSize,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: squircleRadius,
                        border: isSelected && !themeProvider.isDynamicColor
                            ? Border.all(color: color, width: 2)
                            : null,
                        boxShadow: isSelected && !themeProvider.isDynamicColor
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : [],
                      ),
                      child: isSelected
                          ? Center(
                              child: Icon(
                                Icons.check,
                                color: Theme.of(context).colorScheme.onPrimary,
                                size: iconSize,
                              ),
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        );
      },
    );
  }
}
