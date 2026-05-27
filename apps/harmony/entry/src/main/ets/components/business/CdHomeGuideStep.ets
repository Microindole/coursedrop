import { AppColors, AppRadius, AppSize, AppSpacing, AppTypography } from '../../common/Theme';
import { CdButton } from '../common/CdButton';
import { CdPanel } from '../common/CdPanel';

@Component
export struct CdHomeGuideStep {
  onGoLibrary: () => void = () => {};
  onGoShare: () => void = () => {};

  build() {
    CdPanel({ hasShadow: true }) {
      Column({ space: AppSpacing.MD }) {
        Row({ space: AppSpacing.MD }) {
          Stack() {
            Image($r('app.media.cd_icon_library'))
              .width(AppSize.ICON_MD)
              .height(AppSize.ICON_MD)
              .fillColor(AppColors.PRIMARY)
          }
          .width(44)
          .height(44)
          .backgroundColor(AppColors.PRIMARY_SOFT)
          .borderRadius(AppRadius.MD)

          Column({ space: AppSpacing.XS }) {
            Text('开始第一步：整理本地库')
              .fontSize(AppTypography.BODY)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppColors.TEXT)
            
            Text('先将文件或文本导入本地缓存库，然后再生成公网提取链接，或与局域网设备直传。')
              .fontSize(AppTypography.BODY_SMALL)
              .fontColor(AppColors.TEXT_SECONDARY)
              .lineHeight(18)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')

        Row({ space: AppSpacing.MD }) {
          CdButton({
            label: '管理本地库',
            variant: 'tonal',
            onTap: () => {
              this.onGoLibrary();
            }
          })
          .layoutWeight(1)

          CdButton({
            label: '去分享发送',
            onTap: () => {
              this.onGoShare();
            }
          })
          .layoutWeight(1)
        }
        .width('100%')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }
}
