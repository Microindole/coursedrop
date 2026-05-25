import { RuntimeDeviceRegistry } from './DeviceRegistry';
import { DeviceDiscoveryService } from './DeviceDiscoveryService';
import { LanDeviceDiscoveryService } from './LanDeviceDiscoveryService';

export type { DeviceDiscoveryService } from './DeviceDiscoveryService';
export type { DeviceRegistry } from './DeviceRegistry';
export { RuntimeDeviceRegistry } from './DeviceRegistry';
export { LanDeviceDiscoveryService } from './LanDeviceDiscoveryService';

export const deviceDiscoveryService: DeviceDiscoveryService = new LanDeviceDiscoveryService(
  new RuntimeDeviceRegistry()
);
