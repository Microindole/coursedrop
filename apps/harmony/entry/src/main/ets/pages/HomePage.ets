import DevicePage from './DevicePage';
import LocalLibraryPage from './LocalLibraryPage';
import SettingsPage from './SettingsPage';
import SharePage from './SharePage';
import { AppColors, AppSpacing } from '../common/Theme';
import {
  CdBanner,
  CdBottomTabs,
  CdPageTitle,
  CdScrollContainer,
  CdSectionHeader,
  CdTransferStats,
  CdHomeGuideStep,
  CdHomeRecentShares
} from '../components/index';
import { ShareSession } from '../models/ShareSession';
import { HomeViewModel, HomeTransferStats } from '../viewmodels/HomeViewModel';

@Entry
@Component
struct HomePage {
  private viewModel: HomeViewModel = new HomeViewModel();
  @State currentIndex: number = 0;
  
  @State recentShares: ShareSession[] = [];
  @State transferStats: HomeTransferStats = { activeCount: 0, completedCount: 0, failedCount: 0, expiringCount: 0 };

  aboutToAppear() {
    this.syncHomeData();
  }

  private syncHomeData() {
    this.viewModel = new HomeViewModel();
    this.recentShares = this.viewModel.recentShares;
    this.transferStats = this.viewModel.getTransferStats();
  }

  @Builder
  HomeTab() {
    CdScrollContainer({ showScrollBar: true }) {
      CdPageTitle({
        title: this.viewModel.appName,
        subtitle: this.viewModel.subtitle
      })

      CdTransferStats({
        statsActiveCount: this.transferStats.activeCount,
        statsCompletedCount: this.transferStats.completedCount,
        statsFailedCount: this.transferStats.failedCount,
        statsExpiringCount: this.transferStats.expiringCount
      })

      CdBanner({
        title: '云端中转与局域网直传双引擎',
        description: '我们不读取并分析您的明文内容。生成提取码后可在网页中扫码秒级拉取。',
        tone: 'info',
        actionText: '同步状态',
        onAction: () => {
          this.syncHomeData();
        }
      })

      // 上手指南步骤卡片
      CdHomeGuideStep({
        onGoLibrary: () => {
          this.currentIndex = 2; // 本地库 Tab
        },
        onGoShare: () => {
          this.currentIndex = 1; // 分享 Tab
        }
      })

      CdSectionHeader({ title: '最近的提取链接' })

      // 最近分享提取列表
      CdHomeRecentShares({
        recentShares: this.recentShares,
        onRecentTap: () => {
          this.currentIndex = 1; // 分享 Tab
        }
      })
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
    .backgroundColor(AppColors.BACKGROUND)
  }
}
