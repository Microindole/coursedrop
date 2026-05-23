import { promptAction } from '@kit.ArkUI';
import { AppSpacing } from '../common/Theme';
import {
  CdActionTile,
  CdButton,
  CdFileItem,
  CdInfoRow,
  CdPageTitle,
  CdPanel,
  CdScrollContainer,
  CdSectionHeader,
  CdStatusPill,
  CdTextField
} from '../components/index';
import { HomeViewModel } from '../viewmodels/HomeViewModel';

@Entry
@Component
struct HomePage {
  private viewModel: HomeViewModel = new HomeViewModel();
  @State roomName: string = '';
  @State roomCode: string = '';

  private showTodoToast(action: string): void {
    promptAction.showToast({
      message: `${action}接口下一步接入`,
      duration: 1800
    });
  }

  build() {
    CdScrollContainer() {
      Column({ space: AppSpacing.MD }) {
        Column({ space: AppSpacing.MD }) {
          CdPageTitle({
            title: this.viewModel.appName,
            subtitle: this.viewModel.subtitle
          })

          Row({ space: AppSpacing.SM }) {
            CdStatusPill({ label: '局域网优先', tone: 'info' })
            CdStatusPill({ label: '临时中转', tone: 'success' })
          }
          .width('100%')
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .padding({ top: AppSpacing.PAGE_TOP, bottom: AppSpacing.SM })

        Grid() {
          GridItem() {
            CdActionTile({
              title: '本地发送',
              subtitle: '同网直传',
              symbol: $r('sys.symbol.wifi'),
              onTap: () => {
                this.showTodoToast('局域网传输');
              }
            })
          }

          GridItem() {
            CdActionTile({
              title: '公网分享',
              subtitle: '二维码时效',
              symbol: $r('sys.symbol.qrcode'),
              onTap: () => {
                this.showTodoToast('公网分享');
              }
            })
          }

          GridItem() {
            CdActionTile({
              title: '分享管理',
              subtitle: '记录与状态',
              symbol: $r('sys.symbol.folder_fill'),
              onTap: () => {
                this.showTodoToast('分享管理');
              }
            })
          }

          GridItem() {
            CdActionTile({
              title: '加密传输',
              subtitle: '端到端',
              symbol: $r('sys.symbol.lock_fill'),
              onTap: () => {
                this.showTodoToast('端到端加密');
              }
            })
          }
        }
        .columnsTemplate('1fr 1fr')
        .rowsTemplate('1fr 1fr')
        .columnsGap(AppSpacing.SM)
        .rowsGap(AppSpacing.SM)
        .width('100%')
        .height(200)

        CdSectionHeader({ title: '临时投递' })

        CdPanel() {
          Column({ space: AppSpacing.LG }) {
            CdTextField({
              label: '分享名称',
              placeholder: '例如：移动应用作业资料',
              value: $roomName
            })

            CdButton({
              label: '创建临时分享',
              variant: 'contained',
              onTap: () => {
                this.showTodoToast('创建分享');
              }
            })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }

        CdPanel() {
          Column({ space: AppSpacing.LG }) {
            CdTextField({
              label: '分享码',
              placeholder: '输入 6 位分享码',
              value: $roomCode
            })

            CdButton({
              label: '加入分享',
              variant: 'tonal',
              onTap: () => {
                this.roomCode = this.roomCode.toUpperCase();
                this.showTodoToast('加入分享');
              }
            })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }

        CdSectionHeader({ title: '最近内容', actionText: '全部' })

        CdFileItem({
          name: 'UI 教程参考资料.zip',
          meta: '公网临时副本 · 23 小时后过期',
          tone: 'file'
        })

        CdFileItem({
          name: '课堂截图.png',
          meta: '局域网可用 · 端到端加密',
          tone: 'image'
        })

        CdPanel() {
          Column({ space: AppSpacing.SM }) {
            CdInfoRow({
              title: '当前主线',
              value: '先跑通公网临时中转，再接局域网直传和分享管理器',
              symbol: $r('sys.symbol.paperplane_fill')
            })
          }
          .width('100%')
        }

        Blank()
      }
      .width('100%')
    }
  }
}
