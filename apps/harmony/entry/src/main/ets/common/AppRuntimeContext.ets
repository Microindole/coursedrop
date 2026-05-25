export class AppRuntimeContext {
  private static appFilesDir: string = '';

  static configureAppFilesDir(filesDir: string): void {
    AppRuntimeContext.appFilesDir = filesDir;
  }

  static getAppFilesDir(): string {
    return AppRuntimeContext.appFilesDir;
  }
}
