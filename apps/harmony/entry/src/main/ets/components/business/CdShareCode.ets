import { AppColors, AppRadius, AppSpacing, AppTypography } from '../../common/Theme';
import { CdButton } from '../actions/CdButton';
import { CdExpireInfo, CdExpireTone } from './CdExpireInfo';
import { CdNetworkBadge, CdNetworkMode } from './CdNetworkBadge';

@Component
export struct CdShareCode {
  code: string = '';
  shareUrl: string = '';
  expireText: string = '';
  expireTone: CdExpireTone = 'active';
  networkMode: CdNetworkMode = 'relay';
  onCopy: () => void = () => {};
  onRefresh: () => void = () => {};
  onRevoke: () => void = () => {};

  build() {
    Column({ space: AppSpacing.LG }) {
      Row() {
        CdNetworkBadge({ mode: this.networkMode })
        Blank()
        CdExpireInfo({ label: this.expireText, tone: this.expireTone })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Column({ space: AppSpacing.SM }) {
        Text(this.code.length > 0 ? this.code : '------')
          .fontSize(34)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.TEXT)
          .textAlign(TextAlign.Center)
          .width('100%')

        Text(this.shareUrl.length > 0 ? this.shareUrl : '生成分享后显示公网链接')
          .fontSize(AppTypography.CAPTION)
          .fontColor(AppColors.TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
      }
      .width('100%')
      .padding(AppSpacing.LG)
      .backgroundColor(AppColors.PRIMARY_SOFT)
      .borderRadius(AppRadius.LG)

      Row({ space: AppSpacing.SM }) {
        Column() {
          CdButton({
            label: '复制',
            variant: 'tonal',
            onTap: () => {
              this.onCopy();
            }
          })
        }
        .layoutWeight(1)

        Column() {
          CdButton({
            label: '刷新',
            variant: 'tonal',
            onTap: () => {
              this.onRefresh();
            }
          })
        }
        .layoutWeight(1)

        Column() {
          CdButton({
            label: '撤回',
            variant: 'danger',
            onTap: () => {
              this.onRevoke();
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
