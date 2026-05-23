import { AppColors, AppSpacing } from '../../common/Theme';

@Component
export struct CdScrollContainer {
  showScrollBar: boolean = false;
  @BuilderParam content: () => void = this.defaultContent;

  @Builder
  defaultContent() {
  }

  build() {
    Scroll() {
      Column({ space: AppSpacing.MD }) {
        this.content()
      }
      .width('100%')
      .padding({
        left: AppSpacing.PAGE_HORIZONTAL,
        right: AppSpacing.PAGE_HORIZONTAL,
        bottom: AppSpacing.XL
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColors.BACKGROUND)
    .scrollBar(this.showScrollBar ? BarState.Auto : BarState.Off)
  }
}
