import { AppColors, AppRadius, AppSpacing, AppTypography } from '../../common/Theme';

@Component
export struct CdInfoRow {
  title: string = '';
  value: string = '';
  mark: string = '';

  private resolveMarkBg(): string {
    if (this.mark === 'IDENTITY') return AppColors.PRIMARY_SOFT;
    if (this.mark === 'SERVER') return AppColors.WARNING_SOFT;
    return AppColors.SURFACE_MUTED;
  }

  private resolveMarkColor(): string {
    if (this.mark === 'IDENTITY') return AppColors.PRIMARY;
    if (this.mark === 'SERVER') return AppColors.WARNING;
    return AppColors.TEXT_SECONDARY;
  }

  build() {
    Column({ space: AppSpacing.XS }) {
      Row() {
        Text(this.title)
          .fontSize(AppTypography.BODY_SMALL)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.TEXT)
        
        if (this.mark && this.mark.length > 0) {
          Row() {
            Text(this.mark)
              .fontSize(9)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.resolveMarkColor())
          }
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .borderRadius(4)
          .backgroundColor(this.resolveMarkBg())
          .margin({ left: AppSpacing.SM })
        }
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      if (this.value && this.value.length > 0) {
        Text(this.value)
          .fontSize(AppTypography.CAPTION)
          .fontColor(AppColors.TEXT_SECONDARY)
          .lineHeight(16)
          .width('100%')
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ top: AppSpacing.XS, bottom: AppSpacing.XS })
  }
}
