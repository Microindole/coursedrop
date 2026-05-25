import { Device } from '../../models/Device';

export interface DeviceRegistry {
  list(): Device[];
  save(device: Device): void;
}

export class RuntimeDeviceRegistry implements DeviceRegistry {
  private devices: Device[] = [];

  list(): Device[] {
    return this.devices;
  }

  save(device: Device): void {
    const index = this.devices.findIndex((next) => next.id === device.id);
    if (index < 0) {
      this.devices.push(device);
      return;
    }
    this.devices[index] = device;
  }
}
