import { AppColors, AppRadius, AppSpacing, AppTypography } from '../../common/Theme';

export type CdExpireTone = 'active' | 'soon' | 'expired';

@Component
export struct CdExpireInfo {
  label: string = '';
  tone: CdExpireTone = 'active';

  private backgroundColor(): string {
    if (this.tone === 'soon') {
      return AppColors.WARNING_SOFT;
    }
    if (this.tone === 'expired') {
      return '#FFF0F0';
    }
    return AppColors.PRIMARY_SOFT;
  }

  private textColor(): string {
    if (this.tone === 'soon') {
      return AppColors.WARNING;
    }
    if (this.tone === 'expired') {
      return AppColors.DANGER;
    }
    return AppColors.PRIMARY_SELECTED;
  }

  build() {
    Row({ space: AppSpacing.XS }) {
      Text('EXP')
        .fontSize(AppTypography.CAPTION)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.textColor())

      Text(this.label)
        .fontSize(AppTypography.CAPTION)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.textColor())
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .padding({
      left: AppSpacing.SM,
      right: AppSpacing.SM,
      top: AppSpacing.XS,
      bottom: AppSpacing.XS
    })
    .backgroundColor(this.backgroundColor())
    .borderRadius(AppRadius.SM)
  }
}
