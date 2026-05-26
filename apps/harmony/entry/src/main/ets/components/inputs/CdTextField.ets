import { AppColors, AppSize, AppSpacing, AppTypography } from '../../common/Theme';

@Component
export struct CdTextField {
  @Prop label: string = '';
  @Prop placeholder: string = '';
  @Link value: string;

  build() {
    Column({ space: AppSpacing.XS }) {
      if (this.label.length > 0) {
        Text(this.label)
          .fontSize(AppTypography.CAPTION)
          .fontColor(AppColors.TEXT_SECONDARY)
          .fontWeight(FontWeight.Medium)
      }

      TextInput({ placeholder: this.placeholder, text: this.value })
        .height(AppSize.INPUT_HEIGHT)
        .fontSize(AppTypography.BODY)
        .fontColor(AppColors.TEXT)
        .placeholderColor(AppColors.TEXT_SECONDARY)
        .backgroundColor(Color.Transparent)
        .borderRadius(0)
        .padding({ left: 0, right: 0 })
        .onChange((value: string) => {
          this.value = value;
        })

      Divider()
        .strokeWidth(1)
        .color(AppColors.BORDER_STRONG)
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
  }
}
