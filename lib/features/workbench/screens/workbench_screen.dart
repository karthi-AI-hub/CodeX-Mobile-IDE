import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/project_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../editor/controllers/editor_controller.dart';
import '../../editor/screens/editor_screen.dart';
import '../widgets/activity_bar.dart';
import '../widgets/side_bar.dart';
import '../widgets/status_bar.dart';
import '../../settings/screens/settings_view.dart';
import '../../search/screens/search_view.dart';

class WorkbenchScreen extends ConsumerStatefulWidget {
  final Project project;

  const WorkbenchScreen({super.key, required this.project});

  @override
  ConsumerState<WorkbenchScreen> createState() => _WorkbenchScreenState();
}

class _WorkbenchScreenState extends ConsumerState<WorkbenchScreen> {
  int _selectedIndex = 0; // 0: Explorer, 1: Search, 2: Settings

  @override
  Widget build(BuildContext context) {
    // We reuse the existing EditorController logic which also holds the file structure roughly?
    // Actually project files come from currentProjectFilesProvider
    final filesAsync = ref.watch(currentProjectFilesProvider(widget.project.path));
    final controller = ref.watch(editorControllerProvider(widget.project.path));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ActivityBar(
                    selectedIndex: _selectedIndex,
                    onIndexChanged: (index) {
                      setState(() {
                         if (index == 3) {
                           // Menu Icon toggles sidebar visibility
                           if (_selectedIndex == -1) {
                             _selectedIndex = 0; // Open Explorer by default
                           } else {
                             _selectedIndex = -1; // Close Sidebar
                           }
                         } else {
                           // Toggle behavior for other icons
                           if (_selectedIndex == index) {
                             _selectedIndex = -1;
                           } else {
                             _selectedIndex = index;
                           }
                         }
                      });
                    },
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile = constraints.maxWidth < 600;
                        
                        Widget? sideBarContent;
                        if (_selectedIndex == 0) {
                          sideBarContent = filesAsync.when(
                              data: (files) => SideBar(
                                files: files,
                                activeFile: controller.state.value.activeFile,
                                projectPath: widget.project.path,
                                onFileSelected: (file) {
                                  controller.openFile(file, files[file] ?? '');
                                  // Optional: Close sidebar on mobile on selection
                                  if (isMobile) {
                                    // setState(() => _selectedIndex = -1); 
                                    // Maybe keep it open for multi-file browse
                                  }
                                },
                                onFileRename: (oldName, newName) async {
                                  try {
                                    await ref.read(projectServiceProvider).renameFile(
                                      widget.project.path, 
                                      oldName, 
                                      newName
                                    );
                                    // Update editor state as well
                                    controller.renameFileInEditor(oldName, newName);
                                    
                                    // Refresh file list
                                    ref.invalidate(currentProjectFilesProvider(widget.project.path));
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Rename failed: $e')),
                                    );
                                  }
                                },
                              ),
                              loading: () => const SizedBox(width: 200, child: Center(child: CircularProgressIndicator())),
                              error: (_, __) => const SizedBox(width: 200),
                            );
                        } else if (_selectedIndex == 1) {
                          sideBarContent = filesAsync.when(
                            data: (files) => SearchView(
                              files: files,
                              activeFile: controller.state.value.activeFile,
                              onFileSelected: (file) {
                                controller.openFile(file, files[file] ?? '');
                                if (isMobile) {
                                  // setState(() => _selectedIndex = -1);
                                }
                              },
                            ),
                            loading: () => const SizedBox(width: 200, child: Center(child: CircularProgressIndicator())),
                            error: (_, __) => const SizedBox(width: 200),
                          );
                        } else if (_selectedIndex == 2) {
                          sideBarContent = const SettingsView();
                        }

                        // Editor Widget
                        final editor = EditorScreen(
                           project: widget.project,
                           isEmbedded: true,
                           onInteract: () {
                             if (_selectedIndex != -1) {
                               setState(() => _selectedIndex = -1);
                             }
                           },
                        );

                        const sidebarWidth = 220.0;

                        // Desktop: Row (SideBar + Editor)
                        if (!isMobile) {
                          return Row(
                            children: [
                              if (sideBarContent != null) 
                                SizedBox(width: sidebarWidth, child: sideBarContent),
                              Expanded(child: editor),
                            ],
                          );
                        }

                        // Mobile: Stack (Editor + Animated Overlay Sidebar)
                        return Stack(
                          children: [
                            editor, // Editor always fills the space
                            // Backdrop when sidebar is open on mobile
                            if (sideBarContent != null)
                              GestureDetector(
                                onTap: () => setState(() => _selectedIndex = -1),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  color: Colors.black.withOpacity(0.4),
                                ),
                              ),
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutQuart,
                              left: sideBarContent != null ? 0 : -sidebarWidth,
                              top: 0,
                              bottom: 0,
                              width: sidebarWidth,
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 15,
                                      offset: const Offset(5, 0),
                                    )
                                  ],
                                ),
                                child: sideBarContent ?? const SizedBox(),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            ValueListenableBuilder(
              valueListenable: controller.state,
              builder: (context, state, child) {
                return StatusBar(
                  activeFile: state.activeFile,
                  line: state.line,
                  column: state.column,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
