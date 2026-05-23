import { Device } from '../models/Device';

export const mockDevices: Device[] = [
  {
    id: 'device-harmony-phone',
    name: 'Mate 课递测试机',
    platform: 'HARMONY',
    status: 'ONLINE',
    networkMode: 'LAN',
    latencyMs: 12,
    address: '192.168.31.24',
    lastSeenAt: '2026-05-24T10:20:00Z'
  },
  {
    id: 'device-laptop',
    name: '宿舍 Windows 笔记本',
    platform: 'WINDOWS',
    status: 'IDLE',
    networkMode: 'LAN',
    latencyMs: 21,
    address: '192.168.31.8',
    lastSeenAt: '2026-05-24T10:18:00Z'
  },
  {
    id: 'device-relay-peer',
    name: '公网接收端',
    platform: 'WEB',
    status: 'ONLINE',
    networkMode: 'RELAY',
    latencyMs: 86,
    address: '',
    lastSeenAt: '2026-05-24T10:15:00Z'
  }
];
