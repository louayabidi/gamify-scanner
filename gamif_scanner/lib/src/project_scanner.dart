import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:path/path.dart' as p;
import 'method_info.dart';

class ProjectScanner {
  final String projectPath;
  ProjectScanner({required this.projectPath});

  Future<List<MethodInfo>> scanProject() async {
    final allMethods = <MethodInfo>[];
    final libDir = Directory(p.join(projectPath, 'lib'));

    if (!libDir.existsSync()) {
      throw Exception('Dossier lib/ introuvable dans $projectPath');
    }

    final dartFiles = libDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => !f.path.endsWith('.g.dart'))
        .where((f) => !f.path.endsWith('.freezed.dart'))
        .toList();

    print('  📂 ${dartFiles.length} fichiers Dart trouvés...');

    for (final file in dartFiles) {
      try {
        final source = file.readAsStringSync();
        final result = parseString(content: source);
        final visitor = _MethodVisitor(
          filePath: file.path,
          source: source,
        );
        result.unit.visitChildren(visitor);
        allMethods.addAll(visitor.methods);
      } catch (_) {}
    }
    return allMethods;
  }
}

class _MethodVisitor extends RecursiveAstVisitor<void> {
  final String filePath;
  final String source;
  final List<MethodInfo> methods = [];
  String? _currentClassName;

  _MethodVisitor({required this.filePath, required this.source});

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    _currentClassName = node.name.lexeme;
    super.visitClassDeclaration(node);
    _currentClassName = null;
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (node.isGetter || node.isSetter) return;
    if (node.body is EmptyFunctionBody) return;

    final lineNumber =
        '\n'.allMatches(source.substring(0, node.offset)).length + 1;

    final body = node.body;
    if (body is! BlockFunctionBody) return;

    methods.add(MethodInfo(
      name: node.name.lexeme,
      className: _currentClassName,
      filePath: filePath,
      bodyOffset: body.block.leftBracket.offset,
      isAsync: body.isAsynchronous,
      lineNumber: lineNumber,
    ));
    super.visitMethodDeclaration(node);
  }
}