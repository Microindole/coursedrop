import { AppColors, AppRadius, AppSpacing, AppShadows } from '../../common/Theme';

@Component
export struct CdPanel {
  @BuilderParam content: () => void = this.defaultContent;
  hasShadow: boolean = true;
  clickable: boolean = false;
  onTap: () => void = () => {};

  @State private isPressed: boolean = false;

  @Builder
  defaultContent() {}

  build() {
    Column() {
      this.content()
    }
    .width('100%')
    .padding(AppSpacing.MD)
    .backgroundColor(AppColors.SURFACE)
    .borderRadius(AppRadius.LG)
    .border({ width: 0.5, color: AppColors.BORDER })
    .shadow(this.hasShadow ? AppShadows.CARD : null)
    .scale({
      x: this.clickable && this.isPressed ? 0.98 : 1,
      y: this.clickable && this.isPressed ? 0.98 : 1
    })
    .animation({ duration: 150, curve: Curve.FastOutSlowIn })
    .onTouch((event?: TouchEvent) => {
      if (this.clickable && event) {
        if (event.type === TouchType.Down) {
          this.isPressed = true;
        } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
          this.isPressed = false;
        }
      }
    })
    .onClick(() => {
      if (this.clickable) {
        this.onTap();
      }
    })
  }
}
