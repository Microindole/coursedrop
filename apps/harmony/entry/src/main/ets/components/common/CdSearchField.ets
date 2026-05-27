import { AppColors, AppRadius, AppSize, AppSpacing, AppTypography } from '../../common/Theme';

@Component
export struct CdSearchField {
  placeholder: string = '搜索';
  @Link value: string;
  onChangeValue: (value: string) => void = () => {};
  onSubmit: () => void = () => {};

  build() {
    Row({ space: AppSpacing.SM }) {
      Image($r('app.media.cd_icon_search'))
        .width(18)
        .height(18)
        .fillColor(AppColors.TEXT_SECONDARY)

      TextInput({ placeholder: this.placeholder, text: this.value })
        .layoutWeight(1)
        .height(AppSize.INPUT_HEIGHT)
        .fontSize(AppTypography.BODY_SMALL)
        .fontColor(AppColors.TEXT)
        .placeholderColor(AppColors.MUTED)
        .backgroundColor(Color.Transparent)
        .padding({ left: 0, right: 0 })
        .onChange((value: string) => {
          this.value = value;
          this.onChangeValue(value);
        })
        .onSubmit(() => {
          this.onSubmit();
        })

      if (this.value.length > 0) {
        Image($r('app.media.cd_icon_close'))
          .width(16)
          .height(16)
          .fillColor(AppColors.MUTED)
          .onClick(() => {
            animateTo({ duration: 150 }, () => {
              this.value = '';
            });
            this.onChangeValue('');
          })
      }
    }
    .width('100%')
    .height(AppSize.INPUT_HEIGHT)
    .padding({ left: AppSpacing.MD, right: AppSpacing.MD })
    .backgroundColor(AppColors.SURFACE_MUTED)
    .borderRadius(AppRadius.LG)
    .border({ width: 0.5, color: AppColors.BORDER })
  }
}
