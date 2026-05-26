import { LocalFileEntry } from '../../models/LocalFileEntry';
import { CourseDropFileStore } from '../local/CourseDropFileStore';
import { LocalFileIndexRepository } from '../local/LocalFileIndexRepository';
import { FileImportPlan, FileImportResult, PickedFile } from './FileModels';

export interface FileImportService {
  createImportPlan(file: PickedFile): FileImportPlan;
  importPickedFile(file: PickedFile): Promise<FileImportResult>;
}

export class CourseDropFileImportService implements FileImportService {
  private fileStore: CourseDropFileStore;
  private indexRepository: LocalFileIndexRepository;

  constructor(fileStore: CourseDropFileStore, indexRepository: LocalFileIndexRepository) {
    this.fileStore = fileStore;
    this.indexRepository = indexRepository;
  }

  createImportPlan(file: PickedFile): FileImportPlan {
    return {
      sourceUri: file.uri,
      displayName: file.displayName,
      contentType: file.contentType,
      sizeBytes: file.sizeBytes,
      type: file.type,
      targetDirectory: this.fileStore.stagingRoot()
    };
  }

  async importPickedFile(file: PickedFile): Promise<FileImportResult> {
    const targetDirectory = this.fileStore.stagingRoot();
    if (targetDirectory.length === 0) {
      throw new Error('应用沙箱目录未初始化');
    }
    const localFileId = `local-${Date.now()}`;
    const entry: LocalFileEntry = {
      id: localFileId,
      displayName: file.displayName,
      type: file.type,
      contentType: file.contentType,
      sizeBytes: file.sizeBytes,
      localUri: file.uri,
      shareCount: 0,
      remoteCached: false,
      encrypted: false
    };
    this.indexRepository.save(entry);
    return {
      localFileId: localFileId,
      localUri: file.uri
    };
  }
}
