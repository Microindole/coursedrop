import { AppColors, AppSize, AppSpacing, AppTypography } from '../../common/Theme';

@Component
export struct CdEmptyState {
  title: string = '';
  description: string = '';
  mark: string = 'EMPTY';

  build() {
    Column({ space: AppSpacing.SM }) {
      Text(this.mark)
        .fontSize(AppTypography.CAPTION)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppColors.TEXT_SECONDARY)
        .width(AppSize.ICON_LG + 24)
        .height(AppSize.ICON_LG)
        .textAlign(TextAlign.Center)
        .backgroundColor(AppColors.SURFACE_MUTED)

      Text(this.title)
        .fontSize(AppTypography.SUBTITLE)
        .fontWeight(FontWeight.Medium)
        .fontColor(AppColors.TEXT)

      if (this.description.length > 0) {
        Text(this.description)
          .fontSize(AppTypography.BODY_SMALL)
          .fontColor(AppColors.TEXT_SECONDARY)
          .lineHeight(20)
          .textAlign(TextAlign.Center)
      }
    }
    .width('100%')
    .padding({ top: AppSpacing.XL, bottom: AppSpacing.XL })
    .alignItems(HorizontalAlign.Center)
  }
}
