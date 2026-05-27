import {
    CdButton,
    CdInfoRow,
    CdPanel,
    CdScrollContainer,
    CdSectionHeader,
    CdSelectField,
    CdSwitchRow,
    CdTextField,
    CdTopBar
} from '../components/index';
import { AppSpacing } from '../common/Theme';
import { SettingsViewModel } from '../viewmodels/SettingsViewModel';
import type { CachePolicy } from '../viewmodels/SettingsViewModel';
import router from '@ohos.router';

@Component
export default struct SettingsPage {
    private viewModel: SettingsViewModel = new SettingsViewModel();
    showBack: boolean = false;
    @State e2eeEnabled: boolean = this.viewModel.e2eeEnabled;
    @State lanFirstEnabled: boolean = this.viewModel.lanFirstEnabled;
    @State expireOption: string = this.viewModel.defaultExpireHours;
    @State cachePolicy: string = this.viewModel.cachePolicy;
    @State actionText: string = this.viewModel.lastActionText;
    @State loginCode: string = '';
    @State scannedText: string = '';
    @State revision: number = 0;

    private refreshView(): void {
        this.actionText = this.viewModel.lastActionText;
        this.revision += 1;
    }

    private cachePolicyValue(value: string): CachePolicy {
        if (value === 'DAILY') {
            return 'DAILY';
        }
        if (value === 'MANUAL') {
            return 'MANUAL';
        }
        return 'EXPIRED_ONLY';
    }

    private async registerCurrentDevice(): Promise<void> {
        await this.viewModel.registerCurrentDevice();
        this.refreshView();
    }

    private async confirmWebLogin(): Promise<void> {
        await this.viewModel.confirmWebLogin(this.loginCode);
        this.refreshView();
    }

    private async handleScannedText(): Promise<void> {
        await this.viewModel.handleScannedText(this.scannedText);
        this.refreshView();
    }

    build() {
        Stack({ alignContent: Alignment.TopStart }) {
            CdScrollContainer() {
                Column() {
                    if (this.revision < 0) {
                        Blank()
                    }

                    CdTopBar({
                        title: '设置',
                        subtitle: '中转源、加密、缓存策略',
                        leadingText: this.showBack ? '返回' : '',
                        onLeadingTap: () => {}
                    })

                    CdSectionHeader({ title: '连接策略' })

                    CdPanel() {
                        Column({ space: AppSpacing.MD }) {
                            CdInfoRow({
                                title: '本机身份',
                                value: this.viewModel.localIdentity === undefined ? '尚未注册到中转服务器' : this.viewModel.localIdentity.fingerprintId,
                                mark: 'ID'
                            })

                            CdButton({
                                label: '注册或刷新本机身份',
                                variant: 'tonal',
                                onTap: () => {
                                    this.registerCurrentDevice();
                                }
                            })

                            CdTextField({
                                label: '网页登录码',
                                placeholder: '输入电脑浏览器显示的登录码',
                                value: $loginCode
                            })

                            CdButton({
                                label: '确认网页登录',
                                variant: 'tonal',
                                onTap: () => {
                                    this.confirmWebLogin();
                                }
                            })

                            CdTextField({
                                label: '扫码内容调试',
                                placeholder: '粘贴二维码内容或 login:/share: 前缀',
                                value: $scannedText
                            })

                            CdButton({
                                label: '处理扫码内容',
                                variant: 'tonal',
                                onTap: () => {
                                    this.handleScannedText();
                                }
                            })

                            CdSwitchRow({
                                title: '局域网优先',
                                description: '同网设备优先直连，跨网络再走公网中转',
                                isOn: $lanFirstEnabled,
                                onChange: (enabled: boolean) => {
                                    this.lanFirstEnabled = enabled;
                                    this.viewModel.updateSecurity(this.e2eeEnabled, this.lanFirstEnabled);
                                    this.refreshView();
                                }
                            })
                        }
                        .width('100%')
                    }

                    CdSectionHeader({ title: '公网中转源' })

                    CdPanel() {
                        Row() {
                            CdInfoRow({
                                title: '管理中转源',
                                value: '新增、编辑、停用、删除公网中转服务器',
                                mark: 'SERVER'
                            })
                        }
                        .width('100%')
                        .onClick(() => {
                            router.pushUrl({ url: 'pages/RelaySourcePage' });
                        })
                    }

                    CdSectionHeader({ title: '安全' })

                    CdPanel() {
                        Column({ space: AppSpacing.MD }) {
                            CdSwitchRow({
                                title: '端到端加密',
                                description: '公网服务器只保存临时密文',
                                isOn: $e2eeEnabled,
                                onChange: (enabled: boolean) => {
                                    this.e2eeEnabled = enabled;
                                    this.viewModel.updateSecurity(this.e2eeEnabled, this.lanFirstEnabled);
                                    this.refreshView();
                                }
                            })
                        }
                        .width('100%')
                    }

                    CdSectionHeader({ title: '过期与缓存' })

                    CdPanel() {
                        Column({ space: AppSpacing.MD }) {
                            CdSelectField({
                                label: '默认公网分享有效期',
                                placeholder: '选择有效期',
                                selectedValue: $expireOption,
                                onChange: (value: string) => {
                                    this.expireOption = value;
                                    this.viewModel.updatePolicies(this.expireOption, this.cachePolicyValue(this.cachePolicy));
                                    this.refreshView();
                                },
                                options: [
                                    { label: '1 小时', value: '1' },
                                    { label: '6 小时', value: '6' },
                                    { label: '24 小时', value: '24' },
                                    { label: '7 天', value: '168' }
                                ]
                            })

                            CdSelectField({
                                label: '缓存清理策略',
                                placeholder: '选择清理策略',
                                selectedValue: $cachePolicy,
                                onChange: (value: string) => {
                                    this.cachePolicy = this.cachePolicyValue(value);
                                    this.viewModel.updatePolicies(this.expireOption, this.cachePolicyValue(value));
                                    this.refreshView();
                                },
                                options: [
                                    { label: '仅清理过期内容', value: 'EXPIRED_ONLY' },
                                    { label: '每天自动清理', value: 'DAILY' },
                                    { label: '手动清理', value: 'MANUAL' }
                                ]
                            })
                        }
                        .width('100%')
                    }

                    if (this.actionText.length > 0) {
                        CdPanel() {
                            CdInfoRow({
                                title: this.actionText,
                                value: `局域网优先 ${this.lanFirstEnabled ? '开启' : '关闭'} · E2EE ${this.e2eeEnabled ? '开启' : '关闭'}`,
                                mark: 'SERVER'
                            })
                        }
                    }
                }
                .width('100%')
            }
        }
        .width('100%')
        .height('100%')
    }
}
