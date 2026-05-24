import { AppColors, AppRadius, AppSize, AppSpacing, AppTypography } from '../../common/Theme';

@Component
export struct CdCheckboxRow {
  title: string = '';
  description: string = '';
  @Link checked: boolean;
  onChange: (checked: boolean) => void = (_checked: boolean) => {};

  build() {
    Row() {
      Row() {
        if (this.checked) {
          Image($r('app.media.cd_icon_done'))
            .width(16)
            .height(16)
            .fillColor(Color.White)
        }
      }
      .width(24)
      .height(24)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.checked ? AppColors.PRIMARY : AppColors.SURFACE)
      .borderRadius(AppRadius.SM)
      .border({ width: 1, color: this.checked ? AppColors.PRIMARY : AppColors.BORDER_STRONG })
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
    }
    .width('100%')
    .height(AppSize.LIST_ROW_HEIGHT)
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.checked = !this.checked;
      this.onChange(this.checked);
    })
  }
}
