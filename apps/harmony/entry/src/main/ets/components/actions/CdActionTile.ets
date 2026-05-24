import { AppColors, AppRadius, AppSize, AppSpacing, AppTypography } from '../../common/Theme';

@Component
export struct CdActionTile {
  title: string = '';
  subtitle: string = '';
  mark: string = '';
  onTap: () => void = () => {};

  private resolveIcon(): Resource {
    if (this.mark === 'IMG') {
      return $r('app.media.cd_icon_image');
    }
    if (this.mark === 'TXT') {
      return $r('app.media.cd_icon_text');
    }
    if (this.mark === 'URL') {
      return $r('app.media.cd_icon_link');
    }
    return $r('app.media.cd_icon_file');
  }

  build() {
    Column({ space: AppSpacing.XS }) {
      Image(this.resolveIcon())
        .width(AppSize.ICON_LG)
        .height(AppSize.ICON_LG)
        .fillColor(AppColors.PRIMARY_SELECTED)
        .padding(AppSpacing.SM)
        .backgroundColor(AppColors.PRIMARY_SOFT)
        .borderRadius(AppRadius.MD)

      Text(this.title)
        .fontSize(AppTypography.BODY_SMALL)
        .fontWeight(FontWeight.Medium)
        .fontColor(AppColors.TEXT)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      if (this.subtitle.length > 0) {
        Text(this.subtitle)
          .fontSize(AppTypography.CAPTION)
          .fontColor(AppColors.TEXT_SECONDARY)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height(96)
    .padding(AppSpacing.SM)
    .backgroundColor(AppColors.SURFACE)
    .borderRadius(AppRadius.LG)
    .onClick(() => {
      this.onTap();
    })
  }
}
