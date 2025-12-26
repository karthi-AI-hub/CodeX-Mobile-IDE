import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';

class AboutLegalScreen extends StatelessWidget {
  const AboutLegalScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CodeXColors.background,
      appBar: AppBar(
        title: Text(
          'Legal & About',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // App Logo
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: CodeXColors.accentBlue.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset('assets/logo.png'),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'CodeX Mobile IDE',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: GoogleFonts.outfit(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 48),
            
            // Info Section
            _buildSection(
              context,
              'Resources',
              [
                _buildLinkItem(
                  icon: Icons.language_rounded,
                  label: 'Official Website',
                  onTap: () => _launchUrl('https://codexmobileide.vercel.app/'),
                ),
                _buildLinkItem(
                  icon: Icons.shield_outlined,
                  label: 'Privacy Policy',
                  onTap: () => _launchUrl('https://codexmobileide.vercel.app/privacy'),
                ),
                _buildLinkItem(
                  icon: Icons.description_outlined,
                  label: 'Terms of Service',
                  onTap: () => _launchUrl('https://codexmobileide.vercel.app/terms'),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            _buildSection(
              context,
              'Developer',
              [
                _buildLinkItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Karthikeyan | Full Stack Web | Mobile Developer',
                  onTap: null, // Just info
                ),
                _buildLinkItem(
                  icon: Icons.mail_outline_rounded,
                  label: 'Support Assistance',
                  onTap: () => _launchUrl('mailto:karthi.nexgen.dev@gmail.com'),
                ),
              ],
            ),
            
            const SizedBox(height: 60),
            Text(
              '© 2025 CodeX. All rights reserved.',
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: Colors.grey.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: CodeXColors.accentBlue,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildLinkItem({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 22, color: Colors.white.withOpacity(0.7)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Colors.white.withOpacity(0.3),
              ),
          ],
        ),
      ),
    );
  }
}
