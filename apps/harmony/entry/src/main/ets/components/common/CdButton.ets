import { AppColors, AppRadius, AppSize, AppSpacing, AppTypography } from '../../common/Theme';

@Component
export struct CdButton {
  @Prop label: string = '';
  variant: 'contained' | 'tonal' | 'text' | 'danger' = 'contained';
  @Prop interactive: boolean = true;
  onTap: () => void = () => {};

  @State private isPressed: boolean = false;

  private resolveBgColor(): string {
    if (!this.interactive) return AppColors.SURFACE_MUTED;
    if (this.variant === 'tonal') return AppColors.PRIMARY_SOFT;
    if (this.variant === 'text') return '#00000000';
    if (this.variant === 'danger') return AppColors.DANGER;
    return AppColors.PRIMARY;
  }

  private resolveTextColor(): string {
    if (!this.interactive) return AppColors.MUTED;
    if (this.variant === 'tonal') return AppColors.PRIMARY;
    if (this.variant === 'text') return AppColors.PRIMARY_SELECTED;
    if (this.variant === 'danger' || this.variant === 'contained') return AppColors.SURFACE;
    return AppColors.SURFACE;
  }

  build() {
    Row() {
      Text(this.label)
        .fontSize(AppTypography.BODY_SMALL)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.resolveTextColor())
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height(AppSize.BUTTON_HEIGHT)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.resolveBgColor())
    .borderRadius(AppRadius.XL)
    .scale({
      x: this.interactive && this.isPressed ? 0.96 : 1,
      y: this.interactive && this.isPressed ? 0.96 : 1
    })
    .animation({ duration: 100, curve: Curve.EaseOut })
    .onTouch((event?: TouchEvent) => {
      if (this.interactive && event) {
        if (event.type === TouchType.Down) {
          this.isPressed = true;
        } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
          this.isPressed = false;
        }
      }
    })
    .onClick(() => {
      if (this.interactive) {
        this.onTap();
      }
    })
  }
}
