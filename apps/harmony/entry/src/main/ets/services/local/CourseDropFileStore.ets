import { AppRuntimeContext } from '../../common/AppRuntimeContext';

export interface CourseDropFileStore {
  appRoot(): string;
  libraryRoot(): string;
  incomingRoot(): string;
  stagingRoot(): string;
  cacheRoot(): string;
}

export class AppSandboxFileStore implements CourseDropFileStore {
  appRoot(): string {
    const appFilesDir = AppRuntimeContext.getAppFilesDir();
    if (appFilesDir.length === 0) {
      return '';
    }
    return `${appFilesDir}/CourseDrop`;
  }

  libraryRoot(): string {
    const root = this.appRoot();
    if (root.length === 0) {
      return '';
    }
    return `${root}/library`;
  }

  incomingRoot(): string {
    const root = this.appRoot();
    if (root.length === 0) {
      return '';
    }
    return `${root}/incoming`;
  }

  stagingRoot(): string {
    const root = this.appRoot();
    if (root.length === 0) {
      return '';
    }
    return `${root}/staging`;
  }

  cacheRoot(): string {
    const root = this.appRoot();
    if (root.length === 0) {
      return '';
    }
    return `${root}/cache`;
  }
}
