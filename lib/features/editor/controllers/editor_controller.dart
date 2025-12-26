import 'dart:async';
import 'package:flutter/material.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:highlight/languages/css.dart';
import 'package:highlight/languages/xml.dart';
import '../../../core/services/project_service.dart';
import 'package:highlight/languages/all.dart'; 

final editorControllerProvider = Provider.family<EditorController, String>((ref, projectPath) {
  final controller = EditorController(ref, projectPath);
  ref.onDispose(() => controller.dispose());
  return controller;
});

class EditorState {
  final Map<String, CodeController> controllers;
  final String activeFile;
  final bool isSaving;
  final int line;
  final int column;
  final Set<String> closedFiles;

  EditorState({
    required this.controllers,
    this.activeFile = 'index.html',
    this.isSaving = false,
    this.line = 1,
    this.column = 1,
    this.closedFiles = const {},
  });

  EditorState copyWith({
    Map<String, CodeController>? controllers,
    String? activeFile,
    bool? isSaving,
    int? line,
    int? column,
    Set<String>? closedFiles,
  }) {
    return EditorState(
      controllers: controllers ?? this.controllers,
      activeFile: activeFile ?? this.activeFile,
      isSaving: isSaving ?? this.isSaving,
      line: line ?? this.line,
      column: column ?? this.column,
      closedFiles: closedFiles ?? this.closedFiles,
    );
  }
}

class EditorController {
  final Ref _ref;
  final String _projectPath;
  Timer? _debounceTimer;

  final ValueNotifier<EditorState> state;

  EditorController(this._ref, this._projectPath)
      : state = ValueNotifier(EditorState(controllers: {}));

  void init(Map<String, String> files) {
    final currentControllers = Map<String, CodeController>.from(state.value.controllers);
    bool changed = false;

    files.forEach((fileName, content) {
      // Only add if not closed and not already present
      if (!state.value.closedFiles.contains(fileName) && !currentControllers.containsKey(fileName)) {
        // Create new controller for this file
        final controller = CodeController(
          text: content,
          language: _getHighlightLanguage(fileName),
        );
        
        // Add listeners
        controller.addListener(() {
          _onTextChanged(fileName, controller.text);
          if (state.value.activeFile == fileName) {
            _updateCursorPosition(controller);
          }
        });
        
        currentControllers[fileName] = controller;
        changed = true;
      }
    });

    if (changed) {
      state.value = state.value.copyWith(controllers: currentControllers);
    }
  }

  dynamic _getHighlightLanguage(String fileName) {
     if (fileName.endsWith('.html')) return xml;
     if (fileName.endsWith('.css')) return css;
     if (fileName.endsWith('.js')) return javascript;
     return null; // Plain text
  }

  void openFile(String fileName, String content) {
    // Remove from closed files if present
    final newClosedFiles = Set<String>.from(state.value.closedFiles)..remove(fileName);
    
    final currentControllers = Map<String, CodeController>.from(state.value.controllers);
    
    // Add controller if missing
    if (!currentControllers.containsKey(fileName)) {
      final controller = CodeController(
        text: content,
        language: _getHighlightLanguage(fileName),
      );
      
      controller.addListener(() {
        _onTextChanged(fileName, controller.text);
        if (state.value.activeFile == fileName) {
          _updateCursorPosition(controller);
        }
      });
      
      currentControllers[fileName] = controller;
    }

    state.value = state.value.copyWith(
      controllers: currentControllers,
      closedFiles: newClosedFiles,
      activeFile: fileName,
    );
    
    // Update cursor for new active file
    if (currentControllers.containsKey(fileName)) {
      _updateCursorPosition(currentControllers[fileName]!);
    }
  }

  void switchTab(String fileName) {
    state.value = state.value.copyWith(activeFile: fileName);
    // Update cursor position for the new active file
    final controller = state.value.controllers[fileName];
    if (controller != null) {
      _updateCursorPosition(controller);
    }
  }

  void closeFile(String fileName) {
    if (!state.value.controllers.containsKey(fileName)) return;

    final newControllers = Map<String, CodeController>.from(state.value.controllers);
    final controller = newControllers.remove(fileName);
    controller?.dispose();
    
    final newClosedFiles = Set<String>.from(state.value.closedFiles)..add(fileName);

    String newActiveFile = state.value.activeFile;
    if (state.value.activeFile == fileName) {
      if (newControllers.isNotEmpty) {
        newActiveFile = newControllers.keys.last;
        final newController = newControllers[newActiveFile];
        if (newController != null) {
           _updateCursorPosition(newController);
        }
      } else {
        newActiveFile = '';
      }
    }

    state.value = state.value.copyWith(
      controllers: newControllers,
      activeFile: newActiveFile,
      closedFiles: newClosedFiles,
    );
  }

  void renameFileInEditor(String oldName, String newName) {
    final newControllers = Map<String, CodeController>.from(state.value.controllers);
    final newClosedFiles = Set<String>.from(state.value.closedFiles);
    String newActiveFile = state.value.activeFile;

    // Update controllers
    if (newControllers.containsKey(oldName)) {
      final controller = newControllers.remove(oldName)!;
      // Update language for syntax highlighting
      controller.language = _getHighlightLanguage(newName);
      newControllers[newName] = controller;
    }

    // Update closed files
    if (newClosedFiles.contains(oldName)) {
      newClosedFiles.remove(oldName);
      newClosedFiles.add(newName);
    }

    // Update active file
    if (newActiveFile == oldName) {
      newActiveFile = newName;
    }

    state.value = state.value.copyWith(
      controllers: newControllers,
      closedFiles: newClosedFiles,
      activeFile: newActiveFile,
    );
  }

  void _updateCursorPosition(CodeController controller) {
    final selection = controller.selection;
    if (selection.baseOffset == -1) return;

    final text = controller.text;
    final String beforeCursor = text.substring(0, selection.baseOffset);
    final int line = beforeCursor.split('\n').length;
    final int column = beforeCursor.split('\n').last.length + 1;

    state.value = state.value.copyWith(line: line, column: column);
  }

  void _onTextChanged(String fileName, String content) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 1), () {
      _saveFile(fileName, content);
    });
  }

  Future<void> _saveFile(String fileName, String content) async {
    state.value = state.value.copyWith(isSaving: true);
    try {
      await _ref.read(projectServiceProvider).writeFile(_projectPath, fileName, content);
    } finally {
      state.value = state.value.copyWith(isSaving: false);
    }
  }

  void dispose() {
    _debounceTimer?.cancel();
    for (var controller in state.value.controllers.values) {
      controller.dispose();
    }
    state.dispose();
  }
}
