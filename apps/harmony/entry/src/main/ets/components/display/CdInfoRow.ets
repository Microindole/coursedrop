import { AppColors, AppSize, AppSpacing, AppTypography } from '../../common/Theme';

@Component
export struct CdInfoRow {
  title: string = '';
  value: string = '';
  symbol: Resource = $r('sys.symbol.info_circle_fill');

  build() {
    Row() {
      SymbolGlyph(this.symbol)
        .fontSize(AppSize.ICON_MD)
        .fontColor([AppColors.PRIMARY_SELECTED])
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
