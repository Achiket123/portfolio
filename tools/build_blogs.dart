//
// Each .md file must start with YAML-like frontmatter between --- delimiters:
//
//   ---
//   title: My Post Title
//   date: 2026-05-09
//   description: A short summary shown on the card.
//   tags: go, backend, performance
//   ---
//
// The body below the second --- is the blog content in Markdown.
// The script computes reading time automatically (200 wpm average).
// Output: tool/blog_registry.json - commit this file so your server can serve it.

import 'dart:convert';
import 'dart:io';

const int wordsPerMinute = 200;

void main() async {
  final blogsDir = Directory('blogs');

  if (!await blogsDir.exists()) {
    stderr.writeln('blogs/ directory not found. Create it next to pubspec.yaml.');
    exit(1);
  }

  final files = await blogsDir.list().where((e) => e is File && e.path.endsWith('.md')).cast<File>().toList();

  if (files.isEmpty) {
    stderr.writeln('No .md files found in blogs/');
    exit(0);
  }

  final posts = <Map<String, dynamic>>[];

  for (final file in files) {
    final raw = await file.readAsString();
    final parsed = _parseFrontmatter(raw, file.path);
    if (parsed != null) posts.add(parsed);
  }

  posts.sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));

  final outFile = File('tool/blog_registry.json');
  await outFile.create(recursive: true);
  await outFile.writeAsString(const JsonEncoder.withIndent('  ').convert(posts));

  stdout.writeln('Generated tool/blog_registry.json with ${posts.length} post(s).');
}

Map<String, dynamic>? _parseFrontmatter(String raw, String filePath) {
  final lines = raw.split('\n');

  if (lines.isEmpty || lines[0].trim() != '---') {
    stderr.writeln('Skipping $filePath: missing opening ---');
    return null;
  }

  final closeIndex = lines.indexWhere((l) => l.trim() == '---', 1);
  if (closeIndex == -1) {
    stderr.writeln('Skipping $filePath: missing closing ---');
    return null;
  }

  final frontmatterLines = lines.sublist(1, closeIndex);
  final content = lines.sublist(closeIndex + 1).join('\n').trim();

  final meta = <String, String>{};
  for (final line in frontmatterLines) {
    final colon = line.indexOf(':');
    if (colon == -1) continue;
    final key = line.substring(0, colon).trim();
    final value = line.substring(colon + 1).trim();
    meta[key] = value;
  }

  final title = meta['title'];
  final date = meta['date'];
  final description = meta['description'];
  final tagsRaw = meta['tags'] ?? '';

  if (title == null || date == null || description == null) {
    stderr.writeln('Skipping $filePath: frontmatter must include title, date, description.');
    return null;
  }

  final tags = tagsRaw.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();

  final wordCount = content.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  final readingTime = (wordCount / wordsPerMinute).ceil().clamp(1, 999);

  final slug = _toSlug(title);

  return {
    'slug': slug,
    'title': title,
    'date': date,
    'description': description,
    'tags': tags,
    'readingTimeMinutes': readingTime,
    'content': content,
  };
}

String _toSlug(String title) {
  return title
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
      .replaceAll(RegExp(r'\s+'), '-')
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}
