
---

### 📄 PART 1: Functional Requirements Document (FRD)

**Project Name:** CodeX Mobile: HTML/CSS/JS Editor
**Target Platform:** Android (Google Play Store Compliant)
**Tech Stack:** Flutter (Dart)

#### 1. Project Overview

CodeX Mobile is an offline-first mobile IDE designed to mimic the Visual Studio Code experience. It allows users to write HTML, CSS, and JavaScript, manage projects, and preview websites instantly using a local WebView. The app must strictly adhere to Android's **Scoped Storage** policies to ensure safety and Play Store approval.

#### 2. Functional Modules

**Module A: Dashboard (Project Management)**

* **Location:** Home Screen.
* **Behavior:**
* Display a list of projects (folders) stored in the **App’s Internal Directory** (`ApplicationDocumentsDirectory`).
* **Create Project:** Floating Action Button (+) opens a dialog to name a new project. Action creates a folder with `index.html`, `style.css`, and `script.js` pre-filled.
* **Delete Project:** Long-press to delete (must show confirmation dialog).



**Module B: The Editor (VS Code UI)**

* **UI Style:** Dark Theme (Hex: `#1E1E1E`). Font: `Fira Code` or `JetBrains Mono`.
* **Tabs System:** Top bar showing 3 fixed tabs (`index.html`, `style.css`, `script.js`). Tapping a tab switches the editor content instantly.
* **Editor Features:**
* Syntax Highlighting for HTML/CSS/JS (using `code_text_field` package).
* Line Numbers enabled.
* **Quick-Key Toolbar:** A horizontal scrollable bar *above* the keyboard containing keys: `< > / " ' = { } ;`.
* **Auto-Save:** Code saves to internal storage on every keystroke (debounced 1s).



**Module C: Live Preview (The Compiler)**

* **Trigger:** "Play" button in the UI.
* **Action:**
* Reads content from the 3 internal files.
* Injects CSS into `<style>` and JS into `<script>`.
* Loads the combined HTML string into a **WebView**.
* **Console Drawer:** A bottom sheet that captures and displays `console.log` messages from the WebView.



**Module D: File Import/Export (Scoped Storage Compliance)**

* **Import File:** Uses `FilePicker` to open the System Picker. Selected file is **copied** into the current project's internal folder.
* **Export Project:** Uses `archive` package to Zip the internal project folder. Uses `FilePicker.saveFile` to let the user save the Zip to their Downloads folder.
* **Policy Rule:** NEVER request `MANAGE_EXTERNAL_STORAGE`. All operations must use the System Picker.

#### 3. Non-Functional Requirements

* **Performance:** Editor must handle 1000+ lines of code without lag.
* **Offline:** App must function 100% without internet.
* **Security:** WebView must have JavaScript enabled but restrict navigation to external URLs (unless user confirmed).

---
