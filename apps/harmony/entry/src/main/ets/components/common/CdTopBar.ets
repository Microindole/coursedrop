import { AppColors, AppSize, AppSpacing, AppTypography } from '../../common/Theme';

@Component
export struct CdTopBar {
  title: string = '';
  subtitle: string = '';
  leadingText: string = '';
  trailingText: string = '';
  onLeadingTap: () => void = () => {};
  onTrailingTap: () => void = () => {};

  build() {
    Row() {
      if (this.leadingText.length > 0) {
        Text(this.leadingText)
          .fontSize(AppTypography.BODY_SMALL)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppColors.PRIMARY_SELECTED)
          .width(56)
          .onClick(() => {
            this.onLeadingTap();
          })
      } else {
        Blank()
          .width(56)
      }

      Column({ space: AppSpacing.XS }) {
        Text(this.title)
          .fontSize(AppTypography.SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.TEXT)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        if (this.subtitle.length > 0) {
          Text(this.subtitle)
            .fontSize(AppTypography.CAPTION)
            .fontColor(AppColors.TEXT_SECONDARY)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
      .alignItems(HorizontalAlign.Center)
      .layoutWeight(1)

      if (this.trailingText.length > 0) {
        Text(this.trailingText)
          .fontSize(AppTypography.BODY_SMALL)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppColors.PRIMARY_SELECTED)
          .textAlign(TextAlign.End)
          .width(56)
          .onClick(() => {
            this.onTrailingTap();
          })
      } else {
        Blank()
          .width(56)
      }
    }
    .width('100%')
    .height(AppSize.TAB_BAR_HEIGHT)
    .alignItems(VerticalAlign.Center)
    .padding({ left: AppSpacing.XS, right: AppSpacing.XS })
  }
}
