import router from '@ohos.router';
import {
  CdBanner,
  CdScrollContainer,
  CdSectionHeader,
  CdTopBar,
  CdLanRadarScanner,
  CdLanDeviceList
} from '../components/index';
import { Device } from '../models/Device';
import { DeviceViewModel } from '../viewmodels/DeviceViewModel';

@Component
export default struct DevicePage {
  showBack: boolean = true;
  private viewModel: DeviceViewModel = new DeviceViewModel();

  @State devices: Device[] = [];
  @State scanning: boolean = false;
  @State lastActionText: string = '局域网发现优先';
  @State errorMessage: string = '';

  aboutToAppear() {
    this.syncDevices();
  }

  private syncDevices() {
    this.devices = this.viewModel.devices;
    this.scanning = this.viewModel.scanning;
    this.lastActionText = this.viewModel.lastActionText.length > 0 ? this.viewModel.lastActionText : '局域网发现优先';
    this.errorMessage = this.viewModel.errorMessage;
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      CdScrollContainer({ showScrollBar: true, backgroundStyle: 'device' }) {
        CdTopBar({
          title: '局域网直传设备',
          subtitle: `已连接 ${this.devices.filter(d => d.status !== 'OFFLINE').length} 台设备`,
          leadingText: this.showBack ? '返回' : '',
          trailingText: '刷新',
          onLeadingTap: () => {
            router.back();
          },
          onTrailingTap: () => {
            this.scanDevices();
          }
        })

        CdBanner({
          title: this.lastActionText,
          description: this.errorMessage.length > 0 ? this.errorMessage : '同局域网下优先使用 Socket 直传，减少公网暴露面并提升传输速度。',
          tone: this.errorMessage.length > 0 ? 'danger' : 'info'
        })

        // 雷达扫描控制面板
        CdLanRadarScanner({
          scanning: this.scanning,
          lanDeviceCount: this.viewModel.getLanDevices().length,
          onStartScan: () => {
            this.scanDevices();
          }
        })

        CdSectionHeader({ title: '已扫描到的局域网节点' })

        // 连接设备列表
        CdLanDeviceList({
          devices: this.devices,
          onDeviceTap: (device) => {
            this.lastActionText = `成功与 ${device.name} 发起通道握手 · 延迟：${device.latencyMs || 2} ms`;
          }
        })
      }
    }
    .width('100%')
    .height('100%')
  }

  private async scanDevices(): Promise<void> {
    this.viewModel.scanning = true;
    this.syncDevices();
    await this.viewModel.refreshDevices();
    this.syncDevices();
  }
}
