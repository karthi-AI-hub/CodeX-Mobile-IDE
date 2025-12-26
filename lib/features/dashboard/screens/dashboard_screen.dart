import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/project_service.dart';
import '../../../core/theme/app_theme.dart';
import 'project_files_screen.dart';
import '../../settings/screens/settings_view.dart';
import '../../workbench/screens/workbench_screen.dart';

import '../../onboarding/screens/onboarding_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstRun();
    });
  }

  Future<void> _checkFirstRun() async {
    final isFirstRun = await ref.read(projectServiceProvider).checkFirstRun();
    if (isFirstRun && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CodeX : Mobile IDE',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.settings_rounded, size: 22),
              onPressed: () => _showSettings(context),
            ),
          ),
        ],
      ),
      body: projectsAsync.when(
        data: (projects) => projects.isEmpty
            ? _buildEmptyState(context, ref)
            : _buildProjectList(projects),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent)),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateProjectDialog(context, ref),
        backgroundColor: CodeXColors.accentBlue,
        elevation: 8,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'New Project',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: CodeXColors.sidebar,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 340,
            height: 500,
            color: CodeXColors.sidebar,
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.white.withOpacity(0.03),
                  elevation: 0,
                  title: Text('App Settings', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600)),
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Expanded(child: SettingsView()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: CodeXColors.accentBlue.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome_mosaic_rounded,
              size: 80,
              color: CodeXColors.accentBlue.withAlpha(100),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'No Projects Found',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Create your first project to start\nbuilding modern web apps.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: Colors.grey,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () => _showCreateProjectDialog(context, ref),
            icon: const Icon(Icons.add_rounded),
            label: const Text('New Project'),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectList(List<Project> projects) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WorkbenchScreen(project: project)),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: CodeXColors.accentBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.folder_rounded,
                        color: CodeXColors.accentBlue,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.name,
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Modified • ${project.lastModified.toString().split(' ').first}',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildActionIcon(
                          icon: Icons.snippet_folder_rounded,
                          color: Colors.white.withOpacity(0.4),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProjectFilesScreen(project: project),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 4),
                        _buildActionIcon(
                          icon: Icons.delete_outline_rounded,
                          color: Colors.redAccent.withOpacity(0.6),
                          onPressed: () => _showDeleteConfirmDialog(context, ref, project),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 20),
        onPressed: onPressed,
      ),
    );
  }

  void _showCreateProjectDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Project'),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: CodeXColors.text),
          decoration: const InputDecoration(
            hintText: 'Project Name',
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
                  await ref.read(projectServiceProvider).createProject(controller.text);
                  ref.invalidate(projectsProvider);
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

  void _showDeleteConfirmDialog(BuildContext context, WidgetRef ref, Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text('Are you sure you want to delete "${project.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () async {
              try {
                await ref.read(projectServiceProvider).deleteProject(project.path);
                ref.invalidate(projectsProvider);
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) {
                   Navigator.pop(context);
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
