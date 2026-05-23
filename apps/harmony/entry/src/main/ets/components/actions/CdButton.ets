import { AppColors, AppRadius, AppSize, AppTypography } from '../../common/Theme';

export type CdButtonVariant = 'contained' | 'tonal' | 'text' | 'danger';

@Component
export struct CdButton {
  label: string = '';
  variant: CdButtonVariant = 'contained';
  interactive: boolean = true;
  onTap: () => void = () => {};

  private resolveBackgroundColor(): string {
    if (this.variant === 'contained') {
      return AppColors.PRIMARY;
    }
    if (this.variant === 'danger') {
      return AppColors.SURFACE_MUTED;
    }
    if (this.variant === 'tonal') {
      return AppColors.PRIMARY_SOFT;
    }
    return AppColors.SURFACE;
  }

  private resolveTextColor(): ResourceColor {
    if (this.variant === 'contained') {
      return Color.White;
    }
    if (this.variant === 'danger') {
      return AppColors.DANGER;
    }
    return AppColors.PRIMARY;
  }

  build() {
    Button(this.label, { type: ButtonType.Capsule })
      .width('100%')
      .height(AppSize.BUTTON_HEIGHT)
      .fontSize(AppTypography.BODY)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.resolveTextColor())
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
