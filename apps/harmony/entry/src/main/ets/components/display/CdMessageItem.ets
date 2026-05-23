import { AppColors, AppRadius, AppSpacing, AppTypography } from '../../common/Theme';

@Component
export struct CdMessageItem {
  title: string = '';
  description: string = '';
  timeText: string = '';
  unread: boolean = false;
  onTap: () => void = () => {};

  build() {
    Row() {
      Column({ space: AppSpacing.XS }) {
        Row() {
          Text(this.title)
            .fontSize(AppTypography.BODY)
            .fontWeight(this.unread ? FontWeight.Bold : FontWeight.Medium)
            .fontColor(AppColors.TEXT)
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          if (this.timeText.length > 0) {
            Text(this.timeText)
              .fontSize(AppTypography.CAPTION)
              .fontColor(AppColors.TEXT_SECONDARY)
          }
        }
        .width('100%')

        if (this.description.length > 0) {
          Text(this.description)
            .fontSize(AppTypography.BODY_SMALL)
            .fontColor(AppColors.TEXT_SECONDARY)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
      .layoutWeight(1)

      if (this.unread) {
        Text('')
          .width(8)
          .height(8)
          .backgroundColor(AppColors.PRIMARY)
          .borderRadius(AppRadius.SM)
          .margin({ left: AppSpacing.SM })
      }
    }
    .width('100%')
    .padding(AppSpacing.MD)
    .backgroundColor(AppColors.SURFACE)
    .borderRadius(AppRadius.LG)
    .onClick(() => {
      this.onTap();
    })
  }
}
