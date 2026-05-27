import { AppColors, AppRadius, AppSize, AppSpacing, AppTypography } from '../../common/Theme';

export type CdFileTone = 'file' | 'image' | 'link' | 'text';

@Component
export struct CdFileItem {
  @Prop name: string = '';
  @Prop meta: string = '';
  @Prop tone: CdFileTone = 'file';
  onTap: () => void = () => {};

  private resolveIcon(): Resource {
    if (this.tone === 'image') {
      return $r('app.media.cd_icon_image');
    }
    if (this.tone === 'link') {
      return $r('app.media.cd_icon_link');
    }
    if (this.tone === 'text') {
      return $r('app.media.cd_icon_text');
    }
    return $r('app.media.cd_icon_file');
  }

  build() {
    Row() {
      Row() {
        Image(this.resolveIcon())
          .width(24)
          .height(24)
          .fillColor(AppColors.PRIMARY_SELECTED)
      }
      .width(44)
      .height(44)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(AppColors.PRIMARY_SOFT)
      .borderRadius(AppRadius.MD)
      .margin({ right: AppSpacing.MD })

      Column({ space: AppSpacing.XS }) {
        Text(this.name)
          .fontSize(AppTypography.BODY)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppColors.TEXT)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(this.meta)
          .fontSize(AppTypography.CAPTION)
          .fontColor(AppColors.TEXT_SECONDARY)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Image($r('app.media.cd_icon_share'))
        .width(18)
        .height(18)
        .fillColor(AppColors.TEXT_SECONDARY)
    }
    .width('100%')
    .padding({
      left: AppSpacing.MD,
      right: AppSpacing.MD,
      top: AppSpacing.MD,
      bottom: AppSpacing.MD
    })
    .backgroundColor(AppColors.SURFACE)
    .borderRadius(AppRadius.LG)
    .onClick(() => {
      this.onTap();
    })
  }
}
