import { AppColors, AppRadius, AppSize } from '../../common/Theme';

export type CdIconButtonVariant = 'plain' | 'tonal' | 'danger';

@Component
export struct CdIconButton {
  @Prop icon: Resource = $r('app.media.cd_icon_share');
  @Prop variant: CdIconButtonVariant = 'plain';
  @Prop interactive: boolean = true;
  onTap: () => void = () => {};

  private resolveBackgroundColor(): ResourceColor {
    if (this.variant === 'tonal') {
      return AppColors.PRIMARY_SOFT;
    }
    if (this.variant === 'danger') {
      return AppColors.SURFACE_MUTED;
    }
    return Color.Transparent;
  }

  private resolveIconColor(): string {
    if (this.variant === 'danger') {
      return AppColors.DANGER;
    }
    if (this.variant === 'tonal') {
      return AppColors.PRIMARY_SELECTED;
    }
    return AppColors.TEXT;
  }

  build() {
    Button({ type: ButtonType.Circle }) {
      Image(this.icon)
        .width(AppSize.ICON_MD)
        .height(AppSize.ICON_MD)
        .fillColor(this.resolveIconColor())
    }
    .width(40)
    .height(40)
    .backgroundColor(this.resolveBackgroundColor())
    .borderRadius(AppRadius.XL)
    .enabled(this.interactive)
    .opacity(this.interactive ? 1 : 0.45)
    .onClick(() => {
      if (this.interactive) {
        this.onTap();
      }
    })
  }
}
