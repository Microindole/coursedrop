import { TransferItemType } from '../../models/CommonTypes';
import { LocalFileEntry } from '../../models/LocalFileEntry';

export interface LocalFileIndexRepository {
  list(): LocalFileEntry[];
  listByType(type: TransferItemType): LocalFileEntry[];
  findById(id: string): LocalFileEntry | undefined;
  save(file: LocalFileEntry): void;
  remove(ids: string[]): void;
}

export class RuntimeLocalFileIndexRepository implements LocalFileIndexRepository {
  private files: LocalFileEntry[] = [];

  list(): LocalFileEntry[] {
    return this.copyFiles(this.files);
  }

  listByType(type: TransferItemType): LocalFileEntry[] {
    return this.copyFiles(this.files.filter((file) => file.type === type));
  }

  findById(id: string): LocalFileEntry | undefined {
    const file = this.files.find((next) => next.id === id);
    if (file === undefined) {
      return undefined;
    }
    return this.copyFile(file);
  }

  save(file: LocalFileEntry): void {
    const nextFile = this.copyFile(file);
    const index = this.files.findIndex((next) => next.id === file.id);
    if (index < 0) {
      this.files.push(nextFile);
      return;
    }
    this.files[index] = nextFile;
  }

  remove(ids: string[]): void {
    this.files = this.files.filter((file) => !ids.includes(file.id));
  }

  private copyFiles(source: LocalFileEntry[]): LocalFileEntry[] {
    const files: LocalFileEntry[] = [];
    source.forEach((file: LocalFileEntry) => {
      files.push(this.copyFile(file));
    });
    return files;
  }

  private copyFile(file: LocalFileEntry): LocalFileEntry {
    return {
      id: file.id,
      displayName: file.displayName,
      type: file.type,
      contentType: file.contentType,
      sizeBytes: file.sizeBytes,
      localUri: file.localUri,
      lastSharedAt: file.lastSharedAt,
      shareCount: file.shareCount,
      remoteCached: file.remoteCached,
      encrypted: file.encrypted
    };
  }
}
