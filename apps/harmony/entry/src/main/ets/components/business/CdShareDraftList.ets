import { AppColors, AppRadius, AppSize, AppSpacing, AppTypography } from '../../common/Theme';
import { TransferItem } from '../../models/TransferItem';
import { TransferItemType } from '../../models/CommonTypes';
import { CdPanel } from '../common/CdPanel';
import { CdIconButton } from '../common/CdIconButton';

export interface ShareDraftFileTypeColors {
  main: string;
  bg: string;
}

@Component
export struct CdShareDraftList {
  @Prop items: TransferItem[] = [];
  onRemoveItem: (itemId: string) => void = () => {};

  private formatSize(sizeBytes: number): string {
    if (sizeBytes < 1024) return `${sizeBytes} B`;
    if (sizeBytes < 1024 * 1024) return `${Math.round(sizeBytes / 1024)} KB`;
    return `${Math.round(sizeBytes / 1024 / 1024)} MB`;
  }

  private typeText(type: TransferItemType): string {
    if (type === 'IMAGE') return '图片';
    if (type === 'TEXT') return '文本';
    if (type === 'LINK') return '链接';
    return '文件';
  }

  private typeIcon(type: TransferItemType): Resource {
    if (type === 'IMAGE') return $r('app.media.cd_icon_image');
    if (type === 'TEXT') return $r('app.media.cd_icon_text');
    if (type === 'LINK') return $r('app.media.cd_icon_link');
    return $r('app.media.cd_icon_file');
  }

  private typeColors(type: TransferItemType): ShareDraftFileTypeColors {
    if (type === 'IMAGE') return { main: AppColors.TONE_IMAGE, bg: AppColors.TONE_IMAGE_BG };
    if (type === 'TEXT') return { main: AppColors.TONE_TEXT, bg: AppColors.TONE_TEXT_BG };
    if (type === 'LINK') return { main: AppColors.TONE_LINK, bg: AppColors.TONE_LINK_BG };
    return { main: AppColors.TONE_FILE, bg: AppColors.TONE_FILE_BG };
  }

  build() {
    if (this.items === undefined || this.items.length === 0) {
      CdPanel() {
        Column({ space: AppSpacing.MD }) {
          Image($r('app.media.cd_icon_share'))
            .width(44)
            .height(44)
            .fillColor(AppColors.MUTED)

          Text('分享草稿内容为空')
            .fontSize(AppTypography.BODY)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppColors.TEXT)

          Text('先从下方导入文件或图片，将其加入临时草稿中，再点击生成分享提取链接。')
            .fontSize(AppTypography.BODY_SMALL)
            .fontColor(AppColors.TEXT_SECONDARY)
            .textAlign(TextAlign.Center)
            .lineHeight(18)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .padding({ top: AppSpacing.XL, bottom: AppSpacing.XL })
      }
    } else {
      CdPanel() {
        Column() {
          ForEach(this.items, (item: TransferItem, index: number) => {
            Row({ space: AppSpacing.MD }) {
              Stack() {
                Image(this.typeIcon(item.type))
                  .width(AppSize.ICON_MD)
                  .height(AppSize.ICON_MD)
                  .fillColor(this.typeColors(item.type).main)
              }
              .width(40)
              .height(40)
              .backgroundColor(this.typeColors(item.type).bg)
              .borderRadius(AppRadius.MD)

              Column({ space: AppSpacing.XS }) {
                Text(item.displayName)
                  .fontSize(AppTypography.BODY_SMALL)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(AppColors.TEXT)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })

                Text(`${this.typeText(item.type)} · ${this.formatSize(item.sizeBytes)} · ${item.remoteItemId ? '已托管在云端' : '待上传中转'}`)
                  .fontSize(AppTypography.CAPTION)
                  .fontColor(AppColors.TEXT_SECONDARY)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)

              if (item.remoteItemId === undefined || item.remoteItemId.length === 0) {
                CdIconButton({
                  icon: $r('app.media.cd_icon_close'),
                  variant: 'plain',
                  onTap: () => {
                    this.onRemoveItem(item.id);
                  }
                })
              }
            }
            .width('100%')
            .padding({ top: AppSpacing.MD, bottom: AppSpacing.MD })

            if (index < this.items.length - 1) {
              Divider()
                .color(AppColors.BORDER)
                .strokeWidth(0.5)
            }
          }, (item: TransferItem) => item.id)
        }
        .width('100%')
      }
    }
  }
}
