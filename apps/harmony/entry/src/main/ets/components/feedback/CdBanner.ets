import { AppColors, AppRadius, AppSpacing, AppTypography } from '../../common/Theme';

export type CdBannerTone = 'info' | 'success' | 'warning' | 'danger';

@Component
export struct CdBanner {
  title: string = '';
  description: string = '';
  tone: CdBannerTone = 'info';
  actionText: string = '';
  onAction: () => void = () => {};

  private resolveBackgroundColor(): string {
    if (this.tone === 'success') {
      return AppColors.SUCCESS_SOFT;
    }
    if (this.tone === 'warning') {
      return AppColors.WARNING_SOFT;
    }
    if (this.tone === 'danger') {
      return '#FFF0F0';
    }
    return AppColors.PRIMARY_SOFT;
  }

  private resolveAccentColor(): string {
    if (this.tone === 'success') {
      return AppColors.SUCCESS;
    }
    if (this.tone === 'warning') {
      return AppColors.WARNING;
    }
    if (this.tone === 'danger') {
      return AppColors.DANGER;
    }
    return AppColors.PRIMARY_SELECTED;
  }

  build() {
    Row() {
      Column({ space: AppSpacing.XS }) {
        Text(this.title)
          .fontSize(AppTypography.BODY)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.TEXT)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        if (this.description.length > 0) {
          Text(this.description)
            .fontSize(AppTypography.BODY_SMALL)
            .fontColor(AppColors.TEXT_SECONDARY)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      if (this.actionText.length > 0) {
        Text(this.actionText)
          .fontSize(AppTypography.BODY_SMALL)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.resolveAccentColor())
          .margin({ left: AppSpacing.MD })
          .onClick(() => {
            this.onAction();
          })
      }
    }
    .width('100%')
    .padding(AppSpacing.MD)
    .backgroundColor(this.resolveBackgroundColor())
    .borderRadius(AppRadius.LG)
  }
}
