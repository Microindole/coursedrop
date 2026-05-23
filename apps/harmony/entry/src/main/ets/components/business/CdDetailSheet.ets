import { AppColors, AppRadius, AppSpacing, AppTypography } from '../../common/Theme';
import { CdExpireInfo, CdExpireTone } from './CdExpireInfo';
import { CdNetworkBadge, CdNetworkMode } from './CdNetworkBadge';

@Component
export struct CdDetailSheet {
  title: string = '';
  sizeText: string = '';
  typeText: string = '';
  createdText: string = '';
  expireText: string = '';
  expireTone: CdExpireTone = 'active';
  networkMode: CdNetworkMode = 'relay';
  encrypted: boolean = false;

  @Builder
  detailRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(AppTypography.BODY_SMALL)
        .fontColor(AppColors.TEXT_SECONDARY)
        .width(80)

      Text(value)
        .fontSize(AppTypography.BODY_SMALL)
        .fontColor(AppColors.TEXT)
        .layoutWeight(1)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
  }

  build() {
    Column({ space: AppSpacing.MD }) {
      Text(this.title)
        .fontSize(AppTypography.TITLE)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppColors.TEXT)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')

      Row({ space: AppSpacing.SM }) {
        CdNetworkBadge({ mode: this.networkMode })
        CdExpireInfo({ label: this.expireText, tone: this.expireTone })
        if (this.encrypted) {
          CdNetworkBadge({ mode: 'e2ee' })
        }
      }
      .width('100%')

      Column({ space: AppSpacing.SM }) {
        this.detailRow('大小', this.sizeText)
        this.detailRow('类型', this.typeText)
        this.detailRow('创建', this.createdText)
      }
      .width('100%')
    }
    .width('100%')
    .padding(AppSpacing.MD)
    .backgroundColor(AppColors.SURFACE)
    .borderRadius(AppRadius.LG)
  }
}
