import { courseDropFileStore, localFileIndexRepository } from '../local';
import { CourseDropFileImportService } from './FileImportService';
import { SystemFilePickerService } from './FilePickerService';
import { FileTypeResolver } from './FileTypeResolver';

export type { FileImportPlan, FileImportResult, PickedFile } from './FileModels';
export type { FileImportService } from './FileImportService';
export { CourseDropFileImportService } from './FileImportService';
export type { FilePickerService } from './FilePickerService';
export { SystemFilePickerService } from './FilePickerService';
export { FileTypeResolver } from './FileTypeResolver';

export const fileTypeResolver: FileTypeResolver = new FileTypeResolver();
export const filePickerService = new SystemFilePickerService();
export const fileImportService = new CourseDropFileImportService(
  courseDropFileStore,
  localFileIndexRepository
);
