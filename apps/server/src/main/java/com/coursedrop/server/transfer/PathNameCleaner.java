package com.coursedrop.server.transfer;

final class PathNameCleaner {
  private PathNameCleaner() {
  }

  static String clean(String filename) {
    return filename.replace('\\', '_').replace('/', '_').trim();
  }
}

