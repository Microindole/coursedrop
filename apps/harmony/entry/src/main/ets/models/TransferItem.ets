export type TransferItemType = 'FILE' | 'TEXT' | 'LINK' | 'IMAGE';

export interface TransferItem {
  id: string;
  roomId: string;
  type: TransferItemType;
  displayName: string;
  contentType: string;
  sizeBytes: number;
  createdAt: string;
  expiresAt: string;
}

