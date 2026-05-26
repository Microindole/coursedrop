import { TransferItemType } from '../../models/CommonTypes';
import { ShareSession } from '../../models/ShareSession';
import { TransferTask } from '../../models/TransferTask';
import { ShareOperationResult, ShareService, TransferStats } from './ShareService';
import { ShareSessionRepository } from './ShareSessionRepository';
import { TransferTaskRepository } from './TransferTaskRepository';
import { RelayShareApi } from './RelayShareApi';
import { identityService } from '../identity';

export class LocalShareService implements ShareService {
  private sessionRepository: ShareSessionRepository;
  private taskRepository: TransferTaskRepository;
  private relayShareApi: RelayShareApi;

  constructor(
    sessionRepository: ShareSessionRepository,
    taskRepository: TransferTaskRepository,
    relayShareApi: RelayShareApi
  ) {
    this.sessionRepository = sessionRepository;
    this.taskRepository = taskRepository;
    this.relayShareApi = relayShareApi;
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

  private findSession(sessionId: string): ShareSession {
    const session = this.sessionRepository.list().find((next) => next.id === sessionId);
    if (session === undefined) {
      throw new Error(`share session not found: ${sessionId}`);
    }
    return session;
  }
}
