import { Device } from '../../models/Device';

export interface DeviceDiscoveryService {
  listDevices(): Device[];
  refresh(): Device[];
}
