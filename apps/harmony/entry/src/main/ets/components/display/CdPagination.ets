import { AppColors, AppRadius, AppSpacing, AppTypography } from '../../common/Theme';

@Component
export struct CdPagination {
  @Link currentPage: number;
  totalPages: number = 1;
  onChange: (page: number) => void = () => {};

  private goTo(page: number): void {
    if (page < 1 || page > this.totalPages || page === this.currentPage) {
      return;
    }
    this.currentPage = page;
    this.onChange(page);
  }

  build() {
    Row({ space: AppSpacing.MD }) {
      Text('上一页')
        .fontSize(AppTypography.BODY_SMALL)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.currentPage > 1 ? AppColors.PRIMARY_SELECTED : AppColors.TEXT_SECONDARY)
        .opacity(this.currentPage > 1 ? 1 : 0.45)
        .onClick(() => {
          this.goTo(this.currentPage - 1);
        })

      Text(`${this.currentPage} / ${this.totalPages}`)
        .fontSize(AppTypography.BODY_SMALL)
        .fontWeight(FontWeight.Medium)
        .fontColor(AppColors.TEXT)
        .textAlign(TextAlign.Center)
        .layoutWeight(1)
        .padding({ top: AppSpacing.SM, bottom: AppSpacing.SM })
        .backgroundColor(AppColors.SURFACE)
        .borderRadius(AppRadius.MD)

      Text('下一页')
        .fontSize(AppTypography.BODY_SMALL)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.currentPage < this.totalPages ? AppColors.PRIMARY_SELECTED : AppColors.TEXT_SECONDARY)
        .opacity(this.currentPage < this.totalPages ? 1 : 0.45)
        .onClick(() => {
          this.goTo(this.currentPage + 1);
        })
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }
}
