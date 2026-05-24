import { AppColors, AppRadius, AppSize, AppSpacing, AppTypography } from '../../common/Theme';

@Component
export struct CdSearchField {
  placeholder: string = '搜索';
  @Link value: string;
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
        .placeholderColor(AppColors.TEXT_SECONDARY)
        .backgroundColor(Color.Transparent)
        .padding({ left: 0, right: 0 })
        .onChange((value: string) => {
          this.value = value;
        })
        .onSubmit(() => {
          this.onSubmit();
        })
    }
    .width('100%')
    .height(AppSize.INPUT_HEIGHT)
    .padding({ left: AppSpacing.MD, right: AppSpacing.MD })
    .backgroundColor(AppColors.SURFACE)
    .borderRadius(AppRadius.LG)
  }
}
