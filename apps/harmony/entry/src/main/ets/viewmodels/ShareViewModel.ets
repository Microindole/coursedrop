import { mockShareSessions, mockTransferTasks } from '../mocks';
import { ShareSession } from '../models/ShareSession';
import { TransferItem } from '../models/TransferItem';
import { TransferTask } from '../models/TransferTask';

export class ShareViewModel {
  currentSession: ShareSession = mockShareSessions[0];
  loading: boolean = false;
  errorMessage: string = '';

  getItems(): TransferItem[] {
    return this.currentSession.items;
  }

  getTasks(): TransferTask[] {
    return mockTransferTasks.filter((task) => task.sessionId === this.currentSession.id);
  }

  getExpireText(): string {
    if (this.currentSession.expireStatus === 'EXPIRED') {
      return '已过期';
    }
    if (this.currentSession.expireStatus === 'EXPIRING_SOON') {
      return '即将过期';
    }
    return '24 小时内有效';
  }

  copyShareLink(): string {
    return this.currentSession.shareUrl;
  }

  refreshShareCode(): void {
    this.loading = false;
  }

  revokeShare(): void {
    this.currentSession.status = 'REVOKED';
  }
}
