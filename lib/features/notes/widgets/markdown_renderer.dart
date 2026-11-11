import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';

class MarkdownRenderer extends StatelessWidget {
  final String content;
  final bool isZenMode;

  const MarkdownRenderer({
    super.key,
    required this.content,
    this.isZenMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final blocks = _parseBlocks(content);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks.map((block) => _buildBlock(context, block)).toList(),
    );
  }

  List<_MdBlock> _parseBlocks(String text) {
    final List<_MdBlock> blocks = [];
    final lines = text.split('\n');

    int i = 0;
    while (i < lines.length) {
      final line = lines[i];

      // Check for Code Block: ```language
      if (line.trim().startsWith('```')) {
        final lang = line.trim().replaceAll('```', '').trim();
        final codeLines = <String>[];
        i++;
        while (i < lines.length && !lines[i].trim().startsWith('```')) {
          codeLines.add(lines[i]);
          i++;
        }
        blocks.add(
          _MdBlock(
            type: _MdBlockType.code,
            content: codeLines.join('\n'),
            extra: lang.isNotEmpty ? lang : 'code',
          ),
        );
        i++;
        continue;
      }

      // Check for Headings
      if (line.startsWith('# ')) {
        blocks.add(_MdBlock(type: _MdBlockType.h1, content: line.substring(2)));
      } else if (line.startsWith('## ')) {
        blocks.add(_MdBlock(type: _MdBlockType.h2, content: line.substring(3)));
      } else if (line.startsWith('### ')) {
        blocks.add(_MdBlock(type: _MdBlockType.h3, content: line.substring(4)));
      } else if (line.startsWith('#### ')) {
        blocks.add(_MdBlock(type: _MdBlockType.h4, content: line.substring(5)));
      }
      // Check for Blockquote
      else if (line.startsWith('> ')) {
        blocks.add(
          _MdBlock(type: _MdBlockType.quote, content: line.substring(2)),
        );
      }
      // Check for Bullet points
      else if (line.trim().startsWith('* ') || line.trim().startsWith('- ')) {
        blocks.add(
          _MdBlock(
            type: _MdBlockType.bullet,
            content: line.trim().substring(2),
          ),
        );
      }
      // Check for Numbered lists: 1. Item
      else if (RegExp(r'^\d+\.\s').hasMatch(line.trim())) {
        final match = RegExp(r'^(\d+)\.\s(.*)$').firstMatch(line.trim());
        if (match != null) {
          blocks.add(
            _MdBlock(
              type: _MdBlockType.numbered,
              content: match.group(2) ?? '',
              extra: match.group(1),
            ),
          );
        }
      }
      // Regular Paragraph or empty line
      else {
        if (line.trim().isNotEmpty) {
          blocks.add(_MdBlock(type: _MdBlockType.paragraph, content: line));
        } else {
          blocks.add(_MdBlock(type: _MdBlockType.space, content: ''));
        }
      }
      i++;
    }

    return blocks;
  }

