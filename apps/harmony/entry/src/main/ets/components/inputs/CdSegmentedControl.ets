import { AppColors, AppRadius, AppSpacing, AppTypography } from '../../common/Theme';

@Component
export struct CdSegmentedControl {
  options: string[] = [];
  @Link selectedIndex: number;
  onChange: (index: number) => void = () => {};

  build() {
    Row({ space: AppSpacing.XS }) {
      ForEach(this.options, (option: string, index: number) => {
        Text(option)
          .fontSize(AppTypography.BODY_SMALL)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.selectedIndex === index ? AppColors.PRIMARY_SELECTED : AppColors.TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
          .padding({ top: AppSpacing.SM, bottom: AppSpacing.SM })
          .backgroundColor(this.selectedIndex === index ? AppColors.SURFACE : Color.Transparent)
          .borderRadius(AppRadius.MD)
          .onClick(() => {
            this.selectedIndex = index;
            this.onChange(index);
          })
      }, (option: string) => option)
    }
    .width('100%')
    .padding(AppSpacing.XS)
    .backgroundColor(AppColors.SURFACE_MUTED)
    .borderRadius(AppRadius.LG)
  }
}
