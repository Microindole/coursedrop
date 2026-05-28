import { AppColors, AppRadius, AppSpacing, AppTypography } from '../../common/Theme';

@Component
export struct CdBanner {
  title: string = '';
  description: string = '';
  tone: 'info' | 'success' | 'warning' | 'danger' = 'info';
  actionText: string = '';
  onAction: () => void = () => {};

  private resolveBg(): string {
    if (this.tone === 'success') return AppColors.SUCCESS_SOFT;
    if (this.tone === 'warning') return AppColors.WARNING_SOFT;
    if (this.tone === 'danger') return AppColors.DANGER_SOFT;
    return AppColors.PRIMARY_SOFT;
  }

  private resolveBorderColor(): string {
    if (this.tone === 'success') return AppColors.SUCCESS;
    if (this.tone === 'warning') return AppColors.WARNING;
    if (this.tone === 'danger') return AppColors.DANGER;
    return AppColors.PRIMARY;
  }

  build() {
    Row({ space: AppSpacing.MD }) {
      Row()
        .width(4)
        .height(44)
        .borderRadius(2)
        .backgroundColor(this.resolveBorderColor())

      Column({ space: AppSpacing.XS }) {
        Text(this.title)
          .fontSize(AppTypography.BODY_SMALL)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.resolveBorderColor())
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        if (this.description.length > 0) {
          Text(this.description)
            .fontSize(AppTypography.CAPTION)
            .fontColor(AppColors.TEXT_SECONDARY)
            .lineHeight(16)
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      if (this.actionText.length > 0) {
        Text(this.actionText)
          .fontSize(AppTypography.CAPTION)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.resolveBorderColor())
          .onClick(() => {
            this.onAction();
          })
      }
    }
    .width('100%')
    .padding(AppSpacing.LG)
    .backgroundColor(this.resolveBg())
    .borderRadius(AppRadius.LG)
    .border({ width: 0.7, color: this.resolveBorderColor() })
  }
}
