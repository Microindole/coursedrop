import { TransferTask } from '../models/TransferTask';

export const mockTransferTasks: TransferTask[] = [
  {
    id: 'task-upload-ui',
    itemId: 'item-ui-zip',
    sessionId: 'share-course-ui',
    direction: 'UPLOAD',
    status: 'RUNNING',
    networkMode: 'RELAY',
    progress: 72,
    speedBytesPerSecond: 840000,
    startedAt: '2026-05-24T10:02:00Z'
  },
  {
    id: 'task-send-class-shot',
    itemId: 'item-class-png',
    sessionId: 'share-course-ui',
    deviceId: 'device-harmony-phone',
    direction: 'SEND',
    status: 'COMPLETED',
    networkMode: 'LAN',
    progress: 100,
    speedBytesPerSecond: 3400000,
    startedAt: '2026-05-24T09:30:00Z',
    completedAt: '2026-05-24T09:30:05Z'
  },
  {
    id: 'task-download-plan',
    itemId: 'item-project-link',
    sessionId: 'share-project-plan',
    direction: 'DOWNLOAD',
    status: 'FAILED',
    networkMode: 'E2EE',
    progress: 38,
    errorMessage: '临时链接即将过期，请刷新分享',
    startedAt: '2026-05-24T10:00:00Z'
  }
];
