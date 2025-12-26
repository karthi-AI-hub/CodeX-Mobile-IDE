import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/settings_provider.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Container(
      width: 200,
      color: CodeXColors.sidebar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            child: const Text(
              'SETTINGS',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(10),
              children: [
                _buildSectionHeader('Editor'),
                _buildSlider(
                  'Font Size',
                  settings.fontSize,
                  10,
                  30,
                  (val) => notifier.setFontSize(val),
                ),
                _buildSwitch(
                  'Line Numbers',
                  settings.showLineNumbers,
                  (val) => notifier.toggleLineNumbers(val),
                ),
                _buildSwitch(
                  'Word Wrap',
                  settings.wordWrap,
                  (val) => notifier.toggleWordWrap(val),
                ),
                const Divider(color: CodeXColors.border),
                _buildSectionHeader('About'),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'CodeX Mobile v1.0.0',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 5),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${value.toInt()}',
          style: const TextStyle(color: CodeXColors.text, fontSize: 13),
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: CodeXColors.accentBlue,
            inactiveTrackColor: CodeXColors.border,
            thumbColor: Colors.white,
            trackHeight: 2,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitch(String label, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: CodeXColors.text, fontSize: 13),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: CodeXColors.accentBlue,
          activeTrackColor: CodeXColors.accentBlue.withOpacity(0.3),
          inactiveThumbColor: Colors.grey,
          inactiveTrackColor: CodeXColors.border,
        ),
      ],
    );
  }
}
