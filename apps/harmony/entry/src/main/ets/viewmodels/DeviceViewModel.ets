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

  async refreshDevices(): Promise<void> {
    this.scanning = true;
    this.errorMessage = '';
    try {
      this.devices = await deviceDiscoveryService.refresh();
      this.lastActionText = this.devices.length > 0 ? '局域网发现完成' : '未发现同局域网节点';
    } catch (error) {
      this.errorMessage = `局域网发现失败：${String(error)}`;
      this.lastActionText = '局域网发现失败';
    } finally {
      this.scanning = false;
    }
  }
}
