import { AppColors, AppRadius, AppSize } from '../../common/Theme';

export type CdIconButtonVariant = 'plain' | 'tonal' | 'danger';

@Component
export struct CdIconButton {
  symbol: Resource = $r('sys.symbol.ellipsis');
  variant: CdIconButtonVariant = 'plain';
  enabled: boolean = true;
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
      SymbolGlyph(this.symbol)
        .fontSize(AppSize.ICON_MD)
        .fontColor([this.resolveIconColor()])
    }
    .width(40)
    .height(40)
    .backgroundColor(this.resolveBackgroundColor())
    .borderRadius(AppRadius.XL)
    .enabled(this.enabled)
    .opacity(this.enabled ? 1 : 0.45)
    .onClick(() => {
      if (this.enabled) {
        this.onTap();
      }
    })
  }
}
