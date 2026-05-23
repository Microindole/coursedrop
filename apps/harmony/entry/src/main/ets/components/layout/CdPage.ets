import { AppColors, AppSpacing } from '../../common/Theme';

@Component
export struct CdPage {
  @BuilderParam content: () => void = this.defaultContent;

  @Builder
  defaultContent() {
  }

  build() {
    Column() {
      this.content()
    }
    .width('100%')
    .height('100%')
    .padding({
      left: AppSpacing.PAGE_HORIZONTAL,
      right: AppSpacing.PAGE_HORIZONTAL
    })
    .backgroundColor(AppColors.BACKGROUND)
  }
}
