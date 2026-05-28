import { AppColors, AppRadius, AppSize, AppSpacing, AppTypography } from '../../common/Theme';
import { LocalFileEntry } from '../../models/LocalFileEntry';
import { CdPanel } from '../common/CdPanel';

export interface FileToneStyle {
  main: string;
  bg: string;
  icon: Resource;
}

@Component
export struct CdLocalFileCard {
  file: LocalFileEntry | null = null;
  @Prop isEditMode: boolean = false;
  @Link selectedIds: string[];
  @Link selectedFile: LocalFileEntry | null;

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

  build() {
    if (this.file) {
      CdPanel({
        clickable: true,
        onTap: () => {
          const f = this.file;
          if (f) {
            if (this.isEditMode) {
              if (this.selectedIds.includes(f.id)) {
                this.selectedIds = this.selectedIds.filter(id => id !== f.id);
              } else {
                this.selectedIds.push(f.id);
              }
            } else {
              animateTo({ duration: 250, curve: Curve.FastOutSlowIn }, () => {
                this.selectedFile = f;
              });
            }
          }
        }
      }) {
        Row({ space: AppSpacing.MD }) {
          if (this.isEditMode) {
            Stack() {
              if (this.selectedIds.includes(this.file.id)) {
                Circle()
                  .width(22)
                  .height(22)
                  .fill(AppColors.PRIMARY)
                Image($r('app.media.cd_icon_done'))
                  .width(12)
                  .height(12)
                  .fillColor(AppColors.SURFACE)
              } else {
                Circle()
                  .width(22)
                  .height(22)
                  .fill(Color.Transparent)
                  .stroke(AppColors.BORDER_STRONG)
                  .strokeWidth(1.5)
              }
            }
            .width(24)
            .height(24)
            .animation({ duration: 150 })
          }

          Stack() {
            Image(this.resolveTone(this.file.type).icon)
              .width(AppSize.ICON_MD)
              .height(AppSize.ICON_MD)
              .fillColor(this.resolveTone(this.file.type).main)
          }
          .width(44)
          .height(44)
          .backgroundColor(this.resolveTone(this.file.type).bg)
          .borderRadius(AppRadius.MD)
          .border({ width: 0.7, color: this.resolveTone(this.file.type).main })

          Column({ space: AppSpacing.XS }) {
            Row({ space: AppSpacing.SM }) {
              Text(this.file.displayName)
                .fontSize(AppTypography.BODY_SMALL)
                .fontWeight(FontWeight.Bold)
                .fontColor(AppColors.TEXT)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .layoutWeight(1)

              Text(this.file.encrypted ? 'E2EE' : 'LAN')
                .fontSize(9)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.file.encrypted ? AppColors.SUCCESS : AppColors.PRIMARY)
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .backgroundColor(this.file.encrypted ? AppColors.SUCCESS_SOFT : AppColors.PRIMARY_SOFT)
                .borderRadius(AppRadius.SM)
            }
            .width('100%')

            Text(`${this.typeText(this.file.type)} · ${this.formatSize(this.file.sizeBytes)} · ${this.file.encrypted ? '已端到端加密' : '直传免加密'}`)
              .fontSize(AppTypography.CAPTION)
              .fontColor(AppColors.TEXT_SECONDARY)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          if (!this.isEditMode) {
            Image($r('app.media.cd_icon_done'))
              .width(14)
              .height(14)
              .fillColor(AppColors.MUTED)
              .opacity(0.6)
              .rotate({ angle: 270 })
          }
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
      }
    }
  }
}
