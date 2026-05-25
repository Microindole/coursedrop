import { TransferItemType } from '../../models/CommonTypes';
import { LocalFileEntry } from '../../models/LocalFileEntry';

export interface LocalFileIndexRepository {
  list(): LocalFileEntry[];
  listByType(type: TransferItemType): LocalFileEntry[];
  save(file: LocalFileEntry): void;
  remove(ids: string[]): void;
}

export class RuntimeLocalFileIndexRepository implements LocalFileIndexRepository {
  private files: LocalFileEntry[] = [];

  list(): LocalFileEntry[] {
    return this.files;
  }

  listByType(type: TransferItemType): LocalFileEntry[] {
    return this.files.filter((file) => file.type === type);
  }

  save(file: LocalFileEntry): void {
    const index = this.files.findIndex((next) => next.id === file.id);
    if (index < 0) {
      this.files.push(file);
      return;
    }
    this.files[index] = file;
  }

  remove(ids: string[]): void {
    this.files = this.files.filter((file) => !ids.includes(file.id));
  }
}
