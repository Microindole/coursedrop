import { mockDevices } from '../mocks';
import { Device } from '../models/Device';

export class DeviceViewModel {
  scanning: boolean = false;
  devices: Device[] = mockDevices.slice();
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
    this.devices = this.devices.map((device, index) => {
      if (device.status === 'OFFLINE') {
        return device;
      }
      device.latencyMs = 18 + index * 9;
      device.lastSeenAt = '2026-05-24T12:00:00+08:00';
      return device;
    });
    this.scanning = false;
    this.lastActionText = '设备列表已刷新';
  }
}
