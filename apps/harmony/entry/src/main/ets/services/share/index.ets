import { LocalShareService } from './LocalShareService';
import { apiClient } from '../ApiClient';
import { LocalShareSessionRepository } from './ShareSessionRepository';
import { RelayShareApi } from './RelayShareApi';
import { LocalTransferTaskRepository } from './TransferTaskRepository';
import { ShareService } from './ShareService';

export type { ShareOperationResult, ShareService, TransferStats } from './ShareService';
export { LocalShareService } from './LocalShareService';
export type { ShareSessionRepository } from './ShareSessionRepository';
export { LocalShareSessionRepository } from './ShareSessionRepository';
export { RelayShareApi } from './RelayShareApi';
export type { TransferTaskRepository } from './TransferTaskRepository';
export { LocalTransferTaskRepository } from './TransferTaskRepository';

export const shareService: ShareService = new LocalShareService(
  new LocalShareSessionRepository(),
  new LocalTransferTaskRepository(),
  new RelayShareApi(apiClient)
);
