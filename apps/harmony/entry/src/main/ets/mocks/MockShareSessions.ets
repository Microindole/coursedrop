import { ShareSession } from '../models/ShareSession';
import { mockTransferItems } from './MockTransferItems';

export const mockShareSessions: ShareSession[] = [
  {
    id: 'share-course-ui',
    title: '移动应用 UI 资料',
    code: 'KT82M9',
    shareUrl: 'https://drop.example/s/KT82M9',
    status: 'ACTIVE',
    networkMode: 'RELAY',
    expireStatus: 'ACTIVE',
    createdAt: '2026-05-24T09:10:00Z',
    expiresAt: '2026-05-25T09:10:00Z',
    itemCount: 2,
    totalSizeBytes: 26420000,
    encrypted: true,
    items: mockTransferItems.filter((item) => item.sessionId === 'share-course-ui')
  },
  {
    id: 'share-project-plan',
    title: '项目路线和选题说明',
    code: 'P9X31A',
    shareUrl: 'https://drop.example/s/P9X31A',
    status: 'ACTIVE',
    networkMode: 'E2EE',
    expireStatus: 'EXPIRING_SOON',
    createdAt: '2026-05-23T15:00:00Z',
    expiresAt: '2026-05-24T18:00:00Z',
    itemCount: 1,
    totalSizeBytes: 120,
    encrypted: true,
    items: mockTransferItems.filter((item) => item.sessionId === 'share-project-plan')
  },
  {
    id: 'share-lan-lab',
    title: '实验室局域网传输',
    code: 'LAN001',
    shareUrl: '',
    status: 'DRAFT',
    networkMode: 'LAN',
    expireStatus: 'ACTIVE',
    createdAt: '2026-05-24T11:00:00Z',
    expiresAt: '2026-05-24T23:00:00Z',
    itemCount: 0,
    totalSizeBytes: 0,
    encrypted: false,
    items: []
  }
];
