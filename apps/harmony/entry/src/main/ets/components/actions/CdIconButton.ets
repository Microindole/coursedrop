import { AppColors, AppRadius, AppSize } from '../../common/Theme';

export type CdIconButtonVariant = 'plain' | 'tonal' | 'danger';

@Component
export struct CdIconButton {
  mark: string = '...';
  variant: CdIconButtonVariant = 'plain';
  interactive: boolean = true;
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
      Text(this.mark)
        .fontSize(AppSize.ICON_MD)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.resolveIconColor())
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
