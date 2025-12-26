import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ActivityBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onIndexChanged;

  const ActivityBar({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54, // Slightly wider for better accessibility
      decoration: const BoxDecoration(
        color: CodeXColors.header,
        border: Border(right: BorderSide(color: CodeXColors.border, width: 0.5)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _buildIcon(0, Icons.copy_rounded, 'Explorer'), 
          _buildIcon(1, Icons.search_rounded, 'Search'), 
          _buildIcon(2, Icons.settings_rounded, 'Settings'), 
          const Spacer(),
          _buildIcon(3, Icons.menu_rounded, 'Menu'), 
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildIcon(int index, IconData icon, String tooltip) {
    final isSelected = selectedIndex == index;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () => onIndexChanged(index),
        child: SizedBox(
          width: 54,
          height: 54,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
                size: 24,
              ),
              if (isSelected)
                Positioned(
                  left: 0,
                  top: 12,
                  bottom: 12,
                  child: Container(
                    width: 3,
                    decoration: BoxDecoration(
                      color: CodeXColors.accentBlue,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
