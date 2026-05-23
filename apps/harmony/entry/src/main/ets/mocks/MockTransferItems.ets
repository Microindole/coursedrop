import { TransferItem } from '../models/TransferItem';

export const mockTransferItems: TransferItem[] = [
  {
    id: 'item-ui-zip',
    sessionId: 'share-course-ui',
    type: 'FILE',
    displayName: 'UI 教程参考资料.zip',
    contentType: 'application/zip',
    sizeBytes: 24800000,
    localUri: 'file://local/ui-tutorial.zip',
    remoteUrl: 'https://drop.example/s/KT82M9/ui-tutorial.zip',
    createdAt: '2026-05-24T09:10:00Z',
    expiresAt: '2026-05-25T09:10:00Z',
    encrypted: true
  },
  {
    id: 'item-class-png',
    sessionId: 'share-course-ui',
    type: 'IMAGE',
    displayName: '课堂截图.png',
    contentType: 'image/png',
    sizeBytes: 1620000,
    localUri: 'file://local/class-shot.png',
    remoteUrl: 'https://drop.example/s/KT82M9/class-shot.png',
    createdAt: '2026-05-24T09:12:00Z',
    expiresAt: '2026-05-25T09:10:00Z',
    encrypted: true
  },
  {
    id: 'item-project-link',
    sessionId: 'share-project-plan',
    type: 'LINK',
    displayName: '项目路线文档',
    contentType: 'text/uri-list',
    sizeBytes: 120,
    localUri: '',
    remoteUrl: 'https://drop.example/s/P9X31A/project-roadmap',
    createdAt: '2026-05-23T15:00:00Z',
    expiresAt: '2026-05-24T18:00:00Z',
    encrypted: false
  }
];
