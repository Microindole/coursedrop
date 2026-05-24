import {
    CdIconButton,
    CdInfoRow,
    CdPanel,
    CdRelaySourceList,
    CdScrollContainer,
    CdSectionHeader,
    CdSelectField,
    CdSwitchRow,
    CdTextField,
    CdTopBar
} from '../components/index';
import { AppSpacing } from '../common/Theme';
import { CachePolicy, SettingsViewModel } from '../viewmodels/SettingsViewModel';

@Component
export default struct SettingsPage {
    private viewModel: SettingsViewModel = new SettingsViewModel();
    showBack: boolean = false;
    @State relayUrl: string = '';
    @State e2eeEnabled: boolean = this.viewModel.e2eeEnabled;
    @State lanFirstEnabled: boolean = this.viewModel.lanFirstEnabled;
    @State expireOption: string = '24';
    @State cachePolicy: string = this.viewModel.cachePolicy;
    @State revision: number = 0;

    private refreshView(): void {
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
                        Column({ space: AppSpacing.MD }) {
                            CdRelaySourceList({
                                relayServers: this.viewModel.relayServers,
                                onToggle: (id: string) => {
                                    this.viewModel.toggleRelayServer(id);
                                    this.refreshView();
                                },
                                onPromote: (id: string) => {
                                    this.viewModel.promoteRelayServer(id);
                                    this.refreshView();
                                }
                            })

                            Row() {
                                Column() {
                                    CdTextField({
                                        label: '新增中转源',
                                        placeholder: 'https://relay.example.com',
                                        value: $relayUrl
                                    })
                                }
                                .layoutWeight(1)

                                CdIconButton({
                                    icon: $r('app.media.cd_icon_server'),
                                    variant: 'tonal',
                                    onTap: () => {
                                        this.viewModel.addRelayServer(this.relayUrl);
                                        this.relayUrl = '';
                                        this.refreshView();
                                    }
                                })
                            }
                            .width('100%')
                            .alignItems(VerticalAlign.Bottom)
                        }
                        .width('100%')
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

                    if (this.viewModel.lastActionText.length > 0) {
                        CdPanel() {
                            CdInfoRow({
                                title: this.viewModel.lastActionText,
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
