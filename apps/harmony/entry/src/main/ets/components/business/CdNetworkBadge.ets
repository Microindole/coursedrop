import { AppColors, AppRadius, AppSpacing } from '../../common/Theme';

export type CdNetworkMode = 'lan' | 'relay' | 'e2ee' | 'offline';

@Component
export struct CdNetworkBadge {
  mode: CdNetworkMode = 'relay';

  private resolveIcon(): Resource {
    if (this.mode === 'lan') {
      return $r('app.media.cd_icon_lan');
    }
    if (this.mode === 'e2ee') {
      return $r('app.media.cd_icon_lock');
    }
    if (this.mode === 'offline') {
      return $r('app.media.cd_icon_offline');
    }
    return $r('app.media.cd_icon_relay');
  }

  private resolveBackgroundColor(): string {
    if (this.mode === 'lan' || this.mode === 'e2ee') {
      return AppColors.SUCCESS_SOFT;
    }
    if (this.mode === 'offline') {
      return AppColors.SURFACE_MUTED;
    }
    return AppColors.PRIMARY_SOFT;
  }

  private resolveTextColor(): string {
    if (this.mode === 'lan' || this.mode === 'e2ee') {
      return AppColors.SUCCESS;
    }
    if (this.mode === 'offline') {
      return AppColors.TEXT_SECONDARY;
    }
    return AppColors.PRIMARY_SELECTED;
  }

  build() {
    Image(this.resolveIcon())
      .width(16)
      .height(16)
      .fillColor(this.resolveTextColor())
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
