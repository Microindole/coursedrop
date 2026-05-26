import { TransferItemType } from './CommonTypes';

export interface TransferItem {
  id: string;
  roomId?: string;
  sessionId?: string;
  type: TransferItemType;
  displayName: string;
  contentType: string;
  sizeBytes: number;
  localUri?: string;
  remoteUrl?: string;
  remoteItemId?: string;
  createdAt: string;
  expiresAt: string;
  encrypted?: boolean;
}
