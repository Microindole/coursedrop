import router from '@ohos.router';
import { AppColors, AppRadius, AppSize, AppSpacing, AppTypography } from '../common/Theme';
import {
  CdBanner,
  CdButton,
  CdIconButton,
  CdPanel,
  CdProgressRow,
  CdScrollContainer,
  CdSectionHeader,
  CdTopBar
} from '../components/index';
import { TransferItemType } from '../models/CommonTypes';
import { TransferItem } from '../models/TransferItem';
import { TransferTask } from '../models/TransferTask';
import { ShareViewModel } from '../viewmodels/ShareViewModel';

@Component
export default struct SharePage {
  showBack: boolean = true;
  private viewModel: ShareViewModel = new ShareViewModel();
  @State revision: number = 0;

  private refreshView(): void {
    this.revision += 1;
  }

  private formatSize(sizeBytes: number): string {
    if (sizeBytes < 1024) {
      return `${sizeBytes} B`;
    }
    if (sizeBytes < 1024 * 1024) {
      return `${Math.round(sizeBytes / 1024)} KB`;
    }
    return `${Math.round(sizeBytes / 1024 / 1024)} MB`;
  }

  private typeText(type: TransferItemType): string {
    if (type === 'IMAGE') {
      return '图片';
    }
    if (type === 'TEXT') {
      return '文本';
    }
    if (type === 'LINK') {
      return '链接';
    }
    return '文件';
  }

  private typeIcon(type: TransferItemType): Resource {
    if (type === 'IMAGE') {
      return $r('app.media.cd_icon_image');
    }
    if (type === 'TEXT') {
      return $r('app.media.cd_icon_text');
    }
    if (type === 'LINK') {
      return $r('app.media.cd_icon_link');
    }
    return $r('app.media.cd_icon_file');
  }

  private taskText(task: TransferTask): string {
    if (task.status === 'RUNNING') {
      return '上传中';
    }
    if (task.status === 'COMPLETED') {
      return '已完成';
    }
    if (task.status === 'FAILED') {
      return '失败';
    }
    if (task.status === 'CANCELED') {
      return '已取消';
    }
    return '等待中';
  }

