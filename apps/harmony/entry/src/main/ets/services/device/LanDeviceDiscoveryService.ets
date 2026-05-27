import socket from '@ohos.net.socket';
import { Device } from '../../models/Device';
import { DeviceDiscoveryService } from './DeviceDiscoveryService';
import { DeviceRegistry } from './DeviceRegistry';

interface UdpAddress {
  address: string;
  family: number;
  port: number;
}

interface UdpSendOptions {
  data: string;
  address: UdpAddress;
}

interface UdpExtraOptions {
  broadcast: boolean;
}

interface DiscoveryPayload {
  protocol: string;
  id: string;
  name: string;
  platform: string;
  port: number;
}

export class LanDeviceDiscoveryService implements DeviceDiscoveryService {
  private registry: DeviceRegistry;
  private readonly discoveryPort: number = 39091;

  constructor(registry: DeviceRegistry) {
    this.registry = registry;
  }

  listDevices(): Device[] {
    return this.registry.list();
  }

  async refresh(): Promise<Device[]> {
    const udp = socket.constructUDPSocketInstance();
    try {
      const bindAddress: UdpAddress = {
        address: '0.0.0.0',
        family: 1,
        port: 0
      };
      await udp.bind(bindAddress);
      const extraOptions: UdpExtraOptions = {
        broadcast: true
      };
      await udp.setExtraOptions(extraOptions);
      udp.on('message', (message) => {
        this.handleMessage(message.message, message.remoteInfo.address);
      });
      const options: UdpSendOptions = {
        data: this.buildDiscoveryPayload(),
        address: {
          address: '255.255.255.255',
          family: 1,
          port: this.discoveryPort
        }
      };
      await udp.send(options);
      await this.sleep(1200);
      return this.registry.list();
    } finally {
      udp.off('message');
      udp.close();
    }
  }

  private handleMessage(buffer: ArrayBuffer, address: string): void {
    const text = this.decodeUtf8(buffer).trim();
    if (text.length === 0 || !text.startsWith('{')) {
      return;
    }
    const payload = JSON.parse(text) as DiscoveryPayload;
    if (payload.protocol !== 'coursedrop.lan.v1') {
      return;
    }
    this.registry.save({
      id: payload.id,
      name: payload.name,
      platform: payload.platform === 'HARMONY' ? 'HARMONY' : 'UNKNOWN',
      status: 'ONLINE',
      networkMode: 'LAN',
      latencyMs: 0,
      address: `${address}:${payload.port}`,
      lastSeenAt: new Date().toISOString()
    });
  }

  private buildDiscoveryPayload(): string {
    const payload: DiscoveryPayload = {
      protocol: 'coursedrop.lan.v1',
      id: `harmony-${Date.now()}`,
      name: 'CourseDrop Harmony',
      platform: 'HARMONY',
      port: 39092
    };
    return JSON.stringify(payload);
  }

  private decodeUtf8(buffer: ArrayBuffer): string {
    const bytes = new Uint8Array(buffer);
    let text = '';
    for (let index = 0; index < bytes.length; index += 1) {
      text += String.fromCharCode(bytes[index]);
    }
    return text;
  }

  private sleep(durationMs: number): Promise<void> {
    return new Promise<void>((resolve) => {
      setTimeout(() => {
        resolve();
      }, durationMs);
    });
  }
}
