import { TransferItemType } from '../../models/CommonTypes';
import { ShareSession } from '../../models/ShareSession';
import { TransferTask } from '../../models/TransferTask';

export interface TransferStats {
  activeCount: number;
  completedCount: number;
  failedCount: number;
  expiringCount: number;
}

export interface ShareOperationResult {
  success: boolean;
  message: string;
}

export interface ShareService {
  listRecentSessions(limit: number): ShareSession[];
  getCurrentSession(): ShareSession;
  listTasks(sessionId: string): TransferTask[];
  getStats(): TransferStats;
  refreshShareCode(sessionId: string): ShareOperationResult;
  createRelayShare(sessionId: string, expireHours: number, downloadPolicy: string): Promise<ShareOperationResult>;
  revokeShare(sessionId: string): Promise<ShareOperationResult>;
  extendShare(sessionId: string, expireHours: number): Promise<ShareOperationResult>;
  addLocalItem(sessionId: string, type: TransferItemType): ShareOperationResult;
  attachLocalFile(sessionId: string, localFileId: string): ShareOperationResult;
  removeDraftItem(sessionId: string, itemId: string): ShareOperationResult;
  clearDraft(sessionId: string): ShareOperationResult;
  markItemUploaded(sessionId: string, itemId: string, remoteItemId: string, remoteUrl: string, expiresAt: string): ShareOperationResult;
  updateShareUrl(sessionId: string, shareUrl: string): ShareOperationResult;
}
