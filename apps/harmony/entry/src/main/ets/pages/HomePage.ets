import DevicePage from './DevicePage';
import LocalLibraryPage from './LocalLibraryPage';
import SettingsPage from './SettingsPage';
import SharePage from './SharePage';
import { AppSpacing } from '../common/Theme';
import {
  CdBanner,
  CdBottomTabs,
  CdDeviceList,
  CdPageTitle,
  CdScrollContainer,
  CdSectionHeader,
  CdShareCode,
  CdStatusPill,
  CdTransferStats
} from '../components/index';
import { ShareSession } from '../models/ShareSession';
import { HomeViewModel } from '../viewmodels/HomeViewModel';

@Entry
@Component
struct HomePage {
  private viewModel: HomeViewModel = new HomeViewModel();
  @State currentIndex: number = 0;

  private networkMode(mode: string): 'lan' | 'relay' | 'e2ee' | 'offline' {
    if (mode === 'LAN') {
      return 'lan';
    }
    if (mode === 'E2EE') {
      return 'e2ee';
    }
    if (mode === 'OFFLINE') {
      return 'offline';
    }
    return 'relay';
  }

  private expireTone(status: string): 'active' | 'soon' | 'expired' {
    if (status === 'EXPIRING_SOON') {
      return 'soon';
    }
    if (status === 'EXPIRED') {
      return 'expired';
    }
    return 'active';
  }

  private expireText(session: ShareSession): string {
    if (session.expireStatus === 'EXPIRING_SOON') {
      return '即将过期';
    }
    if (session.expireStatus === 'EXPIRED') {
      return '已过期';
    }
    return '有效';
  }

  @Builder
  HomeTab() {
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
        .padding({ bottom: AppSpacing.SM })

        CdTransferStats({
          statsActiveCount: this.viewModel.getTransferStats().activeCount,
          statsCompletedCount: this.viewModel.getTransferStats().completedCount,
          statsFailedCount: this.viewModel.getTransferStats().failedCount,
          statsExpiringCount: this.viewModel.getTransferStats().expiringCount
        })

        CdBanner({
          title: '本地库尚未建立索引',
          description: '下一步接应用目录、SQLite 索引、本地文件选择和真实传输。',
          tone: 'info'
        })

        CdSectionHeader({ title: '最近分享' })

        ForEach(this.viewModel.recentShares, (share: ShareSession) => {
          CdShareCode({
            code: share.code,
            shareUrl: share.shareUrl,
            expireText: this.expireText(share),
            expireTone: this.expireTone(share.expireStatus),
            networkMode: this.networkMode(share.networkMode)
          })
        }, (share: ShareSession) => share.id)

        CdSectionHeader({ title: '附近设备' })

        CdDeviceList({ devices: this.viewModel.nearbyDevices })

        Blank()
      }
      .width('100%')
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
