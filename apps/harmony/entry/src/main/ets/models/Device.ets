import { NetworkMode } from './CommonTypes';

export type DevicePlatform = 'HARMONY' | 'ANDROID' | 'IOS' | 'WINDOWS' | 'MACOS' | 'LINUX' | 'WEB' | 'UNKNOWN';

export type DeviceStatus = 'ONLINE' | 'IDLE' | 'OFFLINE';

export interface Device {
  id: string;
  name: string;
  platform: DevicePlatform;
  status: DeviceStatus;
  networkMode: NetworkMode;
  latencyMs?: number;
  address?: string;
  lastSeenAt: string;
}
