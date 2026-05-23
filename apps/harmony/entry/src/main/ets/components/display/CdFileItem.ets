import { AppColors, AppRadius, AppSize, AppSpacing, AppTypography } from '../../common/Theme';

export type CdFileTone = 'file' | 'image' | 'link' | 'text';

@Component
export struct CdFileItem {
  name: string = '';
  meta: string = '';
  tone: CdFileTone = 'file';
  onTap: () => void = () => {};

  private resolveMark(): string {
    if (this.tone === 'image') {
      return 'IMG';
    }
    if (this.tone === 'link') {
      return 'URL';
    }
    if (this.tone === 'text') {
      return 'TXT';
    }
    return 'DOC';
  }

  build() {
    Row() {
      Row() {
        Text(this.resolveMark())
          .fontSize(AppTypography.CAPTION)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.PRIMARY_SELECTED)
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

      Text('>')
        .fontSize(AppTypography.BODY)
        .fontColor(AppColors.TEXT_SECONDARY)
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
