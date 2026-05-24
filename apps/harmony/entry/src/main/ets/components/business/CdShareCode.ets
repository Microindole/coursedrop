import { AppColors, AppRadius, AppSpacing, AppTypography } from '../../common/Theme';
import { CdIconButton } from '../actions/CdIconButton';
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

      Row({ space: AppSpacing.LG }) {
        Column({ space: AppSpacing.XS }) {
          CdIconButton({
            icon: $r('app.media.cd_icon_copy'),
            variant: 'tonal',
            onTap: () => {
              this.onCopy();
            }
          })

          Text('复制')
            .fontSize(AppTypography.CAPTION)
            .fontColor(AppColors.TEXT_SECONDARY)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column({ space: AppSpacing.XS }) {
          CdIconButton({
            icon: $r('app.media.cd_icon_refresh'),
            variant: 'tonal',
            onTap: () => {
              this.onRefresh();
            }
          })

          Text('刷新')
            .fontSize(AppTypography.CAPTION)
            .fontColor(AppColors.TEXT_SECONDARY)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column({ space: AppSpacing.XS }) {
          CdIconButton({
            icon: $r('app.media.cd_icon_close'),
            variant: 'danger',
            onTap: () => {
              this.onRevoke();
            }
          })

          Text('撤回')
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
