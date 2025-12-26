import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:code_text_field/code_text_field.dart';
import '../controllers/editor_controller.dart';
import '../../../core/services/project_service.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/quick_key_toolbar.dart';
import '../../preview/screens/preview_screen.dart';
import '../../settings/providers/settings_provider.dart';

class EditorScreen extends ConsumerStatefulWidget {
  final Project project;
  final bool isEmbedded;
  final VoidCallback? onInteract;

  const EditorScreen({
    super.key,
    required this.project,
    this.isEmbedded = false,
    this.onInteract,
  });

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  @override
  Widget build(BuildContext context) {
    final filesAsync = ref.watch(currentProjectFilesProvider(widget.project.path));
    final controller = ref.watch(editorControllerProvider(widget.project.path));
    final settings = ref.watch(settingsProvider);

    // Listen for file changes
    ref.listen(currentProjectFilesProvider(widget.project.path), (previous, next) {
      next.whenData((files) {
        controller.init(files);
      });
    });

    final content = filesAsync.when(
      data: (files) {
        // Initial hydration
        if (controller.state.value.controllers.isEmpty && controller.state.value.closedFiles.isEmpty) {
           WidgetsBinding.instance.addPostFrameCallback((_) {
             controller.init(files);
           });
        }
        
        return ValueListenableBuilder<EditorState>(
          valueListenable: controller.state,
          builder: (context, state, child) {
            if (state.controllers.isEmpty) {
               return const Center(child: Text('No file is open', style: TextStyle(color: Colors.grey)));
            }
            
            // Handle case where activeFile is empty or invalid
            if (state.activeFile.isEmpty || !state.controllers.containsKey(state.activeFile)) {
               return const Center(child: Text('No file selected', style: TextStyle(color: Colors.grey)));
            }

            Widget editorContent;
            final fileName = state.activeFile;
            if (fileName.endsWith('.png') || fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')) {
              editorContent = Center(
                child: Image.file(
                  File('${widget.project.path}/$fileName'),
                  key: ValueKey(fileName), 
                  fit: BoxFit.contain,
                ),
              );
            } else {
              editorContent = CodeField(
                controller: state.controllers[state.activeFile]!,
                textStyle: TextStyle(fontFamily: 'FiraCode', fontSize: settings.fontSize),
                lineNumberStyle: LineNumberStyle(
                  width: settings.showLineNumbers ? 45 : 0,
                  textAlign: TextAlign.right,
                  margin: 10,
                  textStyle: TextStyle(
                    color: Colors.grey, 
                    fontSize: settings.fontSize - 2,
                    height: 1.0, 
                  ),
                ),
                wrap: settings.wordWrap,
                expands: true,
              );
            }

            return Listener(
              onPointerDown: (_) => widget.onInteract?.call(),
              behavior: HitTestBehavior.translucent,
              child: Column(
                children: [
                  _buildTabBar(state, controller),
                  Expanded(
                    child: Container(
                      color: CodeXColors.background,
                      child: editorContent,
                    ),
                  ),
                  QuickKeyToolbar(
                    onKeyTap: (key) {
                      final activeController = state.controllers[state.activeFile];
                      if (activeController != null) {
                         final currentText = activeController.text;
                         final selection = activeController.selection;
                         if (selection.isValid && selection.start >= 0) {
                           final newText = currentText.replaceRange(selection.start, selection.end, key);
                           activeController.value = TextEditingValue(
                             text: newText,
                             selection: TextSelection.collapsed(offset: selection.start + key.length),
                           );
                         }
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );

    if (widget.isEmbedded) {
      return Column(
        children: [
          _buildCustomHeader(controller),
          Expanded(child: content),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.name),
        actions: _buildActions(controller),
      ),
      body: content,
    );
  }

  // ... (mid section unchanged)


  Widget _buildCustomHeader(EditorController controller) {
    return Container(
      height: 54, // Match ActivityBar height
      decoration: const BoxDecoration(
        color: CodeXColors.header,
        border: Border(bottom: BorderSide(color: CodeXColors.border, width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              widget.project.name,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Row(mainAxisSize: MainAxisSize.min, children: _buildActions(controller)),
        ],
      ),
    );
  }

  List<Widget> _buildActions(EditorController controller) {
    return [
      ValueListenableBuilder(
        valueListenable: controller.state,
        builder: (context, state, child) {
          if (state.isSaving) {
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2, color: CodeXColors.accentBlue),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      _buildHeaderIcon(
        icon: Icons.rocket_launch_rounded,
        color: Colors.greenAccent,
        onPressed: () {
          final state = controller.state.value;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PreviewScreen(
                html: state.controllers['index.html']?.text ?? '',
                css: state.controllers['style.css']?.text ?? '',
                js: state.controllers['script.js']?.text ?? '',
              ),
            ),
          );
        },
      ),
      _buildHeaderIcon(
        icon: Icons.upload_file_rounded,
        color: Colors.white.withOpacity(0.7),
        onPressed: () async {
          try {
            await ref.read(projectServiceProvider).importFile(widget.project.path);
            ref.invalidate(currentProjectFilesProvider(widget.project.path));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('File imported successfully')),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Import failed: $e')),
            );
          }
        },
      ),
    ];
  }

  Widget _buildHeaderIcon({required IconData icon, required Color color, required VoidCallback onPressed}) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 20),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildTabBar(EditorState state, EditorController controller) {
    if (state.controllers.isEmpty) return const SizedBox.shrink();
    
    final tabs = state.controllers.keys.toList()..sort();
    
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        color: CodeXColors.header,
        border: Border(bottom: BorderSide(color: CodeXColors.border, width: 0.5)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final isActive = state.activeFile == tab;
          return InkWell(
            onTap: () => controller.switchTab(tab),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive ? CodeXColors.background : Colors.transparent,
                border: Border(
                  bottom: BorderSide(
                    color: isActive ? CodeXColors.accentBlue : Colors.transparent,
                    width: 2,
                  ),
                  right: const BorderSide(color: CodeXColors.border, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  _getFileIcon(tab),
                  const SizedBox(width: 8),
                  Text(
                    tab,
                    style: GoogleFonts.outfit(
                      color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                  if (isActive) ...[
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => controller.closeFile(tab),
                      child: Icon(Icons.close_rounded, size: 14, color: Colors.white.withOpacity(0.5)),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
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

    return Icon(icon, size: 14, color: color);
  }
}
