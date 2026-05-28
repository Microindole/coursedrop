import { AppColors, AppRadius, AppSpacing, AppTypography } from '../../common/Theme';
import { CdButton } from '../common/CdButton';
import { CdPanel } from '../common/CdPanel';

@Component
export struct CdLanRadarScanner {
  @Prop scanning: boolean = false;
  @Prop lanDeviceCount: number = 0;
  onStartScan: () => void = () => {};

  @State private radarScale: number = 1.0;
  @State private radarOpacity: number = 0.5;

  private startRadarAnimation() {
    this.radarScale = 1.0;
    this.radarOpacity = 0.6;
    
    animateTo({
      duration: 1500,
      curve: Curve.EaseOut,
      iterations: -1,
      playMode: PlayMode.Normal
    }, () => {
      this.radarScale = 1.8;
      this.radarOpacity = 0.0;
    });
  }

  private stopRadarAnimation() {
    animateTo({ duration: 300 }, () => {
      this.radarScale = 1.0;
      this.radarOpacity = 0.5;
    });
  }

  build() {
    CdPanel({ hasShadow: true }) {
      Column({ space: AppSpacing.LG }) {
        Row() {
          Column({ space: AppSpacing.XS }) {
            Text('局域网直传设备扫描')
              .fontSize(AppTypography.BODY)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppColors.TEXT)
            
            Text(`已在当前局域网发现到 ${this.lanDeviceCount} 台设备`)
              .fontSize(AppTypography.CAPTION)
              .fontColor(AppColors.TEXT_SECONDARY)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Stack() {
            if (this.scanning) {
              Circle()
                .width(50)
                .height(50)
                .fill(AppColors.ACCENT_SOFT)
                .scale({ x: this.radarScale, y: this.radarScale })
                .opacity(this.radarOpacity)
            }

            Circle()
              .width(50)
              .height(50)
              .fill(AppColors.PRIMARY_SOFT)
              .stroke(AppColors.ACCENT)
              .strokeWidth(1)

            Image($r('app.media.cd_icon_lan'))
              .width(20)
              .height(20)
              .fillColor(AppColors.PRIMARY)
          }
          .width(64)
          .height(64)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)

        Row({ space: AppSpacing.SM }) {
          Text('UDP DISCOVERY')
            .fontSize(10)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppColors.PRIMARY_SELECTED)
            .padding({ left: AppSpacing.SM, right: AppSpacing.SM, top: 3, bottom: 3 })
            .backgroundColor(AppColors.PRIMARY_SOFT)
            .borderRadius(AppRadius.SM)

          Text('SOCKET DIRECT')
            .fontSize(10)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppColors.SUCCESS)
            .padding({ left: AppSpacing.SM, right: AppSpacing.SM, top: 3, bottom: 3 })
            .backgroundColor(AppColors.SUCCESS_SOFT)
            .borderRadius(AppRadius.SM)
        }
        .width('100%')

        CdButton({
          label: this.scanning ? '正在扫描局域网设备...' : '开始雷达扫描',
          interactive: !this.scanning,
          onTap: () => {
            this.onStartScan();
            this.startRadarAnimation();
            
            setTimeout(() => {
              this.stopRadarAnimation();
            }, 3000);
          }
        })
        .width('100%')
      }
      .width('100%')
    }
  }
}
