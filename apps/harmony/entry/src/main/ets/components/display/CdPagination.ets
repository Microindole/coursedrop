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
      Button({ type: ButtonType.Circle }) {
        Image($r('app.media.cd_icon_prev'))
          .width(20)
          .height(20)
          .fillColor(this.currentPage > 1 ? AppColors.PRIMARY_SELECTED : AppColors.TEXT_SECONDARY)
      }
        .width(40)
        .height(40)
        .backgroundColor(AppColors.SURFACE)
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

      Button({ type: ButtonType.Circle }) {
        Image($r('app.media.cd_icon_next'))
          .width(20)
          .height(20)
          .fillColor(this.currentPage < this.totalPages ? AppColors.PRIMARY_SELECTED : AppColors.TEXT_SECONDARY)
      }
        .width(40)
        .height(40)
        .backgroundColor(AppColors.SURFACE)
        .opacity(this.currentPage < this.totalPages ? 1 : 0.45)
        .onClick(() => {
          this.goTo(this.currentPage + 1);
        })
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }
}
