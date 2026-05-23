import { AppColors, AppSpacing, AppTypography } from '../../common/Theme';

@Component
export struct CdLink {
  label: string = '';
  symbol: Resource | null = null;
  onTap: () => void = () => {};

  build() {
    Row({ space: AppSpacing.XS }) {
      if (this.symbol !== null) {
        SymbolGlyph(this.symbol as Resource)
          .fontSize(AppTypography.BODY_SMALL)
          .fontColor([AppColors.PRIMARY])
      }

      Text(this.label)
        .fontSize(AppTypography.BODY_SMALL)
        .fontWeight(FontWeight.Medium)
        .fontColor(AppColors.PRIMARY)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.onTap();
    })
  }
}
