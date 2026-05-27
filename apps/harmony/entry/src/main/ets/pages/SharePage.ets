import router from '@ohos.router';
import { AppColors, AppRadius, AppSpacing, AppTypography } from '../common/Theme';
import {
  CdBanner,
  CdButton,
  CdScrollContainer,
  CdSectionHeader,
  CdTopBar,
  CdPanel,
  CdShareControlCenter,
  CdShareDraftList,
  CdShareTaskList
} from '../components/index';
import { TransferTask } from '../models/TransferTask';
import { ShareSession } from '../models/ShareSession';
import { ShareViewModel } from '../viewmodels/ShareViewModel';

@Component
export default struct SharePage {
  showBack: boolean = true;
  private viewModel: ShareViewModel = new ShareViewModel();

  @State currentSession: ShareSession = this.viewModel.currentSession;
  @State tasks: TransferTask[] = [];
  @State lastActionText: string = '分享内容由 CourseDrop 中转源托管';
  @State errorMessage: string = '';
  @State loading: boolean = false;

  aboutToAppear() {
    this.syncState();
  }

  private syncState() {
    this.currentSession = this.viewModel.currentSession;
    this.tasks = this.viewModel.getTasks();
    this.lastActionText = this.viewModel.lastActionText.length > 0 ? this.viewModel.lastActionText : '分享内容由 CourseDrop 中转源托管';
    this.errorMessage = this.viewModel.errorMessage;
    this.loading = this.viewModel.loading;
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      CdScrollContainer({ showScrollBar: true }) {
        CdTopBar({
          title: '创建临时分享',
          subtitle: '支持在多端通过提取码和二维码下载文件',
          leadingText: this.showBack ? '返回' : '',
          trailingText: '刷新',
          onLeadingTap: () => {
            router.back();
          },
          onTrailingTap: () => {
            this.syncState();
          }
        })

        CdBanner({
          title: this.lastActionText,
          description: this.errorMessage.length > 0 ? this.errorMessage : '上传中转的文件按安全时效保存，安全期满后由自动机制审计清理并销毁。',
          tone: this.errorMessage.length > 0 ? 'danger' : 'info'
        })

        // 提取中心控制卡片
        CdShareControlCenter({
          currentSession: $currentSession,
          loading: this.loading,
          expireText: this.viewModel.getExpireText(),
          qrImageUrl: this.viewModel.getShareQrImageUrl(),
          onRevoke: () => {
            this.loading = true;
            this.viewModel.revokeShare().then(() => {
              this.syncState();
            });
          },
          onExtend: () => {
            this.loading = true;
            this.viewModel.extendShare().then(() => {
              this.syncState();
            });
          },
          onCopy: () => {
            this.viewModel.copyShareLink().then(() => {
              this.syncState();
            });
          },
          onCreate: () => {
            this.loading = true;
            this.viewModel.refreshShareCode().then(() => {
              this.syncState();
            });
          }
        })

        // 添加草稿操作区域
        CdPanel() {
          Column({ space: AppSpacing.MD }) {
            Row() {
              Text('添加内容至分享草稿')
                .fontSize(AppTypography.BODY)
                .fontWeight(FontWeight.Bold)
                .fontColor(AppColors.TEXT)
                .layoutWeight(1)

              if (this.currentSession.items.length > 0 && this.currentSession.shareUrl.length === 0) {
                Text('清空')
                  .fontSize(AppTypography.BODY_SMALL)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(AppColors.DANGER)
                  .onClick(() => {
                    this.viewModel.clearDraft();
                    this.syncState();
                  })
              }
            }
            .width('100%')

            Row({ space: AppSpacing.MD }) {
              CdButton({
                label: '添加本地文件',
                variant: 'tonal',
                onTap: () => {
                  this.viewModel.addLocalItem('FILE').then(() => {
                    this.syncState();
                  });
                }
              })
              .layoutWeight(1)

              CdButton({
                label: '添加图片/照片',
                variant: 'tonal',
                onTap: () => {
                  this.viewModel.addLocalItem('IMAGE').then(() => {
                    this.syncState();
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

        CdSectionHeader({ title: '分享提取内容' })

        // 分享草稿列表
        CdShareDraftList({
          items: this.currentSession.items,
          onRemoveItem: (itemId: string) => {
            this.viewModel.removeDraftItem(itemId);
            this.syncState();
          }
        })

        // 上传任务进度列表
        CdShareTaskList({
          tasks: this.tasks,
          onGetItemName: (itemId) => {
            return this.viewModel.getItemName(itemId);
          },
          onRetry: (itemId: string) => {
            this.loading = true;
            this.viewModel.retryUpload(itemId).then(() => {
              this.syncState();
            });
          }
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
