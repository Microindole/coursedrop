import { AppConfig } from '../common/AppConfig';
import { mockDevices, mockShareSessions, mockTransferTasks } from '../mocks';
import { Device } from '../models/Device';
import { ShareSession } from '../models/ShareSession';
import { TransferTask } from '../models/TransferTask';

export interface HomeTransferStats {
  activeCount: number;
  completedCount: number;
  failedCount: number;
  expiringCount: number;
}

export class HomeViewModel {
  appName: string = AppConfig.APP_NAME;
  subtitle: string = '本地优先的加密文件传输与分享管理';
  recentShares: ShareSession[] = mockShareSessions.slice(0, 2);
  nearbyDevices: Device[] = mockDevices.slice(0, 2);
  activeTasks: TransferTask[] = mockTransferTasks.filter((task) => task.status === 'RUNNING');

  getTransferStats(): HomeTransferStats {
    return {
      activeCount: mockTransferTasks.filter((task) => task.status === 'RUNNING').length,
      completedCount: mockTransferTasks.filter((task) => task.status === 'COMPLETED').length,
      failedCount: mockTransferTasks.filter((task) => task.status === 'FAILED').length,
      expiringCount: mockShareSessions.filter((share) => share.expireStatus === 'EXPIRING_SOON').length
    };
  }

  getPrimaryShare(): ShareSession {
    return mockShareSessions[0];
  }
}
