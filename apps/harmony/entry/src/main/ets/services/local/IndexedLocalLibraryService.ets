import { TransferItemType } from '../../models/CommonTypes';
import { LocalFileEntry } from '../../models/LocalFileEntry';
import { CourseDropFileStore } from './CourseDropFileStore';
import { LocalFileIndexRepository } from './LocalFileIndexRepository';
import { LocalLibraryService } from './LocalLibraryService';

export class IndexedLocalLibraryService implements LocalLibraryService {
  private fileStore: CourseDropFileStore;
  private indexRepository: LocalFileIndexRepository;

  constructor(
    fileStore: CourseDropFileStore,
    indexRepository: LocalFileIndexRepository
  ) {
    this.fileStore = fileStore;
    this.indexRepository = indexRepository;
  }

  getLibraryRoot(): string {
    return this.fileStore.libraryRoot();
  }

  listFiles(): LocalFileEntry[] {
    return this.indexRepository.list();
  }

  listByType(type: TransferItemType): LocalFileEntry[] {
    return this.indexRepository.listByType(type);
  }

  markShared(ids: string[]): void {
    this.indexRepository.list().forEach((file) => {
      if (ids.includes(file.id)) {
        file.shareCount = file.shareCount + 1;
        file.remoteCached = true;
        this.indexRepository.save(file);
      }
    });
  }

  removeFiles(ids: string[]): void {
    this.indexRepository.remove(ids);
  }
}
