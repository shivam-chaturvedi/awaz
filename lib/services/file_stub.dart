// Stub for dart:io File on web
enum FileMode {
  write,
  append,
  read,
}

class File {
  final String path;
  File(this.path);
  
  Future<File> writeAsString(String contents, {FileMode mode = FileMode.write}) async {
    // On web, we can't write to files directly
    // This is a no-op stub
    return this;
  }
}

