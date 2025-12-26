import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CodeXSettings {
  final double fontSize;
  final bool showLineNumbers;
  final bool wordWrap;

  CodeXSettings({
    this.fontSize = 14.0,
    this.showLineNumbers = true,
    this.wordWrap = false,
  });

  CodeXSettings copyWith({
    double? fontSize,
    bool? showLineNumbers,
    bool? wordWrap,
  }) {
    return CodeXSettings(
      fontSize: fontSize ?? this.fontSize,
      showLineNumbers: showLineNumbers ?? this.showLineNumbers,
      wordWrap: wordWrap ?? this.wordWrap,
    );
  }
}

class SettingsController extends Notifier<CodeXSettings> {
  @override
  CodeXSettings build() {
    return CodeXSettings();
  }

  void setFontSize(double size) {
    state = state.copyWith(fontSize: size);
  }

  void toggleLineNumbers(bool value) {
    state = state.copyWith(showLineNumbers: value);
  }

  void toggleWordWrap(bool value) {
    state = state.copyWith(wordWrap: value);
  }
}

final settingsProvider = NotifierProvider<SettingsController, CodeXSettings>(() {
  return SettingsController();
});
