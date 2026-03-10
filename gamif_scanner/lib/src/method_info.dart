class MethodInfo {
  final String name;
  final String? className;
  final String filePath;
  final int bodyOffset;
  final bool isAsync;
  final int lineNumber;

  const MethodInfo({
    required this.name,
    this.className,
    required this.filePath,
    required this.bodyOffset,
    required this.isAsync,
    required this.lineNumber,
  });

  String get displayName =>
      className != null ? '$className.$name()' : '$name()';

  static const List<String> defaultExclusions = [
    'build', 'initState', 'dispose',
    'didChangeDependencies', 'didUpdateWidget',
    'setState', 'createState',
  ];

  bool get isSuggestedToIgnore => defaultExclusions.contains(name);

  Map<String, dynamic> toJson() => {
    'name': name,
    'className': className,
    'filePath': filePath,
    'bodyOffset': bodyOffset,
    'isAsync': isAsync,
    'lineNumber': lineNumber,
    'displayName': displayName,
    'isSuggestedToIgnore': isSuggestedToIgnore,
  };
}