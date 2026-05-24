import { AppColors, AppRadius, AppSpacing, AppTypography } from '../../common/Theme';
import { CdIconButton } from '../actions/CdIconButton';

@Component
export struct CdFileActionBar {
  selectedCount: number = 0;
  onShare: () => void = () => {};
  onDelete: () => void = () => {};
  onClear: () => void = () => {};

  build() {
    Column({ space: AppSpacing.MD }) {
      Row() {
        Text(`已选择 ${this.selectedCount} 项`)
          .fontSize(AppTypography.BODY_SMALL)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppColors.TEXT)
          .layoutWeight(1)

        CdIconButton({
          icon: $r('app.media.cd_icon_close'),
          variant: 'plain',
          onTap: () => {
            this.onClear();
          }
        })
      }
      .width('100%')

      Row({ space: AppSpacing.LG }) {
        Column({ space: AppSpacing.XS }) {
          CdIconButton({
            icon: $r('app.media.cd_icon_share'),
            variant: 'tonal',
            interactive: this.selectedCount > 0,
            onTap: () => {
              this.onShare();
            }
          })

          Text('分享')
            .fontSize(AppTypography.CAPTION)
            .fontColor(AppColors.TEXT_SECONDARY)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column({ space: AppSpacing.XS }) {
          CdIconButton({
            icon: $r('app.media.cd_icon_trash'),
            variant: 'danger',
            interactive: this.selectedCount > 0,
            onTap: () => {
              this.onDelete();
            }
          })

          Text('删除')
            .fontSize(AppTypography.CAPTION)
            .fontColor(AppColors.TEXT_SECONDARY)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
    }
    .width('100%')
    .padding(AppSpacing.MD)
    .backgroundColor(AppColors.SURFACE)
    .borderRadius(AppRadius.LG)
  }
}
