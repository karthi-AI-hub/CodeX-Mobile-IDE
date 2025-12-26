import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class StatusBar extends StatelessWidget {
  final String activeFile;
  final int line;
  final int column;

  const StatusBar({
    super.key,
    required this.activeFile,
    required this.line,
    required this.column,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      color: CodeXColors.accentBlue,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.source_rounded, size: 14, color: Colors.white),
              const SizedBox(width: 12),
              _buildStatusItem(Icons.error_outline_rounded, '0'),
              const SizedBox(width: 8),
              _buildStatusItem(Icons.warning_amber_rounded, '0'),
            ],
          ),
          Row(
            children: [
              _buildText('Ln $line, Col $column'),
              const SizedBox(width: 16),
              _buildText('UTF-8'),
              const SizedBox(width: 16),
              _buildText(_getLanguage(activeFile)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.white.withOpacity(0.9)),
        const SizedBox(width: 4),
        Text(
          value,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildText(String text) {
    return Text(
      text,
      style: GoogleFonts.outfit(color: Colors.white, fontSize: 11, fontWeight: FontWeight.normal),
    );
  }

  String _getLanguage(String fileName) {
    if (fileName.endsWith('.html')) return 'HTML';
    if (fileName.endsWith('.css')) return 'CSS';
    if (fileName.endsWith('.js')) return 'JavaScript';
    return 'PlainText';
  }
}
