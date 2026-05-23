import { AppColors, AppRadius, AppSpacing } from '../../common/Theme';

@Component
export struct CdDrawer {
  @Link visible: boolean;
  width: number = 304;
  @BuilderParam content: () => void = this.defaultContent;

  @Builder
  defaultContent() {
  }

  build() {
    if (this.visible) {
      Stack({ alignContent: Alignment.Start }) {
        Rect()
          .width('100%')
          .height('100%')
          .fill('#66000000')
          .onClick(() => {
            this.visible = false;
          })

        Column() {
          this.content()
        }
        .width(this.width)
        .height('100%')
        .padding(AppSpacing.LG)
        .backgroundColor(AppColors.SURFACE)
        .borderRadius({
          topRight: AppRadius.LG,
          bottomRight: AppRadius.LG
        })
      }
      .width('100%')
      .height('100%')
    }
  }
}
