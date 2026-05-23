import { AppColors, AppRadius, AppSpacing, AppTypography } from '../../common/Theme';
import { CdNetworkBadge, CdNetworkMode } from './CdNetworkBadge';

export type CdDeviceStatus = 'online' | 'idle' | 'offline';

@Component
export struct CdDeviceItem {
  name: string = '';
  platform: string = '';
  status: CdDeviceStatus = 'online';
  networkMode: CdNetworkMode = 'lan';
  latencyText: string = '';
  onTap: () => void = () => {};

  private statusLabel(): string {
    if (this.status === 'idle') {
      return '空闲';
    }
    if (this.status === 'offline') {
      return '离线';
    }
    return '在线';
  }

  private statusColor(): string {
    if (this.status === 'offline') {
      return AppColors.TEXT_SECONDARY;
    }
    if (this.status === 'idle') {
      return AppColors.WARNING;
    }
    return AppColors.SUCCESS;
  }

  build() {
    Row() {
      Text(this.platform.length > 0 ? this.platform.substring(0, 2).toUpperCase() : 'DV')
        .fontSize(AppTypography.CAPTION)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppColors.PRIMARY_SELECTED)
        .width(44)
        .height(44)
        .textAlign(TextAlign.Center)
        .backgroundColor(AppColors.PRIMARY_SOFT)
        .borderRadius(AppRadius.MD)
        .margin({ right: AppSpacing.MD })

      Column({ space: AppSpacing.XS }) {
        Row({ space: AppSpacing.SM }) {
          Text(this.name)
            .fontSize(AppTypography.BODY)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppColors.TEXT)
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(this.statusLabel())
            .fontSize(AppTypography.CAPTION)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.statusColor())
        }
        .width('100%')

        Row({ space: AppSpacing.SM }) {
          CdNetworkBadge({ mode: this.networkMode })

          if (this.latencyText.length > 0) {
            Text(this.latencyText)
              .fontSize(AppTypography.CAPTION)
              .fontColor(AppColors.TEXT_SECONDARY)
          }
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding(AppSpacing.MD)
    .backgroundColor(AppColors.SURFACE)
    .borderRadius(AppRadius.LG)
    .onClick(() => {
      this.onTap();
    })
  }
}
