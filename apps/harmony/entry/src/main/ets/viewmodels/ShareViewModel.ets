import { TransferItemType } from '../models/CommonTypes';
import { ShareSession } from '../models/ShareSession';
import { TransferItem } from '../models/TransferItem';
import { TransferTask } from '../models/TransferTask';
import { shareService } from '../services/share';
import { shareDraftWorkflow } from '../services/share';
import { transferService } from '../services/transfer';

export class ShareViewModel {
  currentSession: ShareSession = shareService.getCurrentSession();
  loading: boolean = false;
  errorMessage: string = '';
  lastActionText: string = '';

  getItems(): TransferItem[] {
    return this.currentSession.items;
  }

  getTasks(): TransferTask[] {
    return shareService.listTasks(this.currentSession.id);
  }

  getItemName(id: string): string {
    const item = this.currentSession.items.find((next) => next.id === id);
    if (item === undefined) {
      return '';
    }
    return item.displayName;
  }

  getExpireText(): string {
    if (this.currentSession.expiresAt.length === 0 || this.currentSession.status === 'DRAFT') {
      return '公网分享未创建';
    }
    if (this.currentSession.expireStatus === 'EXPIRED') {
      return '已过期';
    }
    if (this.currentSession.expireStatus === 'EXPIRING_SOON') {
      return '即将过期';
    }
    return `有效至 ${this.currentSession.expiresAt}`;
  }

  copyShareLink(): string {
    if (this.currentSession.shareUrl.length === 0) {
      this.lastActionText = '暂无可复制的公网链接';
      return '';
    }
    this.lastActionText = '分享链接已复制';
    return this.currentSession.shareUrl;
  }

  async refreshShareCode(): Promise<void> {
    this.loading = true;
    const result = await shareService.createRelayShare(this.currentSession.id, 24, 'LOGIN_REQUIRED');
    this.currentSession = shareService.getCurrentSession();
    if (result.success) {
      await this.uploadCurrentItems();
    }
    this.currentSession = shareService.getCurrentSession();
    this.lastActionText = result.success ? '公网分享已创建，上传任务已启动' : result.message;
    this.errorMessage = result.success ? '' : result.message;
    this.loading = false;
  }

  revokeShare(): void {
    const result = shareService.revokeShare(this.currentSession.id);
    this.currentSession = shareService.getCurrentSession();
    this.lastActionText = result.message;
  }

  async addLocalItem(type: TransferItemType): Promise<void> {
    const result = await shareDraftWorkflow.pickAndAttachFiles(this.currentSession.id, type);
    this.currentSession = shareService.getCurrentSession();
    this.lastActionText = result.message;
    this.errorMessage = result.success ? '' : result.message;
  }

  private async uploadCurrentItems(): Promise<void> {
    for (let index = 0; index < this.currentSession.items.length; index += 1) {
      const item = this.currentSession.items[index];
      if (item.remoteItemId === undefined || item.remoteItemId.length === 0) {
        await transferService.uploadLocalFile({
          shareId: this.currentSession.id,
          localFileId: item.id,
          encrypted: false
        });
      }
    }
  }
}
