import { TransferItemType } from './CommonTypes';

export interface LocalFileEntry {
  id: string;
  displayName: string;
  type: TransferItemType;
  contentType: string;
  sizeBytes: number;
  localUri: string;
  lastSharedAt?: string;
  shareCount: number;
  remoteCached: boolean;
  encrypted: boolean;
}
