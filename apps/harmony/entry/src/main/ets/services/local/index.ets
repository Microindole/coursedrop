import { AppSandboxFileStore } from './CourseDropFileStore';
import { IndexedLocalLibraryService } from './IndexedLocalLibraryService';
import { RdbLocalFileIndexRepository } from './LocalFileIndexRepository';
import { LocalLibraryService } from './LocalLibraryService';

export type { CourseDropFileStore } from './CourseDropFileStore';
export { AppSandboxFileStore } from './CourseDropFileStore';
export { IndexedLocalLibraryService } from './IndexedLocalLibraryService';
export type { LocalFileIndexRepository } from './LocalFileIndexRepository';
export { RdbLocalFileIndexRepository, RuntimeLocalFileIndexRepository } from './LocalFileIndexRepository';
export type { LibraryGrouping, LocalLibraryService } from './LocalLibraryService';

export const courseDropFileStore = new AppSandboxFileStore();
export const localFileIndexRepository = new RdbLocalFileIndexRepository();
export const localLibraryService: LocalLibraryService = new IndexedLocalLibraryService(
  courseDropFileStore,
  localFileIndexRepository
);
