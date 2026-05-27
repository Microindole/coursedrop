import { LocalFileEntry } from '../../models/LocalFileEntry';
import { TransferTask } from '../../models/TransferTask';
import { LocalFileIndexRepository } from '../local/LocalFileIndexRepository';
import { CourseDropFileStore } from '../local/CourseDropFileStore';
import { RelayTransferApi } from './RelayTransferApi';
import { TransferTaskService } from './TransferTaskService';
import { FileTypeResolver } from '../file/FileTypeResolver';

export interface UploadLocalFileCommand {
  shareId: string;
  localFileId: string;
  encrypted: boolean;
  onUploaded?: (remoteItemId: string, remoteUrl: string, expiresAt: string) => void;
}

export interface DownloadShareItemCommand {
  code: string;
  itemId: string;
  fingerprintId?: string;
  accountId?: string;
}

export interface TransferService {
  uploadLocalFile(command: UploadLocalFileCommand): Promise<TransferTask>;
  downloadShareItem(command: DownloadShareItemCommand): Promise<TransferTask>;
  listTasks(): TransferTask[];
  listSessionTasks(sessionId: string): TransferTask[];
}

export class DefaultTransferService implements TransferService {
  private taskService: TransferTaskService;
  private transferApi: RelayTransferApi;
  private fileIndexRepository: LocalFileIndexRepository;
  private fileStore: CourseDropFileStore;
  private fileTypeResolver: FileTypeResolver = new FileTypeResolver();

  constructor(
    taskService: TransferTaskService,
    transferApi: RelayTransferApi,
    fileIndexRepository: LocalFileIndexRepository,
    fileStore: CourseDropFileStore
  ) {
    this.taskService = taskService;
    this.transferApi = transferApi;
    this.fileIndexRepository = fileIndexRepository;
    this.fileStore = fileStore;
  }

  async uploadLocalFile(command: UploadLocalFileCommand): Promise<TransferTask> {
    const file = this.requireLocalFile(command.localFileId);
    const task = this.taskService.createTask(file.id, 'UPLOAD', 'RELAY', command.shareId);
    this.taskService.start(task.id);
    try {
      const response = await this.transferApi.uploadShareItem({
        shareId: command.shareId,
        localUri: file.localUri,
        displayName: file.displayName,
        contentType: file.contentType,
        encrypted: command.encrypted
      });
      if (command.onUploaded !== undefined) {
        command.onUploaded(response.id, '', '');
      }
      file.remoteCached = true;
      file.shareCount = file.shareCount + 1;
      file.lastSharedAt = new Date().toISOString();
      this.fileIndexRepository.save(file);
      return this.taskService.complete(task.id);
    } catch (error) {
      return this.taskService.fail(task.id, String(error));
    }
  }

  async downloadShareItem(command: DownloadShareItemCommand): Promise<TransferTask> {
    const task = this.taskService.createTask(command.itemId, 'DOWNLOAD', 'RELAY');
    this.taskService.start(task.id);
    try {
      const result = await this.transferApi.downloadShareItem({
        code: command.code,
        itemId: command.itemId,
        targetDirectory: this.fileStore.incomingRoot(),
        fingerprintId: command.fingerprintId,
        accountId: command.accountId
      });
      this.fileIndexRepository.save({
        id: `download-${Date.now()}`,
        displayName: result.displayName,
        type: this.fileTypeResolver.resolve(result.contentType, result.displayName),
        contentType: result.contentType,
        sizeBytes: result.sizeBytes,
        localUri: result.localUri,
        shareCount: 0,
        remoteCached: false,
        encrypted: false
      });
      return this.taskService.complete(task.id);
    } catch (error) {
      return this.taskService.fail(task.id, String(error));
    }
  }

  listTasks(): TransferTask[] {
    return this.taskService.listAll();
  }

  listSessionTasks(sessionId: string): TransferTask[] {
    return this.taskService.listBySession(sessionId);
  }

  private requireLocalFile(localFileId: string): LocalFileEntry {
    const file = this.fileIndexRepository.findById(localFileId);
    if (file === undefined) {
      throw new Error(`本地文件不存在：${localFileId}`);
    }
    return file;
  }
}
