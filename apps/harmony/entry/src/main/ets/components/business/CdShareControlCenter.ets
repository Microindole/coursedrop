import { AppColors, AppRadius, AppSpacing, AppTypography } from '../../common/Theme';
import { ShareSession } from '../../models/ShareSession';
import { CdButton } from '../common/CdButton';
import { CdPanel } from '../common/CdPanel';

@Component
export struct CdShareControlCenter {
  @Link currentSession: ShareSession;
  @Prop loading: boolean = false;
  @Prop expireText: string = '';
  onRevoke: () => void = () => {};
  onCopy: () => void = () => {};
  onCreate: () => void = () => {};

  build() {
    CdPanel({ hasShadow: true }) {
      Column({ space: AppSpacing.MD }) {
        Row({ space: AppSpacing.SM }) {
          // 状态灯
          Stack() {
            Circle()
              .width(12)
              .height(12)
              .fill(this.currentSession.shareUrl.length > 0 ? AppColors.SUCCESS : AppColors.MUTED)
          }
          .width(20)
          .height(20)
          .align(Alignment.Center)

          Column({ space: 2 }) {
            Text(this.currentSession.shareUrl.length > 0 ? '公网临时分享已激活' : '公网临时分享未创建')
              .fontSize(AppTypography.BODY)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppColors.TEXT)

            Text(this.expireText)
              .fontSize(AppTypography.CAPTION)
              .fontColor(AppColors.TEXT_SECONDARY)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          if (this.currentSession.shareUrl.length > 0) {
            CdButton({
              label: '撤销分享',
              variant: 'danger',
              onTap: () => {
                this.onRevoke();
              }
            })
          }
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)

        // 提取码大字展示
        if (this.currentSession.code.length > 0) {
          Column({ space: AppSpacing.SM }) {
            Text('分享提取码')
              .fontSize(11)
              .fontWeight(FontWeight.Medium)
              .fontColor(AppColors.TEXT_SECONDARY)
            
            Text(this.currentSession.code)
              .fontSize(AppTypography.DISPLAY)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppColors.PRIMARY)
              .letterSpacing(3)
          }
          .width('100%')
          .padding({ top: AppSpacing.MD, bottom: AppSpacing.MD })
          .backgroundColor(AppColors.PRIMARY_SOFT)
          .borderRadius(AppRadius.MD)
          .alignItems(HorizontalAlign.Center)
        }

        if (this.currentSession.shareUrl.length > 0) {
          Row({ space: AppSpacing.SM }) {
            Text(this.currentSession.shareUrl)
              .fontSize(AppTypography.BODY_SMALL)
              .fontColor(AppColors.PRIMARY)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)
            
            Text('复制')
              .fontSize(AppTypography.BODY_SMALL)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppColors.PRIMARY_SELECTED)
              .onClick(() => {
                this.onCopy();
              })
          }
          .width('100%')
          .padding(AppSpacing.MD)
          .backgroundColor(AppColors.BACKGROUND)
          .borderRadius(AppRadius.MD)
        } else {
          Text('向草稿中添加文件或图片，然后点击“生成提取链接”，服务器将在安全期内托管您的临时文件。')
            .fontSize(AppTypography.BODY_SMALL)
            .fontColor(AppColors.TEXT_SECONDARY)
            .lineHeight(18)
        }

        if (this.currentSession.shareUrl.length === 0) {
          CdButton({
            label: this.loading ? '正在生成链接并上传...' : '生成公网提取链接',
            interactive: !this.loading && this.currentSession.items.length > 0,
            onTap: () => {
              this.onCreate();
            }
          })
          .width('100%')
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }
}
