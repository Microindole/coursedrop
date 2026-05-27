import { AppColors, AppSpacing, AppTypography } from '../../common/Theme';

@Component
export struct CdSwitchRow {
  @Link isOn: boolean;
  title: string = '';
  description: string = '';
  onChange: (enabled: boolean) => void = () => {};

  build() {
    Row() {
      // 左侧文本说明区
      Column({ space: 2 }) {
        Text(this.title)
          .fontSize(AppTypography.BODY_SMALL)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.TEXT)
        
        if (this.description && this.description.length > 0) {
          Text(this.description)
            .fontSize(AppTypography.CAPTION)
            .fontColor(AppColors.TEXT_SECONDARY)
            .lineHeight(16)
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ right: AppSpacing.MD })

      // 右侧 Switch 组件
      Toggle({ type: ToggleType.Switch, isOn: this.isOn })
        .selectedColor(AppColors.PRIMARY)
        .switchPointColor(AppColors.SURFACE)
        .onChange((isOn: boolean) => {
          this.isOn = isOn;
          this.onChange(isOn);
        })
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .padding({ top: AppSpacing.SM, bottom: AppSpacing.SM })
  }
}
