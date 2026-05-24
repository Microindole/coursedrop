import { AppColors, AppRadius, AppSpacing, AppTypography } from '../../common/Theme';

export type CdExpireTone = 'active' | 'soon' | 'expired';

@Component
export struct CdExpireInfo {
  label: string = '';
  tone: CdExpireTone = 'active';

  private resolveBackgroundColor(): string {
    if (this.tone === 'soon') {
      return AppColors.WARNING_SOFT;
    }
    if (this.tone === 'expired') {
      return '#FFF0F0';
    }
    return AppColors.PRIMARY_SOFT;
  }

  private resolveTextColor(): string {
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
      Image($r('app.media.cd_icon_expire'))
        .width(14)
        .height(14)
        .fillColor(this.resolveTextColor())

      Text(this.label)
        .fontSize(AppTypography.CAPTION)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.resolveTextColor())
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
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
