import { AppColors, AppRadius, AppSize, AppSpacing, AppTypography, AppShadows } from '../../common/Theme';
import { LocalFileEntry } from '../../models/LocalFileEntry';
import { CdButton } from '../common/CdButton';
import { FileToneStyle } from './CdLocalFileCard';

@Component
export struct CdLocalFileDetailDrawer {
  @Link selectedFile: LocalFileEntry | null;
  onShare: (id: string) => void = () => {};
  onDelete: (id: string) => void = () => {};

  private formatSize(sizeBytes: number): string {
    if (sizeBytes < 1024) return `${sizeBytes} B`;
    if (sizeBytes < 1024 * 1024) return `${Math.round(sizeBytes / 1024)} KB`;
    return `${Math.round(sizeBytes / 1024 / 1024)} MB`;
  }

  private typeText(type: string): string {
    if (type === 'IMAGE') return '图片';
    if (type === 'TEXT') return '文本';
    if (type === 'LINK') return '链接';
    return '文件';
  }

  private resolveTone(type: string): FileToneStyle {
    if (type === 'IMAGE') {
      return { main: AppColors.TONE_IMAGE, bg: AppColors.TONE_IMAGE_BG, icon: $r('app.media.cd_icon_image') };
    }
    if (type === 'TEXT') {
      return { main: AppColors.TONE_TEXT, bg: AppColors.TONE_TEXT_BG, icon: $r('app.media.cd_icon_text') };
    }
    if (type === 'LINK') {
      return { main: AppColors.TONE_LINK, bg: AppColors.TONE_LINK_BG, icon: $r('app.media.cd_icon_link') };
    }
    return { main: AppColors.TONE_FILE, bg: AppColors.TONE_FILE_BG, icon: $r('app.media.cd_icon_file') };
  }

  @Builder
  DetailRowItem(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(AppTypography.BODY_SMALL)
        .fontColor(AppColors.TEXT_SECONDARY)
        .width(80)
      
      Text(value)
        .fontSize(AppTypography.BODY_SMALL)
        .fontWeight(FontWeight.Medium)
        .fontColor(AppColors.TEXT)
        .layoutWeight(1)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      if (this.selectedFile !== null) {
        // 虚化遮罩层
        Row()
          .width('100%')
          .height('100%')
          .backgroundColor('#55000000')
          .onClick(() => {
            animateTo({ duration: 250, curve: Curve.FastOutSlowIn }, () => {
              this.selectedFile = null;
            });
          })
          .transition({ opacity: 0 })

        // 底部抽屉面板
        Column({ space: AppSpacing.LG }) {
          // 顶部手柄
          Row() {
            Rect()
              .width(36)
              .height(4)
              .radius(2)
              .fill(AppColors.BORDER_STRONG)
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .padding({ top: AppSpacing.SM, bottom: AppSpacing.SM })

          // 文件标题
          Row({ space: AppSpacing.MD }) {
            Stack() {
              Image(this.resolveTone(this.selectedFile.type).icon)
                .width(AppSize.ICON_MD)
                .height(AppSize.ICON_MD)
                .fillColor(this.resolveTone(this.selectedFile.type).main)
            }
            .width(50)
            .height(50)
            .backgroundColor(this.resolveTone(this.selectedFile.type).bg)
            .borderRadius(AppRadius.MD)

            Column({ space: AppSpacing.XS }) {
              Text(this.selectedFile.displayName)
                .fontSize(AppTypography.SUBTITLE)
                .fontWeight(FontWeight.Bold)
                .fontColor(AppColors.TEXT)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })

              Text(`${this.typeText(this.selectedFile.type)} · ${this.formatSize(this.selectedFile.sizeBytes)}`)
                .fontSize(AppTypography.BODY_SMALL)
                .fontColor(AppColors.TEXT_SECONDARY)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')

          // 详细数据
          Column({ space: AppSpacing.MD }) {
            this.DetailRowItem('存储位置', this.selectedFile.localUri)
            this.DetailRowItem('安全保护', this.selectedFile.encrypted ? '已使用端到端加密保护' : '仅在传输通道加密')
            this.DetailRowItem('分享历史', `累计在当前设备被调用分享过 ${this.selectedFile.shareCount} 次`)
            if (this.selectedFile.lastSharedAt && this.selectedFile.lastSharedAt.length > 0) {
              this.DetailRowItem('最近分享', this.selectedFile.lastSharedAt)
            }
          }
          .padding(AppSpacing.MD)
          .backgroundColor(AppColors.BACKGROUND)
          .borderRadius(AppRadius.MD)
          .width('100%')

          // 操作按钮
          Row({ space: AppSpacing.MD }) {
            CdButton({
              label: '加入当前分享草稿',
              onTap: () => {
                if (this.selectedFile) {
                  this.onShare(this.selectedFile.id);
                  this.selectedFile = null;
                }
              }
            })
            .layoutWeight(2)

            CdButton({
              label: '删除',
              variant: 'danger',
              onTap: () => {
                if (this.selectedFile) {
                  this.onDelete(this.selectedFile.id);
                  this.selectedFile = null;
                }
              }
            })
            .layoutWeight(1)
          }
          .width('100%')
        }
        .width('100%')
        .padding({ left: AppSpacing.LG, right: AppSpacing.LG, bottom: AppSpacing.XL + 10 })
        .backgroundColor(AppColors.SURFACE)
        .borderRadius({ topLeft: AppRadius.XL, topRight: AppRadius.XL })
        .shadow(AppShadows.FLOATING)
        .transition({ translate: { y: '100%' } })
      }
    }
    .width('100%')
    .height('100%')
  }
}
