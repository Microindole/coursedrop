import { mockDevices } from '../mocks';
import { Device } from '../models/Device';

export class DeviceViewModel {
  scanning: boolean = false;
  devices: Device[] = mockDevices;
  errorMessage: string = '';

  getOnlineDevices(): Device[] {
    return this.devices.filter((device) => device.status !== 'OFFLINE');
  }

  getLanDevices(): Device[] {
    return this.devices.filter((device) => device.networkMode === 'LAN');
  }

  refreshDevices(): void {
    this.scanning = true;
    this.scanning = false;
  }
}
