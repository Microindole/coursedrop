import { AppColors, AppSize, AppSpacing, AppTypography } from '../../common/Theme';

export interface CdTabItem {
  title: string;
  symbol: Resource;
}

@Component
export struct CdTabBar {
  items: CdTabItem[] = [];
  @Link currentIndex: number;
  onChange: (index: number) => void = () => {};

  @Builder
  tab(item: CdTabItem, index: number) {
    Column({ space: AppSpacing.XS }) {
      SymbolGlyph(item.symbol)
        .fontSize(AppSize.ICON_MD)
        .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_OPACITY)
        .fontColor(this.currentIndex === index ? [AppColors.PRIMARY_SELECTED] : [AppColors.TAB_NORMAL])

      Text(item.title)
        .fontSize(AppTypography.TAB)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.currentIndex === index ? AppColors.PRIMARY_SELECTED : AppColors.TAB_NORMAL)
    }
    .justifyContent(FlexAlign.Center)
    .height(AppSize.TAB_BAR_HEIGHT)
    .layoutWeight(1)
    .onClick(() => {
      this.currentIndex = index;
      this.onChange(index);
    })
  }

  build() {
    Row() {
      ForEach(this.items, (item: CdTabItem, index: number) => {
        this.tab(item, index)
      }, (item: CdTabItem) => item.title)
    }
    .width('100%')
    .height(AppSize.TAB_BAR_HEIGHT)
    .backgroundColor(AppColors.BACKGROUND)
  }
}
