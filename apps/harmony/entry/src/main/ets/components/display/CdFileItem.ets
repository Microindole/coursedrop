import { AppColors, AppRadius, AppSize, AppSpacing, AppTypography } from '../../common/Theme';

export type CdFileTone = 'file' | 'image' | 'link' | 'text';

@Component
export struct CdFileItem {
  name: string = '';
  meta: string = '';
  tone: CdFileTone = 'file';
  onTap: () => void = () => {};

  private resolveSymbol(): Resource {
    if (this.tone === 'image') {
      return $r('sys.symbol.photo_fill');
    }
    if (this.tone === 'link') {
      return $r('sys.symbol.link');
    }
    if (this.tone === 'text') {
      return $r('sys.symbol.text_alignleft');
    }
    return $r('sys.symbol.doc_fill');
  }

  build() {
    Row() {
      Row() {
        SymbolGlyph(this.resolveSymbol())
          .fontSize(AppSize.ICON_MD)
          .fontColor([AppColors.PRIMARY_SELECTED])
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

      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(AppSize.ICON_MD)
        .fontColor([AppColors.TEXT_SECONDARY])
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