  @Builder
  ShareStatePanel() {
    CdPanel() {
      Column({ space: AppSpacing.MD }) {
        Row({ space: AppSpacing.SM }) {
          Image($r('app.media.cd_icon_relay'))
            .width(AppSize.ICON_MD)
            .height(AppSize.ICON_MD)
            .fillColor(AppColors.PRIMARY_SELECTED)

          Column({ space: AppSpacing.XS }) {
            Text('公网分享')
              .fontSize(AppTypography.BODY)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppColors.TEXT)

            Text(this.viewModel.getExpireText())
              .fontSize(AppTypography.CAPTION)
              .fontColor(AppColors.TEXT_SECONDARY)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          if (this.viewModel.currentSession.shareUrl.length > 0) {
            CdIconButton({
              icon: $r('app.media.cd_icon_close'),
              variant: 'danger',
              onTap: () => {
                this.viewModel.revokeShare();
                this.refreshView();
              }
            })
          }
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)

        if (this.viewModel.currentSession.shareUrl.length > 0) {
          Text(this.viewModel.currentSession.shareUrl)
            .fontSize(AppTypography.BODY_SMALL)
            .fontColor(AppColors.PRIMARY_SELECTED)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .padding(AppSpacing.SM)
            .width('100%')
            .backgroundColor(AppColors.PRIMARY_SOFT)
            .borderRadius(AppRadius.MD)
        } else {
          Text('还没有生成公网链接。添加内容后创建链接，服务器只在有效期内保存上传内容。')
            .fontSize(AppTypography.BODY_SMALL)
            .fontColor(AppColors.TEXT_SECONDARY)
            .lineHeight(20)
        }

        Row({ space: AppSpacing.SM }) {
          CdButton({
            label: this.viewModel.loading ? '创建中' : '创建链接',
            interactive: !this.viewModel.loading && this.viewModel.getItems().length > 0,
            onTap: () => {
              this.viewModel.refreshShareCode().then(() => {
                this.refreshView();
              });
            }
          })
          .layoutWeight(1)

          CdButton({
            label: '记录链接',
            variant: 'tonal',
            interactive: this.viewModel.currentSession.shareUrl.length > 0,
            onTap: () => {
              this.viewModel.copyShareLink();
              this.refreshView();
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

  @Builder
  DraftActionPanel() {
    CdPanel() {
      Column({ space: AppSpacing.MD }) {
        Text('添加到分享草稿')
          .fontSize(AppTypography.BODY)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.TEXT)

        Row({ space: AppSpacing.SM }) {
          CdButton({
            label: '文件',
            variant: 'tonal',
            onTap: () => {
              this.viewModel.addLocalItem('FILE').then(() => {
                this.refreshView();
              });
            }
          })
          .layoutWeight(1)

          CdButton({
            label: '图片',
            variant: 'tonal',
            onTap: () => {
              this.viewModel.addLocalItem('IMAGE').then(() => {
                this.refreshView();
              });
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

  @Builder
  DraftItemRow(item: TransferItem) {
    CdPanel() {
      Row({ space: AppSpacing.MD }) {
        Stack() {
          Image(this.typeIcon(item.type))
            .width(AppSize.ICON_MD)
            .height(AppSize.ICON_MD)
            .fillColor(AppColors.PRIMARY_SELECTED)
        }
        .width(44)
        .height(44)
        .backgroundColor(AppColors.PRIMARY_SOFT)
        .borderRadius(AppRadius.MD)

        Column({ space: AppSpacing.XS }) {
          Text(item.displayName)
            .fontSize(AppTypography.BODY)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppColors.TEXT)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(`${this.typeText(item.type)} · ${this.formatSize(item.sizeBytes)} · ${item.remoteItemId === undefined || item.remoteItemId.length === 0 ? '待上传' : '已入库'}`)
            .fontSize(AppTypography.CAPTION)
            .fontColor(AppColors.TEXT_SECONDARY)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
  }

  @Builder
  DraftList() {
    if (this.viewModel.getItems().length === 0) {
      CdPanel() {
        Column({ space: AppSpacing.SM }) {
          Image($r('app.media.cd_icon_share'))
            .width(36)
            .height(36)
            .fillColor(AppColors.TEXT_SECONDARY)

          Text('分享草稿为空')
            .fontSize(AppTypography.BODY)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppColors.TEXT)

          Text('先添加文件或图片，再创建 CourseDrop 公网链接。')
            .fontSize(AppTypography.BODY_SMALL)
            .fontColor(AppColors.TEXT_SECONDARY)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .padding({ top: AppSpacing.LG, bottom: AppSpacing.LG })
      }
    } else {
      ForEach(this.viewModel.getItems(), (item: TransferItem) => {
        this.DraftItemRow(item);
      }, (item: TransferItem) => item.id)
    }
  }

  @Builder
  TaskList() {
    if (this.viewModel.getTasks().length > 0) {
      CdSectionHeader({ title: '上传任务' })

      ForEach(this.viewModel.getTasks(), (task: TransferTask) => {
        CdProgressRow({
          title: this.viewModel.getItemName(task.itemId),
          description: `${this.taskText(task)} · ${task.networkMode}`,
          progress: task.progress
        })
      }, (task: TransferTask) => task.id)
    }
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      CdScrollContainer({ showScrollBar: true }) {
        if (this.revision < 0) {
          Blank()
        }

        CdTopBar({
          title: '分享',
          subtitle: 'CourseDrop 链接，不调用系统分享',
          leadingText: this.showBack ? '返回' : '',
          onLeadingTap: () => {
            router.back();
          }
        })

        CdBanner({
          title: this.viewModel.lastActionText.length > 0 ? this.viewModel.lastActionText : '分享内容由 CourseDrop 中转源托管',
          description: this.viewModel.errorMessage.length > 0 ? this.viewModel.errorMessage : '下载端扫码或登录后访问，链接过期后服务器清理文件。',
          tone: this.viewModel.errorMessage.length > 0 ? 'danger' : 'info'
        })

        this.ShareStatePanel();

        this.DraftActionPanel();

        CdSectionHeader({ title: '草稿内容' })

        this.DraftList();

        this.TaskList();
      }
    }
    .width('100%')
    .height('100%')
  }
}
