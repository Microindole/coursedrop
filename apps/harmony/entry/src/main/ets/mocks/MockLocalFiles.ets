import { LocalFileEntry } from '../models/LocalFileEntry';

export const mockLocalFiles: LocalFileEntry[] = [
  {
    id: 'local-ui-zip',
    displayName: 'UI 教程参考资料.zip',
    type: 'FILE',
    contentType: 'application/zip',
    sizeBytes: 24800000,
    localUri: 'file://local/ui-tutorial.zip',
    lastSharedAt: '2026-05-24T09:10:00Z',
    shareCount: 3,
    remoteCached: true,
    encrypted: true
  },
  {
    id: 'local-class-png',
    displayName: '课堂截图.png',
    type: 'IMAGE',
    contentType: 'image/png',
    sizeBytes: 1620000,
    localUri: 'file://local/class-shot.png',
    lastSharedAt: '2026-05-24T09:12:00Z',
    shareCount: 1,
    remoteCached: true,
    encrypted: true
  },
  {
    id: 'local-archive-doc',
    displayName: '旧版需求记录.md',
    type: 'TEXT',
    contentType: 'text/markdown',
    sizeBytes: 9800,
    localUri: 'file://local/old-requirements.md',
    lastSharedAt: '2026-05-21T16:40:00Z',
    shareCount: 2,
    remoteCached: false,
    encrypted: false
  }
];
