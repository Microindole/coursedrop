import { AppColors, AppRadius, AppSpacing, AppTypography } from '../../common/Theme';
import { CdPanel } from '../common/CdPanel';

@Component
export struct CdTransferStats {
  statsActiveCount: number = 0;
  statsCompletedCount: number = 0;
  statsFailedCount: number = 0;
  statsExpiringCount: number = 0;

  @Builder
  statCell(icon: Resource, value: number, label: string, color: string, bgColor: string) {
    Column({ space: 4 }) {
      // 状态图标容器
      Row() {
        Image(icon)
          .width(18)
          .height(18)
          .fillColor(color)
      }
      .width(36)
      .height(36)
      .borderRadius(18)
      .backgroundColor(bgColor)
      .justifyContent(FlexAlign.Center)
      
      // 数值
      Text(`${value}`)
        .fontSize(AppTypography.TITLE)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppColors.TEXT)
        .margin({ top: 2 })

      // 状态文本说明
      Text(label)
        .fontSize(10)
        .fontWeight(FontWeight.Medium)
        .fontColor(AppColors.TEXT_SECONDARY)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
    .padding({ top: AppSpacing.SM, bottom: AppSpacing.SM })
  }

  build() {
    CdPanel({ hasShadow: true }) {
      Row() {
        this.statCell($r('app.media.cd_icon_running'), this.statsActiveCount, '运行中', AppColors.PRIMARY, AppColors.PRIMARY_SOFT)
        this.statCell($r('app.media.cd_icon_done'), this.statsCompletedCount, '已完成', AppColors.SUCCESS, AppColors.SUCCESS_SOFT)
        this.statCell($r('app.media.cd_icon_failed'), this.statsFailedCount, '传输失败', AppColors.DANGER, '#FFF0F0')
        this.statCell($r('app.media.cd_icon_expire'), this.statsExpiringCount, '即将过期', AppColors.WARNING, AppColors.WARNING_SOFT)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .alignItems(VerticalAlign.Center)
    }
  }
}
