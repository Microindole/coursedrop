import { AppRuntimeContext } from '../../common/AppRuntimeContext';

export interface CourseDropFileStore {
  libraryRoot(): string;
}

export class AppSandboxFileStore implements CourseDropFileStore {
  libraryRoot(): string {
    const appFilesDir = AppRuntimeContext.getAppFilesDir();
    if (appFilesDir.length === 0) {
      return '';
    }
    return `${appFilesDir}/CourseDrop/library`;
  }
}
