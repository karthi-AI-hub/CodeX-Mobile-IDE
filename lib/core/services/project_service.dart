import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    }
  }
}

final projectServiceProvider = Provider((ref) => ProjectService());

final projectsProvider = FutureProvider<List<Project>>((ref) async {
  final service = ref.watch(projectServiceProvider);
  return service.getProjects();
});
