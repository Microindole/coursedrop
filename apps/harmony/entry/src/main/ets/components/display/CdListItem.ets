import { AppColors, AppRadius, AppSize, AppSpacing, AppTypography } from '../../common/Theme';

@Component
export struct CdListItem {
  title: string = '';
  description: string = '';
  symbol: Resource = $r('sys.symbol.circle_fill');
  showChevron: boolean = true;
  onTap: () => void = () => {};

  build() {
    ListItem() {
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

          if (this.description.length > 0) {
            Text(this.description)
              .fontSize(AppTypography.CAPTION)
              .fontColor(AppColors.TEXT_SECONDARY)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        if (this.showChevron) {
          SymbolGlyph($r('sys.symbol.chevron_right'))
            .fontSize(AppSize.ICON_MD)
            .fontColor([AppColors.TEXT_SECONDARY])
        }
      }
      .width('100%')
      .minHeight(AppSize.LIST_ROW_HEIGHT)
      .padding({ left: AppSpacing.MD, right: AppSpacing.MD })
      .backgroundColor(AppColors.SURFACE)
      .borderRadius(AppRadius.LG)
    }
    .onClick(() => {
      this.onTap();
    })
  }
}
