import { AppColors, AppRadius, AppSpacing, AppTypography } from '../../common/Theme';

@Component
export struct CdTransferStats {
  activeCount: number = 0;
  completedCount: number = 0;
  failedCount: number = 0;
  expiringCount: number = 0;

  @Builder
  statCell(label: string, value: number, color: string) {
    Column({ space: AppSpacing.XS }) {
      Text(`${value}`)
        .fontSize(AppTypography.TITLE)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)

      Text(label)
        .fontSize(AppTypography.CAPTION)
        .fontColor(AppColors.TEXT_SECONDARY)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    Row() {
      this.statCell('进行中', this.activeCount, AppColors.PRIMARY_SELECTED)
      this.statCell('已完成', this.completedCount, AppColors.SUCCESS)
      this.statCell('失败', this.failedCount, AppColors.DANGER)
      this.statCell('将过期', this.expiringCount, AppColors.WARNING)
    }
    .width('100%')
    .padding(AppSpacing.MD)
    .backgroundColor(AppColors.SURFACE)
    .borderRadius(AppRadius.LG)
  }
}
