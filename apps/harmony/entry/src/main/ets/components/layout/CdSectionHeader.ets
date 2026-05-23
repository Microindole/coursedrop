import { AppColors, AppSpacing, AppTypography } from '../../common/Theme';

@Component
export struct CdSectionHeader {
  title: string = '';
  actionText: string = '';
  onAction: () => void = () => {};

  build() {
    Row() {
      Text(this.title)
        .fontSize(AppTypography.TITLE)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppColors.TEXT)
        .layoutWeight(1)

      if (this.actionText.length > 0) {
        Text(this.actionText)
          .fontSize(AppTypography.BODY_SMALL)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppColors.PRIMARY)
          .onClick(() => {
            this.onAction();
          })
      }
    }
    .width('100%')
    .padding({ top: AppSpacing.SM, bottom: AppSpacing.SM })
  }
}
