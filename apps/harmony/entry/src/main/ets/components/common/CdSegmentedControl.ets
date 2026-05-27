import { AppColors, AppRadius, AppSpacing, AppTypography } from '../../common/Theme';

@Component
export struct CdSegmentedControl {
  options: string[] = [];
  @Link selectedIndex: number;
  onChange: (index: number) => void = () => {};

  build() {
    Row() {
      ForEach(this.options, (option: string) => {
        Text(option)
          .fontSize(AppTypography.BODY_SMALL)
          .fontWeight(this.selectedIndex === this.options.indexOf(option) ? FontWeight.Bold : FontWeight.Medium)
          .fontColor(this.selectedIndex === this.options.indexOf(option) ? AppColors.PRIMARY : AppColors.TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
          .padding({ top: AppSpacing.SM + 2, bottom: AppSpacing.SM + 2 })
          .backgroundColor(this.selectedIndex === this.options.indexOf(option) ? AppColors.SURFACE : '#00000000')
          .borderRadius(AppRadius.MD)
          .shadow(this.selectedIndex === this.options.indexOf(option) ? { radius: 6, color: '#0A000000', offsetX: 0, offsetY: 2 } : null)
          .onClick(() => {
            const targetIndex = this.options.indexOf(option);
            if (this.selectedIndex !== targetIndex) {
              animateTo({ duration: 200, curve: Curve.FastOutSlowIn }, () => {
                this.selectedIndex = targetIndex;
              });
              this.onChange(targetIndex);
            }
          })
      }, (option: string) => option)
    }
    .width('100%')
    .padding(4)
    .backgroundColor(AppColors.SURFACE_MUTED)
    .borderRadius(AppRadius.LG)
  }
}
