import { TransferItemType } from '../models/CommonTypes';
import { ShareSession } from '../models/ShareSession';
import { TransferItem } from '../models/TransferItem';
import { TransferTask } from '../models/TransferTask';
import { shareService } from '../services/share';
import { shareDraftWorkflow } from '../services/share';
import { transferService } from '../services/transfer';
import { apiClient } from '../services/ApiClient';
import { clipboardService } from '../services/clipboard';
import { settingsService } from '../services/settings';

export class ShareViewModel {
  currentSession: ShareSession = shareService.getCurrentSession();
  loading: boolean = false;
  errorMessage: string = '';
  lastActionText: string = '';
  private e2eeKeyFragments: string[] = [];

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

  async copyShareLink(): Promise<string> {
    if (this.currentSession.shareUrl.length === 0) {
      this.lastActionText = '暂无可复制的公网链接';
      return '';
    }
    try {
      await clipboardService.copyText(this.currentSession.shareUrl);
      this.lastActionText = '分享链接已复制到剪贴板';
      this.errorMessage = '';
    } catch (error) {
      this.lastActionText = '复制失败';
      this.errorMessage = String(error);
    }
    return this.currentSession.shareUrl;
  }

  getQrPayload(): string {
    return this.currentSession.shareUrl;
  }

  getShareQrImageUrl(): string {
    if (this.currentSession.shareUrl.length === 0 || !apiClient.hasBaseUrl()) {
      return '';
    }
    return `${apiClient.getBaseUrl()}/api/qr?text=${encodeURIComponent(this.currentSession.shareUrl)}`;
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

  async revokeShare(): Promise<void> {
    this.loading = true;
    const result = await shareService.revokeShare(this.currentSession.id);
    this.currentSession = shareService.getCurrentSession();
    this.lastActionText = result.message;
    this.errorMessage = result.success ? '' : result.message;
    this.loading = false;
  }

  async extendShare(): Promise<void> {
    this.loading = true;
    const result = await shareService.extendShare(this.currentSession.id, 24);
    this.currentSession = shareService.getCurrentSession();
    this.lastActionText = result.message;
    this.errorMessage = result.success ? '' : result.message;
    this.loading = false;
  }

  async addLocalItem(type: TransferItemType): Promise<void> {
    const result = await shareDraftWorkflow.pickAndAttachFiles(this.currentSession.id, type);
    this.currentSession = shareService.getCurrentSession();
    this.lastActionText = result.message;
    this.errorMessage = result.success ? '' : result.message;
  }

  removeDraftItem(itemId: string): void {
    const result = shareService.removeDraftItem(this.currentSession.id, itemId);
    this.currentSession = shareService.getCurrentSession();
    this.lastActionText = result.message;
    this.errorMessage = result.success ? '' : result.message;
  }

  clearDraft(): void {
    const result = shareService.clearDraft(this.currentSession.id);
    this.currentSession = shareService.getCurrentSession();
    this.lastActionText = result.message;
    this.errorMessage = result.success ? '' : result.message;
  }

  async retryUpload(itemId: string): Promise<void> {
    this.loading = true;
    try {
      await transferService.uploadLocalFile({
        shareId: this.currentSession.id,
        localFileId: itemId,
        encrypted: settingsService.getSettings().e2eeEnabled,
        onUploaded: (
          remoteItemId: string,
          remoteUrl: string,
          expiresAt: string,
          e2eeKeyMaterial: string,
          e2eeNonce: string,
          e2eeAuthTag: string
        ) => {
          shareService.markItemUploaded(this.currentSession.id, itemId, remoteItemId, remoteUrl, expiresAt);
          this.rememberE2eeKey(remoteItemId, e2eeKeyMaterial, e2eeNonce, e2eeAuthTag);
        }
      });
      this.lastActionText = '上传任务已重试';
      this.errorMessage = '';
    } catch (error) {
      this.lastActionText = '上传重试失败';
      this.errorMessage = String(error);
    }
    this.currentSession = shareService.getCurrentSession();
    this.loading = false;
  }

  private async uploadCurrentItems(): Promise<void> {
    for (let index = 0; index < this.currentSession.items.length; index += 1) {
      const item = this.currentSession.items[index];
      if (item.remoteItemId === undefined || item.remoteItemId.length === 0) {
        await transferService.uploadLocalFile({
          shareId: this.currentSession.id,
          localFileId: item.id,
          encrypted: settingsService.getSettings().e2eeEnabled,
          onUploaded: (
            remoteItemId: string,
            remoteUrl: string,
            expiresAt: string,
            e2eeKeyMaterial: string,
            e2eeNonce: string,
            e2eeAuthTag: string
          ) => {
            shareService.markItemUploaded(this.currentSession.id, item.id, remoteItemId, remoteUrl, expiresAt);
            this.rememberE2eeKey(remoteItemId, e2eeKeyMaterial, e2eeNonce, e2eeAuthTag);
          }
        });
      }
    }
  }

  private rememberE2eeKey(remoteItemId: string, keyMaterial: string, nonce: string, authTag: string): void {
    if (keyMaterial.length === 0) {
      return;
    }
    this.e2eeKeyFragments.push(`${remoteItemId}:${keyMaterial}:${nonce}:${authTag}`);
    const baseUrl = this.currentSession.shareUrl.split('#')[0];
    const fragment = encodeURIComponent(this.e2eeKeyFragments.join(','));
    const nextUrl = `${baseUrl}#cdkey=${fragment}`;
    shareService.updateShareUrl(this.currentSession.id, nextUrl);
    this.currentSession = shareService.getCurrentSession();
  }
}
