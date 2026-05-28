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
    Column({ space: 6 }) {
      // 状态图标容器
      Row() {
        Image(icon)
          .width(18)
          .height(18)
          .fillColor(color)
      }
      .width(40)
      .height(40)
      .borderRadius(20)
      .backgroundColor(bgColor)
      .border({ width: 0.7, color: color })
      .justifyContent(FlexAlign.Center)
      
      // 数值
      Text(`${value}`)
        .fontSize(AppTypography.TITLE)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppColors.TEXT)
        .margin({ top: 2 })

      // 状态文本说明
      Text(label)
        .fontSize(AppTypography.CAPTION)
        .fontWeight(FontWeight.Medium)
        .fontColor(AppColors.TEXT_SECONDARY)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
    .padding({ top: AppSpacing.MD, bottom: AppSpacing.MD })
  }

  build() {
    CdPanel({ hasShadow: true }) {
      Column({ space: AppSpacing.MD }) {
        Row() {
          Text('传输安全态势')
            .fontSize(AppTypography.BODY_SMALL)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppColors.TEXT)
            .layoutWeight(1)

          Text('实时')
            .fontSize(AppTypography.CAPTION)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppColors.ACCENT)
            .padding({ left: AppSpacing.SM, right: AppSpacing.SM, top: 3, bottom: 3 })
            .backgroundColor(AppColors.ACCENT_SOFT)
            .borderRadius(AppRadius.SM)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)

        Row() {
          this.statCell($r('app.media.cd_icon_running'), this.statsActiveCount, '运行中', AppColors.PRIMARY, AppColors.PRIMARY_SOFT)
          this.statCell($r('app.media.cd_icon_done'), this.statsCompletedCount, '已完成', AppColors.SUCCESS, AppColors.SUCCESS_SOFT)
          this.statCell($r('app.media.cd_icon_failed'), this.statsFailedCount, '传输失败', AppColors.DANGER, AppColors.DANGER_SOFT)
          this.statCell($r('app.media.cd_icon_expire'), this.statsExpiringCount, '即将过期', AppColors.WARNING, AppColors.WARNING_SOFT)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceAround)
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
    }
  }
}
