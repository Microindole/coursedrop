import { AppColors, AppTypography } from '../../common/Theme';

export type CdTextRole = 'title' | 'subtitle' | 'body' | 'caption' | 'muted';

@Component
export struct CdText {
  text: string = '';
  role: CdTextRole = 'body';
  maxLines: number = 0;

  private resolveFontSize(): number {
    if (this.role === 'title') {
      return AppTypography.TITLE;
    }
    if (this.role === 'subtitle') {
      return AppTypography.SUBTITLE;
    }
    if (this.role === 'caption') {
      return AppTypography.CAPTION;
    }
    if (this.role === 'muted') {
      return AppTypography.BODY_SMALL;
    }
    return AppTypography.BODY;
  }

  private resolveFontColor(): string {
    if (this.role === 'caption' || this.role === 'muted') {
      return AppColors.TEXT_SECONDARY;
    }
    return AppColors.TEXT;
  }

  private resolveFontWeight(): FontWeight {
    if (this.role === 'title') {
      return FontWeight.Bold;
    }
    if (this.role === 'subtitle') {
      return FontWeight.Medium;
    }
    return FontWeight.Regular;
  }

  build() {
    if (this.maxLines > 0) {
      Text(this.text)
        .fontSize(this.resolveFontSize())
        .fontWeight(this.resolveFontWeight())
        .fontColor(this.resolveFontColor())
        .maxLines(this.maxLines)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    } else {
      Text(this.text)
        .fontSize(this.resolveFontSize())
        .fontWeight(this.resolveFontWeight())
        .fontColor(this.resolveFontColor())
    }
  }
}
