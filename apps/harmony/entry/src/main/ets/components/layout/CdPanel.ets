import { AppColors, AppRadius, AppSpacing } from '../../common/Theme';

@Component
export struct CdPanel {
  @BuilderParam content: () => void = this.defaultContent;

  @Builder
  defaultContent() {
  }

  build() {
    Column() {
      this.content()
    }
    .width('100%')
    .padding(AppSpacing.MD)
    .backgroundColor(AppColors.SURFACE)
    .borderRadius(AppRadius.LG)
  }
}
