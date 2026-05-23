import { AppColors, AppRadius, AppSpacing, AppTypography } from '../../common/Theme';

@Component
export struct CdProgressRow {
  title: string = '';
  description: string = '';
  progress: number = 0;

  private progressText(): string {
    if (this.progress < 0) {
      return '0%';
    }
    if (this.progress > 100) {
      return '100%';
    }
    return `${Math.round(this.progress)}%`;
  }

  private progressWidth(): string {
    if (this.progress < 0) {
      return '0%';
    }
    if (this.progress > 100) {
      return '100%';
    }
    return `${this.progress}%`;
  }

  build() {
    Column({ space: AppSpacing.SM }) {
      Row() {
        Text(this.title)
          .fontSize(AppTypography.BODY_SMALL)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppColors.TEXT)
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(this.progressText())
          .fontSize(AppTypography.CAPTION)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.PRIMARY_SELECTED)
      }

      Row() {
        Row()
          .height(6)
          .width(this.progressWidth())
          .backgroundColor(AppColors.PRIMARY)
          .borderRadius(AppRadius.SM)
      }
      .width('100%')
      .height(6)
      .backgroundColor(AppColors.SURFACE_MUTED)
      .borderRadius(AppRadius.SM)

      if (this.description.length > 0) {
        Text(this.description)
          .fontSize(AppTypography.CAPTION)
          .fontColor(AppColors.TEXT_SECONDARY)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
    }
    .width('100%')
    .padding(AppSpacing.MD)
    .backgroundColor(AppColors.SURFACE)
    .borderRadius(AppRadius.LG)
  }
}
