import { apiClient } from '../services/ApiClient';
import { identityService } from '../services/identity';
import { RelayShareApi, RelayShareDownloadResponse, RelayShareItemResponse } from '../services/share';
import { transferService } from '../services/transfer';
import { TransferTask } from '../models/TransferTask';

export class ShareDownloadViewModel {
  private relayShareApi: RelayShareApi = new RelayShareApi(apiClient);
  code: string = '';
  share: RelayShareDownloadResponse | undefined = undefined;
  tasks: TransferTask[] = [];
  loading: boolean = false;
  lastActionText: string = '输入或扫码分享码后，可下载到 CourseDrop 本地库';
  errorMessage: string = '';

  async load(code: string): Promise<void> {
    const normalizedCode = code.trim();
    if (normalizedCode.length === 0) {
      this.errorMessage = '请输入分享码';
      this.lastActionText = '分享码为空';
      return;
    }
    this.loading = true;
    this.code = normalizedCode;
    try {
      this.share = await this.relayShareApi.getShareByCode(normalizedCode);
      this.lastActionText = `已读取分享：${this.share.items.length} 项`;
      this.errorMessage = '';
    } catch (error) {
      this.lastActionText = '读取分享失败';
      this.errorMessage = String(error);
    }
    this.loading = false;
  }

  async downloadItem(item: RelayShareItemResponse): Promise<void> {
    if (this.code.length === 0) {
      this.errorMessage = '请先读取分享';
      return;
    }
    this.loading = true;
    try {
      const identity = identityService.getLocalIdentity();
      const task = await transferService.downloadShareItem({
        code: this.code,
        itemId: item.id,
        fingerprintId: identity === undefined ? undefined : identity.fingerprintId
      });
      this.tasks = transferService.listTasks();
      this.lastActionText = task.status === 'COMPLETED' ? '文件已下载并写入本地库' : '下载任务已结束';
      this.errorMessage = task.status === 'FAILED' && task.errorMessage !== undefined ? task.errorMessage : '';
    } catch (error) {
      this.lastActionText = '下载失败';
      this.errorMessage = String(error);
    }
    this.loading = false;
  }

  getItems(): RelayShareItemResponse[] {
    if (this.share === undefined) {
      return [];
    }
    return this.share.items;
  }
}
