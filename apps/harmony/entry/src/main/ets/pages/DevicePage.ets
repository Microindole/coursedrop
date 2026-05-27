import router from '@ohos.router';
import { AppColors, AppRadius, AppSize, AppSpacing, AppTypography } from '../common/Theme';
import {
  CdBanner,
  CdButton,
  CdPanel,
  CdScrollContainer,
  CdSectionHeader,
  CdTopBar
} from '../components/index';
import { Device } from '../models/Device';
import { DeviceViewModel } from '../viewmodels/DeviceViewModel';

@Component
export default struct DevicePage {
  showBack: boolean = true;
  private viewModel: DeviceViewModel = new DeviceViewModel();
  @State revision: number = 0;

  private refreshView(): void {
    this.revision += 1;
  }

  private statusText(device: Device): string {
    if (device.status === 'ONLINE') {
      return '在线';
    }
    if (device.status === 'IDLE') {
      return '空闲';
    }
    return '离线';
  }

  private platformText(device: Device): string {
    if (device.platform === 'HARMONY') {
      return 'HarmonyOS';
    }
    if (device.platform === 'ANDROID') {
      return 'Android';
    }
    if (device.platform === 'WINDOWS') {
      return 'Windows';
    }
    if (device.platform === 'MACOS') {
      return 'macOS';
    }
    if (device.platform === 'LINUX') {
      return 'Linux';
    }
    if (device.platform === 'WEB') {
      return 'Web';
    }
    return '未知设备';
  }

  @Builder
  DeviceRow(device: Device) {
    CdPanel() {
      Row({ space: AppSpacing.MD }) {
        Stack() {
          Image(device.networkMode === 'LAN' ? $r('app.media.cd_icon_lan') : $r('app.media.cd_icon_relay'))
            .width(AppSize.ICON_MD)
            .height(AppSize.ICON_MD)
            .fillColor(device.status === 'OFFLINE' ? AppColors.TEXT_SECONDARY : AppColors.PRIMARY_SELECTED)
        }
        .width(44)
        .height(44)
        .backgroundColor(device.status === 'OFFLINE' ? AppColors.SURFACE_MUTED : AppColors.PRIMARY_SOFT)
        .borderRadius(AppRadius.MD)

        Column({ space: AppSpacing.XS }) {
          Text(device.name)
            .fontSize(AppTypography.BODY)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppColors.TEXT)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(`${this.platformText(device)} · ${device.networkMode} · ${this.statusText(device)}`)
            .fontSize(AppTypography.CAPTION)
            .fontColor(AppColors.TEXT_SECONDARY)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
  }

  @Builder
  DeviceList() {
    if (this.viewModel.devices.length === 0) {
      CdPanel() {
        Column({ space: AppSpacing.SM }) {
          Image($r('app.media.cd_icon_devices'))
            .width(36)
            .height(36)
            .fillColor(AppColors.TEXT_SECONDARY)

          Text('暂无可连接设备')
            .fontSize(AppTypography.BODY)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppColors.TEXT)

          Text('局域网发现服务接入后，这里只展示真实发现到的设备。')
            .fontSize(AppTypography.BODY_SMALL)
            .fontColor(AppColors.TEXT_SECONDARY)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .padding({ top: AppSpacing.LG, bottom: AppSpacing.LG })
      }
    } else {
      ForEach(this.viewModel.devices, (device: Device) => {
        this.DeviceRow(device);
      }, (device: Device) => device.id)
    }
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      CdScrollContainer({ showScrollBar: true }) {
        if (this.revision < 0) {
          Blank()
        }

        CdTopBar({
          title: '设备',
          subtitle: `${this.viewModel.getOnlineDevices().length} 台在线`,
          leadingText: this.showBack ? '返回' : '',
          onLeadingTap: () => {
            router.back();
          }
        })

        CdBanner({
          title: this.viewModel.lastActionText.length > 0 ? this.viewModel.lastActionText : '局域网发现优先',
          description: '后续接入 mDNS/局域网握手后，设备页只负责发现、连接和状态展示。',
          tone: this.viewModel.errorMessage.length > 0 ? 'danger' : 'info'
        })

        CdPanel() {
          Column({ space: AppSpacing.MD }) {
            Row({ space: AppSpacing.SM }) {
              Text(`局域网 ${this.viewModel.getLanDevices().length}`)
                .fontSize(AppTypography.BODY_SMALL)
                .fontColor(AppColors.TEXT)
                .layoutWeight(1)

              Text(`在线 ${this.viewModel.getOnlineDevices().length}`)
                .fontSize(AppTypography.BODY_SMALL)
                .fontColor(AppColors.TEXT_SECONDARY)
            }
            .width('100%')

            CdButton({
              label: this.viewModel.scanning ? '刷新中' : '刷新设备',
              interactive: !this.viewModel.scanning,
              onTap: () => {
                this.viewModel.refreshDevices();
                this.refreshView();
              }
            })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }

        CdSectionHeader({ title: '可连接设备' })

        this.DeviceList();
      }
    }
    .width('100%')
    .height('100%')
  }
}
