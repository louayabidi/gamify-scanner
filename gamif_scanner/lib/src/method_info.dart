/// Represents a Dart method detected during AST scanning.
class MethodInfo {
  /// The method name (e.g., `completeLevel`).
  final String name;

  /// The class containing this method, or null if top-level.
  final String? className;

  /// Absolute path to the file containing this method.
  final String filePath;

  /// Character offset of the opening `{` of the method body.
  final int bodyOffset;

  /// Whether the method is declared as `async`.
  final bool isAsync;

  /// The line number where the method is declared.
  final int lineNumber;

  /// Creates a [MethodInfo] instance.
  const MethodInfo({
    required this.name,
    this.className,
    required this.filePath,
    required this.bodyOffset,
    required this.isAsync,
    required this.lineNumber,
  });

  /// Returns a display name like `ClassName.methodName()`.
  String get displayName =>
      className != null ? '$className.$name()' : '$name()';

  /// Flutter lifecycle methods excluded from tracking by default.
  static const List<String> defaultExclusions = [
    'build', 'initState', 'dispose',
    'didChangeDependencies', 'didUpdateWidget',
    'setState', 'createState',
  ];

  /// Returns true if this method is in the default exclusion list.
  bool get isSuggestedToIgnore => defaultExclusions.contains(name);

  /// Serializes this instance to a JSON map.
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