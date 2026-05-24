import { AppSpacing } from '../../common/Theme';
import { Device } from '../../models/Device';
import { CdDeviceItem } from './CdDeviceItem';

@Component
export struct CdDeviceList {
  devices: Device[] = [];

  private deviceStatus(status: string): 'online' | 'idle' | 'offline' {
    if (status === 'IDLE') {
      return 'idle';
    }
    if (status === 'OFFLINE') {
      return 'offline';
    }
    return 'online';
  }

  private networkMode(mode: string): 'lan' | 'relay' | 'e2ee' | 'offline' {
    if (mode === 'LAN') {
      return 'lan';
    }
    if (mode === 'E2EE') {
      return 'e2ee';
    }
    if (mode === 'OFFLINE') {
      return 'offline';
    }
    return 'relay';
  }

  build() {
    Column({ space: AppSpacing.SM }) {
      ForEach(this.devices, (device: Device) => {
        CdDeviceItem({
          name: device.name,
          platform: device.platform,
          status: this.deviceStatus(device.status),
          networkMode: this.networkMode(device.networkMode),
          latencyText: device.latencyMs === undefined ? '' : `${device.latencyMs} ms`
        })
      }, (device: Device) => device.id)
    }
    .width('100%')
  }
}
