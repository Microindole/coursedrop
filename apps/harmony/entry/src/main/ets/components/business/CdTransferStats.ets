import { AppColors, AppRadius, AppSpacing, AppTypography } from '../../common/Theme';

@Component
export struct CdTransferStats {
  statsActiveCount: number = 0;
  statsCompletedCount: number = 0;
  statsFailedCount: number = 0;
  statsExpiringCount: number = 0;

  @Builder
  statCell(icon: Resource, value: number, color: string) {
    Column({ space: AppSpacing.XS }) {
      Image(icon)
        .width(20)
        .height(20)
        .fillColor(color)

      Text(`${value}`)
        .fontSize(AppTypography.TITLE)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    Row() {
      this.statCell($r('app.media.cd_icon_running'), this.statsActiveCount, AppColors.PRIMARY_SELECTED)
      this.statCell($r('app.media.cd_icon_done'), this.statsCompletedCount, AppColors.SUCCESS)
      this.statCell($r('app.media.cd_icon_failed'), this.statsFailedCount, AppColors.DANGER)
      this.statCell($r('app.media.cd_icon_expire'), this.statsExpiringCount, AppColors.WARNING)
    }
    .width('100%')
    .padding(AppSpacing.MD)
    .backgroundColor(AppColors.SURFACE)
    .borderRadius(AppRadius.LG)
  }
}
