import { AppColors, AppRadius, AppSize } from '../../common/Theme';

@Component
export struct CdIconButton {
  icon: Resource | null = null;
  variant: 'contained' | 'tonal' | 'plain' | 'danger' = 'contained';
  onTap: () => void = () => {};

  @State private isPressed: boolean = false;

  private resolveBgColor(): string {
    if (this.variant === 'tonal') return AppColors.PRIMARY_SOFT;
    if (this.variant === 'danger') return AppColors.DANGER;
    if (this.variant === 'plain') {
      return this.isPressed ? '#0D000000' : '#00000000';
    }
    return AppColors.PRIMARY;
  }

  private resolveIconColor(): string {
    if (this.variant === 'tonal') return AppColors.PRIMARY;
    if (this.variant === 'plain') return AppColors.PRIMARY_SELECTED;
    return AppColors.SURFACE;
  }

  build() {
    Stack() {
      if (this.icon) {
        Image(this.icon)
          .width(18)
          .height(18)
          .fillColor(this.resolveIconColor())
      }
    }
    .width(AppSize.BUTTON_HEIGHT)
    .height(AppSize.BUTTON_HEIGHT)
    .backgroundColor(this.resolveBgColor())
    .borderRadius(AppRadius.XL)
    .scale({
      x: this.isPressed ? 0.94 : 1,
      y: this.isPressed ? 0.94 : 1
    })
    .animation({ duration: 100 })
    .onTouch((event?: TouchEvent) => {
      if (event) {
        if (event.type === TouchType.Down) {
          this.isPressed = true;
        } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
          this.isPressed = false;
        }
      }
    })
    .onClick(() => {
      this.onTap();
    })
  }
}
