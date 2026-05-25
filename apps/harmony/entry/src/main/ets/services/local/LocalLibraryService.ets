import { TransferItemType } from '../../models/CommonTypes';
import { LocalFileEntry } from '../../models/LocalFileEntry';

export type LibraryGrouping = 'TYPE' | 'PEER' | 'STATUS';

export interface LocalLibraryService {
  getLibraryRoot(): string;
  listFiles(): LocalFileEntry[];
  listByType(type: TransferItemType): LocalFileEntry[];
  markShared(ids: string[]): void;
  removeFiles(ids: string[]): void;
}
