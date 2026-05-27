import { TransferItemType } from '../../models/CommonTypes';
import { ShareSession } from '../../models/ShareSession';
import { TransferItem } from '../../models/TransferItem';
import { TransferTask } from '../../models/TransferTask';
import { LocalFileEntry } from '../../models/LocalFileEntry';
import { LocalFileIndexRepository } from '../local/LocalFileIndexRepository';
import { ShareOperationResult, ShareService, TransferStats } from './ShareService';
import { ShareSessionRepository } from './ShareSessionRepository';
import { TransferTaskRepository } from './TransferTaskRepository';
import { RelayShareApi } from './RelayShareApi';
import { identityService } from '../identity';

export class LocalShareService implements ShareService {
  private sessionRepository: ShareSessionRepository;
  private taskRepository: TransferTaskRepository;
  private relayShareApi: RelayShareApi;
  private fileIndexRepository: LocalFileIndexRepository;

  constructor(
    sessionRepository: ShareSessionRepository,
    taskRepository: TransferTaskRepository,
    relayShareApi: RelayShareApi,
    fileIndexRepository: LocalFileIndexRepository
  ) {
    this.sessionRepository = sessionRepository;
    this.taskRepository = taskRepository;
    this.relayShareApi = relayShareApi;
    this.fileIndexRepository = fileIndexRepository;
  }

  listRecentSessions(limit: number): ShareSession[] {
    return this.sessionRepository.list()
      .filter((session) => session.status !== 'DRAFT')
      .slice(0, limit);
  }

  getCurrentSession(): ShareSession {
    return this.sessionRepository.current();
  }

  listTasks(sessionId: string): TransferTask[] {
    return this.taskRepository.listBySession(sessionId);
  }

  getStats(): TransferStats {
    const tasks = this.taskRepository.listAll();
    const sessions = this.sessionRepository.list();
    return {
      activeCount: tasks.filter((task) => task.status === 'RUNNING').length,
      completedCount: tasks.filter((task) => task.status === 'COMPLETED').length,
      failedCount: tasks.filter((task) => task.status === 'FAILED').length,
      expiringCount: sessions.filter((session) => session.expireStatus === 'EXPIRING_SOON').length
    };
  }

  refreshShareCode(sessionId: string): ShareOperationResult {
    const session = this.findSession(sessionId);
    if (session.items.length === 0) {
      return {
        success: false,
        message: '请先添加本地内容'
      };
    }
    return {
      success: false,
      message: '请点击创建公网分享'
    };
  }

  async createRelayShare(sessionId: string, expireHours: number, downloadPolicy: string): Promise<ShareOperationResult> {
    const session = this.findSession(sessionId);
    try {
      const identity = identityService.getLocalIdentity();
      const ownerIdentityId = identity === undefined ? '' : identity.fingerprintId;
      const ownerIdentityType = identity === undefined ? 'ANONYMOUS' : 'FINGERPRINT';
      const response = await this.relayShareApi.createShare(
        expireHours,
        downloadPolicy,
        ownerIdentityId,
        ownerIdentityType
      );
      session.id = response.id;
      session.code = response.code;
      session.shareUrl = response.downloadUrl;
      session.status = 'ACTIVE';
      session.networkMode = 'RELAY';
      session.expireStatus = 'ACTIVE';
      session.createdAt = response.createdAt;
      session.expiresAt = response.expiresAt;
      session.downloadPolicy = response.downloadPolicy === 'OWNER_ONLY' ? 'OWNER_ONLY' :
        response.downloadPolicy === 'PUBLIC' ? 'PUBLIC' : 'LOGIN_REQUIRED';
      this.sessionRepository.save(session);
      return {
        success: true,
        message: '公网分享已创建'
      };
    } catch (error) {
      return {
        success: false,
        message: `创建失败：${String(error)}`
      };
    }
  }

  revokeShare(sessionId: string): ShareOperationResult {
    const session = this.findSession(sessionId);
    session.status = 'REVOKED';
    session.expireStatus = 'EXPIRED';
    this.sessionRepository.save(session);
    return {
      success: true,
      message: '分享已撤回'
    };
  }

  addLocalItem(_sessionId: string, _type: TransferItemType): ShareOperationResult {
    return {
      success: false,
      message: '请先接入系统文件选择器'
    };
  }

  attachLocalFile(sessionId: string, localFileId: string): ShareOperationResult {
    const session = this.findSession(sessionId);
    const localFile = this.fileIndexRepository.findById(localFileId);
    if (localFile === undefined) {
      return {
        success: false,
        message: '本地文件不存在'
      };
    }
    const duplicated = session.items.find((item) => item.localUri === localFile.localUri);
    if (duplicated !== undefined) {
      return {
        success: false,
        message: '该文件已在当前分享中'
      };
    }
    const item = this.toTransferItem(session.id, localFile);
    session.items.push(item);
    session.itemCount = session.items.length;
    session.totalSizeBytes = session.totalSizeBytes + item.sizeBytes;
    session.title = session.itemCount === 1 ? item.displayName : `${session.itemCount} 个文件`;
    this.sessionRepository.save(session);
    return {
      success: true,
      message: '已加入分享草稿'
    };
  }

  markItemUploaded(
    sessionId: string,
    itemId: string,
    remoteItemId: string,
    remoteUrl: string,
    expiresAt: string
  ): ShareOperationResult {
    const session = this.findSession(sessionId);
    const item = session.items.find((next) => next.id === itemId);
    if (item === undefined) {
      return {
        success: false,
        message: '分享项不存在'
      };
    }
    item.remoteItemId = remoteItemId;
    item.remoteUrl = remoteUrl;
    item.expiresAt = expiresAt;
    this.sessionRepository.save(session);
    return {
      success: true,
      message: '分享项已上传'
    };
  }

  private findSession(sessionId: string): ShareSession {
    const session = this.sessionRepository.list().find((next) => next.id === sessionId);
    if (session === undefined) {
      throw new Error(`share session not found: ${sessionId}`);
    }
    return session;
  }

  private toTransferItem(sessionId: string, file: LocalFileEntry): TransferItem {
    return {
      id: file.id,
      sessionId: sessionId,
      type: file.type,
      displayName: file.displayName,
      contentType: file.contentType,
      sizeBytes: file.sizeBytes,
      localUri: file.localUri,
      remoteItemId: '',
      remoteUrl: '',
      createdAt: new Date().toISOString(),
      expiresAt: '',
      encrypted: file.encrypted
    };
  }
}
