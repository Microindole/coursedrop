import {
    CdBanner,
    CdDeviceList,
    CdScrollContainer,
    CdSectionHeader,
    CdTopBar
} from '../components/index';
import { DeviceViewModel } from '../viewmodels/DeviceViewModel';

@Component
export default struct DevicePage {
    private viewModel: DeviceViewModel = new DeviceViewModel();
    showBack: boolean = false;
    @State revision: number = 0;

    private refreshView(): void {
        this.revision += 1;
    }

    build() {
        Stack({ alignContent: Alignment.TopStart }) {
            CdScrollContainer() {
                Column() {
                    if (this.revision < 0) {
                        Blank()
                    }

                    CdTopBar({
                        title: '局域网设备',
                        subtitle: '发现同网设备，公网中转作为 fallback',
                        leadingText: this.showBack ? '返回' : '',
                        trailingText: '刷新',
                        onLeadingTap: () => {},
                        onTrailingTap: () => {
                            this.viewModel.refreshDevices();
                            this.refreshView();
                        }
                    })

                    CdBanner({
                        title: this.viewModel.lastActionText.length > 0 ? this.viewModel.lastActionText : '设备发现尚未接入',
                        description: `在线 ${this.viewModel.getOnlineDevices().length} 台 · 局域网 ${this.viewModel.getLanDevices().length} 台`,
                        tone: 'info'
                    })

                    CdSectionHeader({ title: '在线设备' })

                    CdDeviceList({ devices: this.viewModel.getOnlineDevices() })
                }
                .width('100%')
            }
        }
        .width('100%')
        .height('100%')
    }
}
