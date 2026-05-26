import { ExpireStatus, NetworkMode } from './CommonTypes';
import { TransferItem } from './TransferItem';

export type ShareSessionStatus = 'DRAFT' | 'ACTIVE' | 'REVOKED' | 'EXPIRED';
export type DownloadPolicy = 'PUBLIC' | 'LOGIN_REQUIRED' | 'OWNER_ONLY';

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
  downloadPolicy?: DownloadPolicy;
  items: TransferItem[];
}
