import { AppSandboxFileStore } from './CourseDropFileStore';
import { IndexedLocalLibraryService } from './IndexedLocalLibraryService';
import { RuntimeLocalFileIndexRepository } from './LocalFileIndexRepository';
import { LocalLibraryService } from './LocalLibraryService';

export type { CourseDropFileStore } from './CourseDropFileStore';
export { AppSandboxFileStore } from './CourseDropFileStore';
export { IndexedLocalLibraryService } from './IndexedLocalLibraryService';
export type { LocalFileIndexRepository } from './LocalFileIndexRepository';
export { RuntimeLocalFileIndexRepository } from './LocalFileIndexRepository';
export type { LibraryGrouping, LocalLibraryService } from './LocalLibraryService';

export const localLibraryService: LocalLibraryService = new IndexedLocalLibraryService(
  new AppSandboxFileStore(),
  new RuntimeLocalFileIndexRepository()
);
