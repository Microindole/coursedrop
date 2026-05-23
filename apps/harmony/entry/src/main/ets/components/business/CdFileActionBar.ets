import { AppColors, AppRadius, AppSpacing, AppTypography } from '../../common/Theme';
import { CdButton } from '../actions/CdButton';

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

        Text('取消选择')
          .fontSize(AppTypography.BODY_SMALL)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppColors.PRIMARY_SELECTED)
          .onClick(() => {
            this.onClear();
          })
      }
      .width('100%')

      Row({ space: AppSpacing.SM }) {
        Column() {
          CdButton({
            label: '重新分享',
            variant: 'contained',
            interactive: this.selectedCount > 0,
            onTap: () => {
              this.onShare();
            }
          })
        }
        .layoutWeight(1)

        Column() {
          CdButton({
            label: '删除',
            variant: 'danger',
            interactive: this.selectedCount > 0,
            onTap: () => {
              this.onDelete();
            }
          })
        }
        .layoutWeight(1)
      }
      .width('100%')
    }
    .width('100%')
    .padding(AppSpacing.MD)
    .backgroundColor(AppColors.SURFACE)
    .borderRadius(AppRadius.LG)
  }
}
