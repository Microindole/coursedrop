import { AppColors, AppSpacing, AppTypography } from '../../common/Theme';

@Component
export struct CdPageTitle {
  title: string = '';
  subtitle: string = '';

  build() {
    Column({ space: AppSpacing.SM }) {
      Text(this.title)
        .width('100%')
        .fontSize(AppTypography.DISPLAY)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppColors.TEXT)

      if (this.subtitle.length > 0) {
        Text(this.subtitle)
          .width('100%')
          .fontSize(AppTypography.BODY_SMALL)
          .fontColor(AppColors.TEXT_SECONDARY)
          .lineHeight(22)
      }
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
  }
}
