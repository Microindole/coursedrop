import { mockShareSessions, mockTransferTasks } from '../mocks';
import { TransferItemType } from '../models/CommonTypes';
import { ShareSession } from '../models/ShareSession';
import { TransferItem } from '../models/TransferItem';
import { TransferTask } from '../models/TransferTask';

export class ShareViewModel {
  currentSession: ShareSession = mockShareSessions[0];
  tasks: TransferTask[] = mockTransferTasks.slice();
  loading: boolean = false;
  errorMessage: string = '';
  lastActionText: string = '';

  getItems(): TransferItem[] {
    return this.currentSession.items;
  }

  getTasks(): TransferTask[] {
    return this.tasks.filter((task) => task.sessionId === this.currentSession.id);
  }

  getItemName(id: string): string {
    const item = this.currentSession.items.find((next) => next.id === id);
    if (item === undefined) {
      return '';
    }
    return item.displayName;
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
    this.lastActionText = '分享链接已复制';
    return this.currentSession.shareUrl;
  }

  refreshShareCode(): void {
    this.loading = false;
    this.currentSession.code = this.nextCode();
    this.currentSession.status = 'ACTIVE';
    this.currentSession.expireStatus = 'ACTIVE';
    this.lastActionText = '分享码已刷新';
  }

  revokeShare(): void {
    this.currentSession.status = 'REVOKED';
    this.currentSession.expireStatus = 'EXPIRED';
    this.lastActionText = '分享已撤回';
  }

  addMockItem(type: TransferItemType): void {
    const nextIndex = this.currentSession.items.length + 1;
    const item: TransferItem = {
      id: `mock-added-${type.toLowerCase()}-${nextIndex}`,
      sessionId: this.currentSession.id,
      type,
      displayName: this.resolveItemName(type, nextIndex),
      contentType: this.resolveContentType(type),
      sizeBytes: type === 'TEXT' || type === 'LINK' ? 1024 : 1024 * 1024 * nextIndex,
      localUri: `mock://local/${type.toLowerCase()}/${nextIndex}`,
      createdAt: '2026-05-24T12:00:00+08:00',
      expiresAt: this.currentSession.expiresAt,
      encrypted: true
    };

    const items = [item].concat(this.currentSession.items);
    this.currentSession.items = items;
    this.currentSession.itemCount = items.length;
    this.currentSession.totalSizeBytes = items.reduce((sum, next) => sum + next.sizeBytes, 0);
    this.lastActionText = '已加入待分享内容';
  }

  private nextCode(): string {
    const codeNumber = Math.floor(100000 + Math.random() * 900000);
    return `${codeNumber}`;
  }

  private resolveItemName(type: TransferItemType, index: number): string {
    if (type === 'IMAGE') {
      return `新增图片 ${index}.png`;
    }
    if (type === 'TEXT') {
      return `新增文本片段 ${index}`;
    }
    if (type === 'LINK') {
      return `新增资料链接 ${index}`;
    }
    return `新增文件 ${index}.zip`;
  }

  private resolveContentType(type: TransferItemType): string {
    if (type === 'IMAGE') {
      return 'image/png';
    }
    if (type === 'TEXT') {
      return 'text/plain';
    }
    if (type === 'LINK') {
      return 'text/uri-list';
    }
    return 'application/zip';
  }
}
