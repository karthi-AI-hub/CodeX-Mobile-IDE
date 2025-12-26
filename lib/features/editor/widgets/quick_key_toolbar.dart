import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class QuickKeyToolbar extends StatelessWidget {
  final Function(String) onKeyTap;
  const QuickKeyToolbar({super.key, required this.onKeyTap});

  @override
  Widget build(BuildContext context) {
    final keys = ['<', '>', '/', '"', "'", '=', '{', '}', '(', ')', '[', ']', ';', ':', '.', r'$'];
    return Container(
      height: 44,
      decoration: const BoxDecoration(
        color: CodeXColors.header,
        border: Border(top: BorderSide(color: CodeXColors.border, width: 0.5)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: keys.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
            child: Material(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(6),
              child: InkWell(
                onTap: () => onKeyTap(keys[index]),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: Text(
                    keys[index],
                    style: GoogleFonts.firaCode(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
