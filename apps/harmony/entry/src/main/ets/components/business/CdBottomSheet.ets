import { AppColors, AppRadius, AppSpacing } from '../../common/Theme';

@Component
export struct CdBottomSheet {
  @Link visible: boolean;
  @BuilderParam content: () => void = this.defaultContent;

  @Builder
  defaultContent() {
  }

  build() {
    if (this.visible) {
      Stack({ alignContent: Alignment.Bottom }) {
        Rect()
          .width('100%')
          .height('100%')
          .fill('#66000000')
          .onClick(() => {
            this.visible = false;
          })

        Column({ space: AppSpacing.MD }) {
          Row()
            .width(36)
            .height(4)
            .backgroundColor(AppColors.BORDER_STRONG)
            .borderRadius(AppRadius.SM)
            .margin({ bottom: AppSpacing.SM })

          this.content()
        }
        .width('100%')
        .padding({
          left: AppSpacing.LG,
          right: AppSpacing.LG,
          top: AppSpacing.MD,
          bottom: AppSpacing.XL
        })
        .backgroundColor(AppColors.SURFACE)
        .borderRadius({
          topLeft: AppRadius.LG,
          topRight: AppRadius.LG
        })
      }
      .width('100%')
      .height('100%')
    }
  }
}
