import { Device } from '../../models/Device';
import { DeviceDiscoveryService } from './DeviceDiscoveryService';
import { DeviceRegistry } from './DeviceRegistry';

export class LanDeviceDiscoveryService implements DeviceDiscoveryService {
  private registry: DeviceRegistry;

  constructor(registry: DeviceRegistry) {
    this.registry = registry;
  }

  listDevices(): Device[] {
    return this.registry.list();
  }

  refresh(): Device[] {
    return this.registry.list();
  }
}
