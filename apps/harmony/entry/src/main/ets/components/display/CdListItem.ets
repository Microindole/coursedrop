import { AppColors, AppRadius, AppSize, AppSpacing, AppTypography } from '../../common/Theme';

@Component
export struct CdListItem {
  title: string = '';
  description: string = '';
  mark: string = '';
  showChevron: boolean = true;
  onTap: () => void = () => {};

  build() {
    ListItem() {
      Row() {
        Text(this.mark)
          .fontSize(AppTypography.CAPTION)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.PRIMARY_SELECTED)
          .width(AppSize.ICON_MD)
          .height(AppSize.ICON_MD)
          .textAlign(TextAlign.Center)
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
          Text('>')
            .fontSize(AppTypography.BODY)
            .fontColor(AppColors.TEXT_SECONDARY)
        }
      }
      .width('100%')
      .height(AppSize.LIST_ROW_HEIGHT)
      .padding({ left: AppSpacing.MD, right: AppSpacing.MD })
      .backgroundColor(AppColors.SURFACE)
      .borderRadius(AppRadius.LG)
    }
    .onClick(() => {
      this.onTap();
    })
  }
}
