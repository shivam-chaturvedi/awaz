// Stub for path_provider on web
class Directory {
  final String path;
  Directory(this.path);
}

Future<Directory> getApplicationDocumentsDirectory() async {
  // On web, return a dummy directory
  return Directory('/tmp');
}

