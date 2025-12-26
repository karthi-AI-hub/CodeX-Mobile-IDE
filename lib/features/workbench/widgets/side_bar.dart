import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/project_service.dart';

class SideBar extends ConsumerWidget {
  final Map<String, String> files;
  final String activeFile;
  final Function(String) onFileSelected;
  final Function(String, String)? onFileRename;
  final String projectPath; // Need path for creation

  const SideBar({
    super.key,
    required this.files,
    required this.activeFile,
    required this.onFileSelected,
    this.onFileRename,
    required this.projectPath,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortedFileNames = files.keys.toList()..sort();
    
    return Container(
      width: 220, // Slightly wider for better readability
      decoration: const BoxDecoration(
        color: CodeXColors.sidebar,
        border: Border(right: BorderSide(color: CodeXColors.border, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSidebarHeader(context, ref),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildProjectHeader('PROJECT'),
                ...sortedFileNames.map((fileName) => _buildFileItem(context, fileName)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'EXPLORER',
            style: GoogleFonts.outfit(
              color: Colors.white.withOpacity(0.5),
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 1.2,
            ),
          ),
          Row(
            children: [
              _buildHeaderAction(
                icon: Icons.note_add_rounded,
                onTap: () => _showCreateFileDialog(context, ref),
              ),
              const SizedBox(width: 4),
              _buildHeaderAction(
                icon: Icons.upload_file_rounded,
                onTap: () => _importAsset(context, ref),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAction({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 18, color: Colors.white.withOpacity(0.4)),
      ),
    );
  }

  Widget _buildProjectHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Colors.white.withOpacity(0.7)),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.outfit(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileItem(BuildContext context, String fileName) {
    final isSelected = activeFile == fileName;
    return InkWell(
      onTap: () => onFileSelected(fileName),
      onLongPress: () => _showRenameFileDialog(context, fileName),
      child: Container(
        height: 36, // Standard item height
        decoration: BoxDecoration(
          color: isSelected ? CodeXColors.accentBlue.withOpacity(0.1) : Colors.transparent,
        ),
        padding: const EdgeInsets.only(left: 24, right: 16),
        child: Row(
          children: [
            _getFileIcon(fileName),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Container(
                width: 2,
                height: 16,
                decoration: BoxDecoration(
                  color: CodeXColors.accentBlue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _getFileIcon(String fileName) {
    IconData icon;
    Color color;

    if (fileName.endsWith('.html')) {
      icon = Icons.code;
      color = Colors.orange;
    } else if (fileName.endsWith('.css')) {
      icon = Icons.style;
      color = Colors.lightBlue;
    } else if (fileName.endsWith('.js')) {
      icon = Icons.javascript;
      color = Colors.yellow;
    } else {
      icon = Icons.insert_drive_file_outlined;
      color = Colors.grey;
    }

    return Icon(icon, size: 16, color: color);
  }

  Future<void> _showCreateFileDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New File'),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: CodeXColors.text),
          decoration: const InputDecoration(
            hintText: 'filename.extension',
            hintStyle: TextStyle(color: Colors.grey),
            border: OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: CodeXColors.accentBlue)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                try {
                  await ref.read(projectServiceProvider).createFile(projectPath, controller.text);
                  ref.invalidate(currentProjectFilesProvider(projectPath));
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _importAsset(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(projectServiceProvider).importFile(projectPath);
      ref.invalidate(currentProjectFilesProvider(projectPath));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $e')),
      );
    }
  }
  Future<void> _showRenameFileDialog(BuildContext context, String currentName) async {
    final controller = TextEditingController(text: currentName);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename File'),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: CodeXColors.text),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: CodeXColors.accentBlue)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
               if (controller.text.isNotEmpty && controller.text != currentName) {
                 Navigator.pop(context);
                 onFileRename?.call(currentName, controller.text);
               }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }
}
