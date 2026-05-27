import DevicePage from './DevicePage';
import LocalLibraryPage from './LocalLibraryPage';
import SettingsPage from './SettingsPage';
import SharePage from './SharePage';
import { AppColors, AppRadius, AppSize, AppSpacing, AppTypography } from '../common/Theme';
import {
  CdBanner,
  CdBottomTabs,
  CdButton,
  CdPageTitle,
  CdPanel,
  CdScrollContainer,
  CdSectionHeader,
  CdTransferStats
} from '../components/index';
import { ShareSession } from '../models/ShareSession';
import { HomeViewModel } from '../viewmodels/HomeViewModel';

@Entry
@Component
struct HomePage {
  private viewModel: HomeViewModel = new HomeViewModel();
  @State currentIndex: number = 0;
  @State revision: number = 0;

  private refreshHome(): void {
    this.viewModel = new HomeViewModel();
    this.revision += 1;
  }

  private sessionText(session: ShareSession): string {
    if (session.status === 'DRAFT') {
      return '草稿';
    }
    if (session.status === 'REVOKED') {
      return '已撤回';
    }
    if (session.status === 'EXPIRED') {
      return '已过期';
    }
    return session.expiresAt.length > 0 ? `有效至 ${session.expiresAt}` : '有效';
  }

  @Builder
  StepPanel() {
    CdPanel() {
      Column({ space: AppSpacing.MD }) {
        Row({ space: AppSpacing.MD }) {
          Stack() {
            Image($r('app.media.cd_icon_library'))
              .width(AppSize.ICON_MD)
              .height(AppSize.ICON_MD)
              .fillColor(AppColors.PRIMARY_SELECTED)
          }
          .width(44)
          .height(44)
          .backgroundColor(AppColors.PRIMARY_SOFT)
          .borderRadius(AppRadius.MD)

          Column({ space: AppSpacing.XS }) {
            Text('先整理本地库')
              .fontSize(AppTypography.BODY)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppColors.TEXT)
            Text('导入或生成测试文件，CourseDrop 只管理自己的索引内容。')
              .fontSize(AppTypography.BODY_SMALL)
              .fontColor(AppColors.TEXT_SECONDARY)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')

        Row({ space: AppSpacing.SM }) {
          CdButton({
            label: '本地库',
            variant: 'tonal',
            onTap: () => {
              this.currentIndex = 2;
            }
          })
          .layoutWeight(1)

          CdButton({
            label: '去分享',
            onTap: () => {
              this.currentIndex = 1;
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
  ShareSummary() {
    if (this.viewModel.recentShares.length === 0) {
      CdPanel() {
        Text('暂无最近分享')
          .fontSize(AppTypography.BODY_SMALL)
          .fontColor(AppColors.TEXT_SECONDARY)
      }
    } else {
      ForEach(this.viewModel.recentShares, (share: ShareSession) => {
        CdPanel() {
          Row({ space: AppSpacing.MD }) {
            Image($r('app.media.cd_icon_share'))
              .width(AppSize.ICON_MD)
              .height(AppSize.ICON_MD)
              .fillColor(AppColors.PRIMARY_SELECTED)

            Column({ space: AppSpacing.XS }) {
              Text(share.title)
                .fontSize(AppTypography.BODY)
                .fontWeight(FontWeight.Medium)
                .fontColor(AppColors.TEXT)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })

              Text(`${share.itemCount} 项 · ${this.sessionText(share)}`)
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
      }, (share: ShareSession) => share.id)
    }
  }

  @Builder
  HomeTab() {
    CdScrollContainer({ showScrollBar: true }) {
      if (this.revision < 0) {
        Blank()
      }

      CdPageTitle({
        title: this.viewModel.appName,
        subtitle: this.viewModel.subtitle
      })

      CdTransferStats({
        statsActiveCount: this.viewModel.getTransferStats().activeCount,
        statsCompletedCount: this.viewModel.getTransferStats().completedCount,
        statsFailedCount: this.viewModel.getTransferStats().failedCount,
        statsExpiringCount: this.viewModel.getTransferStats().expiringCount
      })

      CdBanner({
        title: '本地优先，公网中转按时效保存',
        description: '先把文件放入本地库，再创建需要登录访问的 CourseDrop 分享链接。',
        tone: 'info',
        actionText: '刷新',
        onAction: () => {
          this.refreshHome();
        }
      })

      this.StepPanel();

      CdSectionHeader({ title: '最近分享' })

      this.ShareSummary();
    }
  }

  @Builder
  ShareTab() {
    SharePage({ showBack: false })
  }

  @Builder
  LibraryTab() {
    LocalLibraryPage({ showBack: false })
  }

  @Builder
  DeviceTab() {
    DevicePage({ showBack: false })
  }

  @Builder
  SettingsTab() {
    SettingsPage({ showBack: false })
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      CdBottomTabs({
        currentIndex: $currentIndex,
        homeContent: () => {
          this.HomeTab();
        },
        shareContent: () => {
          this.ShareTab();
        },
        libraryContent: () => {
          this.LibraryTab();
        },
        deviceContent: () => {
          this.DeviceTab();
        },
        settingsContent: () => {
          this.SettingsTab();
        }
      })
    }
    .width('100%')
    .height('100%')
  }
}
