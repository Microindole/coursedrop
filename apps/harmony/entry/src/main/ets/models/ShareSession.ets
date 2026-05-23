import { ExpireStatus, NetworkMode } from './CommonTypes';
import { TransferItem } from './TransferItem';

export type ShareSessionStatus = 'DRAFT' | 'ACTIVE' | 'REVOKED' | 'EXPIRED';

export interface ShareSession {
  id: string;
  title: string;
  code: string;
  shareUrl: string;
  status: ShareSessionStatus;
  networkMode: NetworkMode;
  expireStatus: ExpireStatus;
  createdAt: string;
  expiresAt: string;
  itemCount: number;
  totalSizeBytes: number;
  encrypted: boolean;
  items: TransferItem[];
}
