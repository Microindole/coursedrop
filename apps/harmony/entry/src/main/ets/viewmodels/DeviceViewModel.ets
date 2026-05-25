import { Device } from '../models/Device';
import { deviceDiscoveryService } from '../services/device';

export class DeviceViewModel {
  scanning: boolean = false;
  devices: Device[] = deviceDiscoveryService.listDevices();
  errorMessage: string = '';
  lastActionText: string = '';

  getOnlineDevices(): Device[] {
    return this.devices.filter((device) => device.status !== 'OFFLINE');
  }

  getLanDevices(): Device[] {
    return this.devices.filter((device) => device.networkMode === 'LAN');
  }

  refreshDevices(): void {
    this.scanning = true;
    this.devices = deviceDiscoveryService.refresh();
    this.scanning = false;
    this.lastActionText = '设备列表已刷新';
  }
}
