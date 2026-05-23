import { AppColors, AppRadius, AppSpacing, AppTypography } from '../../common/Theme';

export type CdNetworkMode = 'lan' | 'relay' | 'e2ee' | 'offline';

@Component
export struct CdNetworkBadge {
  mode: CdNetworkMode = 'relay';

  private label(): string {
    if (this.mode === 'lan') {
      return 'LAN';
    }
    if (this.mode === 'e2ee') {
      return 'E2EE';
    }
    if (this.mode === 'offline') {
      return 'OFFLINE';
    }
    return 'RELAY';
  }

  private backgroundColor(): string {
    if (this.mode === 'lan' || this.mode === 'e2ee') {
      return AppColors.SUCCESS_SOFT;
    }
    if (this.mode === 'offline') {
      return AppColors.SURFACE_MUTED;
    }
    return AppColors.PRIMARY_SOFT;
  }

  private textColor(): string {
    if (this.mode === 'lan' || this.mode === 'e2ee') {
      return AppColors.SUCCESS;
    }
    if (this.mode === 'offline') {
      return AppColors.TEXT_SECONDARY;
    }
    return AppColors.PRIMARY_SELECTED;
  }

  build() {
    Text(this.label())
      .fontSize(AppTypography.CAPTION)
      .fontWeight(FontWeight.Bold)
      .fontColor(this.textColor())
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
