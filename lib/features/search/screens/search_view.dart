import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class SearchView extends StatefulWidget {
  final Map<String, String> files;
  final String activeFile;
  final Function(String) onFileSelected;

  const SearchView({
    super.key,
    required this.files,
    required this.activeFile,
    required this.onFileSelected,
  });

  @override
  State<SearchView> createState() => _SearchViewState();
}

class SearchMatch {
  final int line;
  final String content;

  SearchMatch(this.line, this.content);
}

class FileMatch {
  final String fileName;
  final List<SearchMatch> matches;

  FileMatch(this.fileName, this.matches);
}

class _SearchViewState extends State<SearchView> {
  final _controller = TextEditingController();
  List<FileMatch> _results = [];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _controller.text.toLowerCase();
    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }

    List<FileMatch> newResults = [];
    widget.files.forEach((fileName, content) {
       // Skip binary or large files if needed, but for now just text check
       // Basic binary file check from earlier service was simple extension check.
       // Assuming Map passed here contains text content only (ProjectService does filtering).
       
       List<SearchMatch> matches = [];
       final lines = content.split('\n');
       for (var i = 0; i < lines.length; i++) {
         if (lines[i].toLowerCase().contains(query)) {
           // Limit line length for display
           String lineContent = lines[i].trim();
           if (lineContent.length > 100) lineContent = '${lineContent.substring(0, 100)}...';
           
           matches.add(SearchMatch(i + 1, lineContent));
           if (matches.length > 50) break; // Limit matches per file
         }
       }
       if (matches.isNotEmpty) {
         newResults.add(FileMatch(fileName, matches));
       }
    });

    setState(() => _results = newResults);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: CodeXColors.sidebar,
        border: Border(right: BorderSide(color: CodeXColors.border, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(
              'SEARCH',
              style: GoogleFonts.outfit(
                color: Colors.white.withOpacity(0.5),
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _controller,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search in files...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.03),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: CodeXColors.accentBlue, width: 1.5),
                ),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 16),
                        onPressed: _controller.clear,
                        color: Colors.white.withOpacity(0.3),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _controller.text.isEmpty
                ? _buildEmptyState('Type to search across all files')
                : _results.isEmpty
                    ? _buildEmptyState('No results found')
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 20),
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final fileMatch = _results[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFileHeader(fileMatch.fileName, fileMatch.matches.length),
                              ...fileMatch.matches.map((m) => _buildMatchItem(fileMatch.fileName, m)),
                              const SizedBox(height: 8),
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Text(
        message,
        style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.3), fontSize: 13),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildFileHeader(String fileName, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white.withOpacity(0.02),
      width: double.infinity,
      child: Row(
        children: [
          Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Colors.white.withOpacity(0.5)),
          const SizedBox(width: 8),
          Icon(_getFileIconData(fileName), size: 14, color: Colors.white.withOpacity(0.4)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              fileName,
              style: GoogleFonts.outfit(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: CodeXColors.accentBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              count.toString(),
              style: GoogleFonts.outfit(
                color: CodeXColors.accentBlue, 
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchItem(String fileName, SearchMatch match) {
    return InkWell(
      onTap: () => widget.onFileSelected(fileName),
      child: Container(
        padding: const EdgeInsets.only(left: 40, right: 16, top: 6, bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${match.line}',
              style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.25), fontSize: 11),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                match.content,
                style: const TextStyle(
                  color: Color(0xFFD4D4D4), 
                  fontSize: 12, 
                  fontFamily: 'FiraCode',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIconData(String fileName) {
    if (fileName.endsWith('.html')) return Icons.code;
    if (fileName.endsWith('.css')) return Icons.style;
    if (fileName.endsWith('.js')) return Icons.javascript;
    return Icons.insert_drive_file_outlined;
  }
}
