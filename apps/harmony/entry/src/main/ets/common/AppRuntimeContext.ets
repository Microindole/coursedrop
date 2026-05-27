export class AppRuntimeContext {
  private static appFilesDir: string = '';
  private static appContext?: Context;

  static configure(context: Context, filesDir: string): void {
    AppRuntimeContext.appContext = context;
    AppRuntimeContext.appFilesDir = filesDir;
  }

  static configureAppFilesDir(filesDir: string): void {
    AppRuntimeContext.appFilesDir = filesDir;
  }

  static getContext(): Context | undefined {
    return AppRuntimeContext.appContext;
  }

  static getAppFilesDir(): string {
    return AppRuntimeContext.appFilesDir;
  }
}
