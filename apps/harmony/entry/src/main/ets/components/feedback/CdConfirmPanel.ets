import { AppColors, AppRadius, AppSpacing, AppTypography } from '../../common/Theme';
import { CdButton } from '../actions/CdButton';

@Component
export struct CdConfirmPanel {
  title: string = '';
  description: string = '';
  confirmText: string = '确认';
  cancelText: string = '取消';
  danger: boolean = false;
  onConfirm: () => void = () => {};
  onCancel: () => void = () => {};

  build() {
    Column({ space: AppSpacing.LG }) {
      Column({ space: AppSpacing.SM }) {
        Text(this.title)
          .fontSize(AppTypography.TITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.TEXT)
          .width('100%')

        if (this.description.length > 0) {
          Text(this.description)
            .fontSize(AppTypography.BODY_SMALL)
            .fontColor(AppColors.TEXT_SECONDARY)
            .lineHeight(20)
            .width('100%')
        }
      }
      .alignItems(HorizontalAlign.Start)

      Row({ space: AppSpacing.SM }) {
        Column() {
          CdButton({
            label: this.cancelText,
            variant: 'tonal',
            onTap: () => {
              this.onCancel();
            }
          })
        }
        .layoutWeight(1)

        Column() {
          CdButton({
            label: this.confirmText,
            variant: this.danger ? 'danger' : 'contained',
            onTap: () => {
              this.onConfirm();
            }
          })
        }
        .layoutWeight(1)
      }
      .width('100%')
    }
    .width('100%')
    .padding(AppSpacing.LG)
    .backgroundColor(AppColors.SURFACE)
    .borderRadius(AppRadius.LG)
  }
}
