import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

class Project {
  final String name;
  final String path;
  final DateTime lastModified;

  Project({
    required this.name,
    required this.path,
    required this.lastModified,
  });
}

class ProjectService {
  Future<List<Project>> getProjects() async {
    final directory = await getApplicationDocumentsDirectory();
    final List<FileSystemEntity> entities = directory.listSync();
    
    return entities
        .whereType<Directory>()
        .where((dir) {
          final name = dir.path.split('/').last;
          return !name.startsWith('.') && name != 'flutter_assets';
        })
        .map((dir) => Project(
              name: dir.path.split('/').last,
              path: dir.path,
              lastModified: dir.statSync().modified,
            ))
        .toList()
      ..sort((a, b) => b.lastModified.compareTo(a.lastModified));
  }

  Future<void> createProject(String name) async {
    final directory = await getApplicationDocumentsDirectory();
    final projectDir = Directory('${directory.path}/$name');
    
    if (await projectDir.exists()) {
      throw Exception('Project already exists');
    }

    await projectDir.create();

    // Create boilerplate files
    await File('${projectDir.path}/index.html').writeAsString('''<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$name</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <h1>Welcome to $name</h1>
    <p>Start coding with CodeX Mobile!</p>
    <script src="script.js"></script>
</body>
</html>''');

    await File('${projectDir.path}/style.css').writeAsString('''body {
    background-color: #1e1e1e;
    color: #d4d4d4;
    font-family: sans-serif;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    height: 100vh;
    margin: 0;
}

h1 {
    color: #007acc;
}''');

    await File('${projectDir.path}/script.js').writeAsString('''console.log("Hello from $name!");
// Add your JavaScript here''');
  }

  Future<void> deleteProject(String path) async {
    final dir = Directory(path);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
      if (await dir.exists()) {
        throw Exception('Failed to delete project directory');
      }
    }
  }

  Future<String> readFile(String projectPath, String fileName) async {
    final file = File('$projectPath/$fileName');
    if (await file.exists()) {
      return await file.readAsString();
    }
    return '';
  }

  Future<void> writeFile(String projectPath, String fileName, String content) async {
    final file = File('$projectPath/$fileName');
    await file.writeAsString(content);
  }

  Future<void> createFile(String projectPath, String fileName) async {
    final file = File('$projectPath/$fileName');
    if (await file.exists()) {
      throw Exception('File already exists');
    }
    await file.create();
  }

  Future<void> deleteFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    } else {
       final dir = Directory(filePath);
       if (await dir.exists()) {
         await dir.delete(recursive: true);
       }
    }
  }

  Future<void> renameFile(String projectPath, String oldName, String newName) async {
    final oldFile = File('$projectPath/$oldName');
    final newFile = File('$projectPath/$newName');

    if (await newFile.exists()) {
      throw Exception('File with this name already exists');
    }

    if (await oldFile.exists()) {
      await oldFile.rename(newFile.path);
    }
  }


  Future<void> importFile(String projectPath) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['html', 'css', 'js', 'png', 'jpg', 'jpeg'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;
      await file.copy('$projectPath/$fileName');
    }
  }

  Future<bool> checkFirstRun() async {
    final directory = await getApplicationDocumentsDirectory();
    final configFile = File('${directory.path}/.codex_config');
    if (await configFile.exists()) {
      return false;
    }
    return true;
  }

  Future<void> completeOnboarding() async {
    final directory = await getApplicationDocumentsDirectory();
    final configFile = File('${directory.path}/.codex_config');
    await configFile.writeAsString('onboarding_completed=true');
  }
}

final projectServiceProvider = Provider((ref) => ProjectService());

final projectsProvider = FutureProvider<List<Project>>((ref) async {
  final service = ref.watch(projectServiceProvider);
  return service.getProjects();
});

final currentProjectFilesProvider = FutureProvider.family<Map<String, String>, String>((ref, projectPath) async {
  final dir = Directory(projectPath);
  final Map<String, String> projectFiles = {};
  
  if (await dir.exists()) {
    final entities = await dir.list().toList();
    for (var entity in entities) {
      if (entity is File) {
        final fileName = entity.path.split('/').last;
        // Simple check for text files to read content
        if (fileName.endsWith('.html') || 
            fileName.endsWith('.css') || 
            fileName.endsWith('.js') || 
            fileName.endsWith('.txt') ||
            fileName.endsWith('.json') ||
            fileName.endsWith('.md') ||
            fileName.endsWith('.xml')) {
           try {
             projectFiles[fileName] = await entity.readAsString();
           } catch (e) {
             projectFiles[fileName] = 'Error reading file';
           }
        } else {
          // Identify binary files or others
          projectFiles[fileName] = '[Binary File]';
        }
      }
    }
  }
  return projectFiles;
});
