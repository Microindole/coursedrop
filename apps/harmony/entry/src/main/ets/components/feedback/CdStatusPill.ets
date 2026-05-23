import { AppColors, AppRadius, AppSpacing, AppTypography } from '../../common/Theme';

export type CdStatusTone = 'info' | 'success' | 'warning';

@Component
export struct CdStatusPill {
  label: string = '';
  tone: CdStatusTone = 'info';

  private resolveBackgroundColor(): string {
    if (this.tone === 'success') {
      return AppColors.SUCCESS_SOFT;
    }
    if (this.tone === 'warning') {
      return AppColors.WARNING_SOFT;
    }
    return AppColors.PRIMARY_SOFT;
  }

  private resolveTextColor(): string {
    if (this.tone === 'success') {
      return AppColors.SUCCESS;
    }
    if (this.tone === 'warning') {
      return AppColors.WARNING;
    }
    return AppColors.PRIMARY_DARK;
  }

  build() {
    Text(this.label)
      .fontSize(AppTypography.CAPTION)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.resolveTextColor())
      .padding({
        left: AppSpacing.SM,
        right: AppSpacing.SM,
        top: AppSpacing.XS,
        bottom: AppSpacing.XS
      })
      .backgroundColor(this.resolveBackgroundColor())
      .borderRadius(AppRadius.SM)
  }
}