  Widget _buildBlock(BuildContext context, _MdBlock block) {
    switch (block.type) {
      case _MdBlockType.h1:
        return Padding(
          padding: const EdgeInsets.only(top: 18.0, bottom: 8.0),
          child: Text(
            block.content,
            style: GoogleFonts.inter(
              color: AppColors.figmaTextRed,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),
        );

      case _MdBlockType.h2:
        return Padding(
          padding: const EdgeInsets.only(top: 14.0, bottom: 6.0),
          child: Text(
            block.content,
            style: GoogleFonts.inter(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        );

      case _MdBlockType.h3:
        return Padding(
          padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
          child: Text(
            block.content,
            style: GoogleFonts.inter(
              color: const Color(0xFF1B1B1B),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        );

      case _MdBlockType.h4:
        return Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
          child: Text(
            block.content,
            style: GoogleFonts.jetBrainsMono(
              color: AppColors.figmaMaroonText,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        );

      case _MdBlockType.quote:
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: const Color(0xFFEFE8E8),
            borderRadius: BorderRadius.circular(6),
            border: const Border(
              left: BorderSide(color: AppColors.figmaBottomNav, width: 3.5),
            ),
          ),
          child: _buildInlineRichText(block.content, isItalic: true),
        );

      case _MdBlockType.bullet:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 6, right: 8),
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: AppColors.figmaBottomNav,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(child: _buildInlineRichText(block.content)),
            ],
          ),
        );

      case _MdBlockType.numbered:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 22,
                child: Text(
                  '${block.extra}.',
                  style: GoogleFonts.jetBrainsMono(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AppColors.figmaBottomNav,
                  ),
                ),
              ),
              Expanded(child: _buildInlineRichText(block.content)),
            ],
          ),
        );

      case _MdBlockType.code:
        return _buildCodeSnippet(context, block.content, block.extra ?? 'code');

      case _MdBlockType.paragraph:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: _buildInlineRichText(block.content),
        );

      case _MdBlockType.space:
        return const SizedBox(height: 6);
    }
  }

  Widget _buildCodeSnippet(BuildContext context, String code, String language) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        color: const Color(0xFF181B20),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF333333), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Code Terminal Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: const BoxDecoration(
              color: Color(0xFF101216),
              borderRadius: BorderRadius.vertical(top: Radius.circular(9)),
              border: Border(
                bottom: BorderSide(color: Color(0xFF282C34), width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF5F56),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFBD2E),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: Color(0xFF27C93F),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF202530),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Text(
                        language.toUpperCase(),
                        style: GoogleFonts.jetBrainsMono(
                          color: const Color(0xFFD6BCFA),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Copied $language snippet to clipboard!'),
                        backgroundColor: AppColors.figmaCodeBadge,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.copy_rounded,
                          color: Colors.white70,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'COPY',
                          style: GoogleFonts.jetBrainsMono(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Code Body with Syntax Coloring
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(14.0),
            child: _buildSyntaxHighlightedText(code, language),
          ),
        ],
      ),
    );
  }

  Widget _buildSyntaxHighlightedText(String code, String lang) {
    final lines = code.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        return RichText(
          text: TextSpan(
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              height: 1.45,
              color: const Color(0xFFE2E8F0),
            ),
            children: _highlightLine(line, lang.toLowerCase()),
          ),
        );
      }).toList(),
    );
  }

  List<TextSpan> _highlightLine(String line, String lang) {
    final spans = <TextSpan>[];

    // Check for comment
    final commentPrefix = (lang == 'python' || lang == 'bash')
        ? '#'
        : (lang == 'sql' ? '--' : '//');

    if (line.trim().startsWith(commentPrefix)) {
      return [
        TextSpan(
          text: line,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontStyle: FontStyle.italic,
          ),
        ),
      ];
    }

    final words = line.split(RegExp(r'(\s+|[(),;{}[\]])'));
    int lastIdx = 0;

    for (final word in words) {
      if (word.isEmpty) continue;
      final idx = line.indexOf(word, lastIdx);
      if (idx > lastIdx) {
        spans.add(TextSpan(text: line.substring(lastIdx, idx)));
      }

      Color wordColor = const Color(0xFFE2E8F0);
      FontWeight weight = FontWeight.normal;

      final lower = word.toLowerCase();
      // Keywords
      if ({
        'void',
        'int',
        'class',
        'struct',
        'def',
        'return',
        'if',
        'else',
        'while',
        'for',
        'switch',
        'case',
        'break',
        'import',
        'from',
        'package',
        'public',
        'static',
        'final',
        'const',
        'select',
        'update',
        'insert',
        'delete',
        'where',
        'set',
        'into',
        'values',
        'create',
        'table',
        'policy',
        'alter',
        'enable',
        'using',
        'check',
        'true',
        'false',
        'null',
        'nullptr',
      }.contains(lower)) {
        wordColor = const Color(0xFF38BDF8); // Cyan
        weight = FontWeight.bold;
      }
      // Types & Classes
      else if (RegExp(r'^[A-Z][a-zA-Z0-9]*$').hasMatch(word)) {
        wordColor = const Color(0xFFFBBF24); // Amber / Yellow
        weight = FontWeight.w600;
      }
      // String Literals
      else if (word.startsWith("'") ||
          word.startsWith('"') ||
          word.endsWith("'") ||
          word.endsWith('"')) {
        wordColor = const Color(0xFF34D399); // Emerald
      }
      // Numbers
      else if (RegExp(r'^\d+(\.\d+)?$').hasMatch(word)) {
        wordColor = const Color(0xFFF472B6); // Pink
      }

      spans.add(
        TextSpan(
          text: word,
          style: TextStyle(color: wordColor, fontWeight: weight),
        ),
      );

      lastIdx = idx + word.length;
    }

    if (lastIdx < line.length) {
      spans.add(TextSpan(text: line.substring(lastIdx)));
    }

    return spans.isNotEmpty ? spans : [TextSpan(text: line)];
  }

  Widget _buildInlineRichText(String text, {bool isItalic = false}) {
    final spans = <InlineSpan>[];
    int start = 0;
    final matches = RegExp(r'(\*\*.*?\*\*|\*.*?\*|`.*?`)').allMatches(text);

    for (final match in matches) {
      if (match.start > start) {
        spans.add(
          TextSpan(
            text: text.substring(start, match.start),
            style: GoogleFonts.inter(
              color: Colors.black87,
              fontSize: 13,
              height: 1.5,
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        );
      }

      final token = match.group(0)!;
      if (token.startsWith('**') && token.endsWith('**')) {
        spans.add(
          TextSpan(
            text: token.substring(2, token.length - 2),
            style: GoogleFonts.inter(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        );
      } else if (token.startsWith('*') && token.endsWith('*')) {
        spans.add(
          TextSpan(
            text: token.substring(1, token.length - 1),
            style: GoogleFonts.inter(
              color: Colors.black87,
              fontStyle: FontStyle.italic,
              fontSize: 13,
            ),
          ),
        );
      } else if (token.startsWith('`') && token.endsWith('`')) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2E37),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                token.substring(1, token.length - 1),
                style: GoogleFonts.jetBrainsMono(
                  color: const Color(0xFF67E8F9),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }

      start = match.end;
    }

    if (start < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(start),
          style: GoogleFonts.inter(
            color: Colors.black87,
            fontSize: 13,
            height: 1.5,
            fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      );
    }

    return Text.rich(TextSpan(children: spans));
  }
}

enum _MdBlockType {
  h1,
  h2,
  h3,
  h4,
  quote,
  bullet,
  numbered,
  code,
  paragraph,
  space,
}

class _MdBlock {
  final _MdBlockType type;
  final String content;
  final String? extra;

  _MdBlock({required this.type, required this.content, this.extra});
}
