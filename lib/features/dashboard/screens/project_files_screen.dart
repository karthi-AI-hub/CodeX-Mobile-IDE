import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/project_service.dart';
import '../../../core/theme/app_theme.dart';

class ProjectFilesScreen extends ConsumerStatefulWidget {
  final Project project;

  const ProjectFilesScreen({super.key, required this.project});

  @override
  ConsumerState<ProjectFilesScreen> createState() => _ProjectFilesScreenState();
}

class _ProjectFilesScreenState extends ConsumerState<ProjectFilesScreen> {
  @override
  Widget build(BuildContext context) {
    final filesAsync = ref.watch(currentProjectFilesProvider(widget.project.path));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Project Files',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          _buildAppBarAction(
            icon: Icons.upload_file_rounded,
            tooltip: 'Import',
            onTap: () => _importFile(context, ref),
          ),
          _buildAppBarAction(
            icon: Icons.note_add_rounded,
            tooltip: 'New File',
            onTap: () => _showCreateFileDialog(context, ref),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: filesAsync.when(
        data: (files) => files.isEmpty
            ? _buildEmptyState()
            : _buildFileList(files),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent)),
        ),
      ),
    );
  }

  Widget _buildAppBarAction({required IconData icon, required String tooltip, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        tooltip: tooltip,
        onPressed: onTap,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_rounded, size: 80, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 24),
          Text(
            'No Files Yet',
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.9)),
          ),
          const SizedBox(height: 12),
          Text(
            'Add files to your project to start coding.',
            style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildFileList(Map<String, String> files) {
    final sortedKeys = files.keys.toList()..sort();
    return ListView.builder(
      itemCount: sortedKeys.length,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemBuilder: (context, index) {
        final fileName = sortedKeys[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _getFileIcon(fileName),
              ),
              title: Text(
                fileName,
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.white),
              ),
              subtitle: Text(
                _getFileTypeLabel(fileName),
                style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
              ),
              onTap: () => _showRenameFileDialog(context, fileName),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                onPressed: () => _confirmDeleteFile(context, fileName),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getFileTypeLabel(String fileName) {
    if (fileName.endsWith('.html')) return 'HTML Document';
    if (fileName.endsWith('.css')) return 'Style Sheet';
    if (fileName.endsWith('.js')) return 'JavaScript File';
    if (fileName.endsWith('.png') || fileName.endsWith('.jpg')) return 'Image Asset';
    return 'Text File';
  }

  Icon _getFileIcon(String fileName) {
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
    return Icon(icon, color: color);
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
                  await ref.read(projectServiceProvider).createFile(widget.project.path, controller.text);
                  ref.invalidate(currentProjectFilesProvider(widget.project.path));
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

  Future<void> _confirmDeleteFile(BuildContext context, String fileName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: Text('Are you sure you want to delete "$fileName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(projectServiceProvider).deleteFile('${widget.project.path}/$fileName');
        ref.invalidate(currentProjectFilesProvider(widget.project.path));
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Delete failed: $e')),
          );
        }
      }
    }
  }

  Future<void> _importFile(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(projectServiceProvider).importFile(widget.project.path);
      ref.invalidate(currentProjectFilesProvider(widget.project.path));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File imported successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
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
            onPressed: () async {
               if (controller.text.isNotEmpty && controller.text != currentName) {
                 try {
                   await ref.read(projectServiceProvider).renameFile(widget.project.path, currentName, controller.text);
                   ref.invalidate(currentProjectFilesProvider(widget.project.path));
                   if (context.mounted) Navigator.pop(context);
                 } catch (e) {
                   if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Rename failed: $e')));
                   }
                 }
               }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }
}
