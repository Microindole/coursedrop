import { NetworkMode } from './CommonTypes';

export type TransferDirection = 'UPLOAD' | 'DOWNLOAD' | 'SEND' | 'RECEIVE';

export type TransferTaskStatus = 'PENDING' | 'RUNNING' | 'COMPLETED' | 'FAILED' | 'CANCELED';

export interface TransferTask {
  id: string;
  itemId: string;
  sessionId?: string;
  deviceId?: string;
  direction: TransferDirection;
  status: TransferTaskStatus;
  networkMode: NetworkMode;
  progress: number;
  speedBytesPerSecond?: number;
  errorMessage?: string;
  startedAt?: string;
  completedAt?: string;
}
