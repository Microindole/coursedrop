import { AppColors, AppRadius, AppSize, AppSpacing, AppTypography } from '../../common/Theme';

@Component
export struct CdActionTile {
  title: string = '';
  subtitle: string = '';
  symbol: Resource = $r('sys.symbol.folder_fill');
  onTap: () => void = () => {};

  build() {
    Column({ space: AppSpacing.XS }) {
      SymbolGlyph(this.symbol)
        .fontSize(AppSize.ICON_LG)
        .fontColor([AppColors.PRIMARY_SELECTED])

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
