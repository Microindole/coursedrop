import { apiClient } from '../ApiClient';
import { courseDropFileStore, localFileIndexRepository } from '../local';
import { HttpRelayTransferApi } from './RelayTransferApi';
import { DefaultTransferService } from './TransferService';
import type { TransferService } from './TransferService';
import { DefaultTransferTaskService } from './TransferTaskService';
import { RuntimeTransferTaskRepository } from './TransferTaskRepository';

export type { RelayDownloadRequest, RelayDownloadResult, RelayUploadRequest, RelayUploadResponse } from './TransferModels';
export type { RelayTransferApi } from './RelayTransferApi';
export { HttpRelayTransferApi } from './RelayTransferApi';
export type { DownloadShareItemCommand, TransferService, UploadLocalFileCommand } from './TransferService';
export { DefaultTransferService } from './TransferService';
export type { TransferProgress, TransferTaskService } from './TransferTaskService';
export { DefaultTransferTaskService } from './TransferTaskService';
export type { TransferTaskRepository } from './TransferTaskRepository';
export { RuntimeTransferTaskRepository } from './TransferTaskRepository';

export const transferTaskRepository = new RuntimeTransferTaskRepository();
export const transferTaskService = new DefaultTransferTaskService(transferTaskRepository);
export const relayTransferApi = new HttpRelayTransferApi(apiClient);
export const transferService: TransferService = new DefaultTransferService(
  transferTaskService,
  relayTransferApi,
  localFileIndexRepository,
  courseDropFileStore
);
