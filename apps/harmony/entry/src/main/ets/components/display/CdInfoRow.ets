import { AppColors, AppSize, AppSpacing, AppTypography } from '../../common/Theme';

@Component
export struct CdInfoRow {
  @Prop title: string = '';
  @Prop value: string = '';
  @Prop mark: string = '';

  private resolveIcon(): Resource {
    if (this.mark === 'LINK') {
      return $r('app.media.cd_icon_link');
    }
    return $r('app.media.cd_icon_server');
  }

  build() {
    Row() {
      Image(this.resolveIcon())
        .width(AppSize.ICON_MD)
        .height(AppSize.ICON_MD)
        .fillColor(AppColors.PRIMARY_SELECTED)
        .margin({ right: AppSpacing.MD })

      Column({ space: AppSpacing.XS }) {
        Text(this.title)
          .fontSize(AppTypography.BODY)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppColors.TEXT)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(this.value)
          .fontSize(AppTypography.CAPTION)
          .fontColor(AppColors.TEXT_SECONDARY)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .height(AppSize.LIST_ROW_HEIGHT)
    .alignItems(VerticalAlign.Center)
  }
}
