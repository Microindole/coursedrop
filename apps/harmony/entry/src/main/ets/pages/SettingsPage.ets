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
import { AppSpacing, AppColors, AppRadius, AppTypography } from '../common/Theme';
import { SettingsViewModel, CachePolicy } from '../viewmodels/SettingsViewModel';
import router from '@ohos.router';

@Component
export default struct SettingsPage {
  showBack: boolean = false;
  private viewModel: SettingsViewModel = new SettingsViewModel();

  @State e2eeEnabled: boolean = this.viewModel.e2eeEnabled;
  @State lanFirstEnabled: boolean = this.viewModel.lanFirstEnabled;
  @State expireOption: string = this.viewModel.defaultExpireHours;
  @State cachePolicy: string = this.viewModel.cachePolicy;
  @State actionText: string = '连接策略设置';
  @State loginCode: string = '';
  @State scannedText: string = '';
  @State accountUsername: string = '';
  @State accountPassword: string = '';
  @State accountPasswordLoginEnabled: boolean = false;

  aboutToAppear() {
    this.syncSettings();
  }

  private syncSettings() {
    this.e2eeEnabled = this.viewModel.e2eeEnabled;
    this.lanFirstEnabled = this.viewModel.lanFirstEnabled;
    this.expireOption = this.viewModel.defaultExpireHours;
    this.cachePolicy = this.viewModel.cachePolicy;
    this.accountPasswordLoginEnabled = this.viewModel.passwordLoginEnabled;
    this.actionText = this.viewModel.lastActionText.length > 0 ? this.viewModel.lastActionText : '配置信息已同步';
  }

  private cachePolicyValue(value: string): CachePolicy {
    if (value === 'DAILY') return 'DAILY';
    if (value === 'MANUAL') return 'MANUAL';
    return 'EXPIRED_ONLY';
  }

  private async registerCurrentDevice() {
    await this.viewModel.registerCurrentDevice();
    this.syncSettings();
  }

  private async confirmWebLogin() {
    if (this.loginCode.length === 0) {
      this.actionText = '请输入网页登录提取码';
      return;
    }
    await this.viewModel.confirmWebLogin(this.loginCode);
    this.loginCode = '';
    this.syncSettings();
  }

  private async handleScannedText() {
    if (this.scannedText.length === 0) {
      this.actionText = '请输入要解析的扫码调试数据';
      return;
    }
    await this.viewModel.handleScannedText(this.scannedText);
    this.scannedText = '';
    this.syncSettings();
  }

  private async openCameraScanner() {
    await this.viewModel.openCameraScanner();
    this.syncSettings();
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      CdScrollContainer({ showScrollBar: true }) {
        CdTopBar({
          title: '系统设置',
          subtitle: '管理本地加密方式、缓存清理及多端配对',
          leadingText: this.showBack ? '返回' : '',
          onLeadingTap: () => {
            router.back();
          }
        })

        // 连接策略与身份标识卡片
        CdSectionHeader({ title: '设备身份与连接' })
        
        CdPanel({ hasShadow: true }) {
          Column({ space: AppSpacing.MD }) {
            CdInfoRow({
              title: '本机设备指纹',
              value: this.viewModel.localIdentity === undefined ? '尚未获取指纹 ID' : this.viewModel.localIdentity.fingerprintId,
              mark: 'IDENTITY'
            })

            CdButton({
              label: '刷新/重新生成设备指纹',
              variant: 'tonal',
              onTap: () => {
                this.registerCurrentDevice();
              }
            })
            .width('100%')

            Divider()
              .color(AppColors.BORDER)
              .strokeWidth(0.5)

            CdSwitchRow({
              title: '局域网优先直传',
              description: '开启后优先采用 Socket 直连，免中转带宽限制',
              isOn: $lanFirstEnabled,
              onChange: (enabled: boolean) => {
                this.lanFirstEnabled = enabled;
                this.viewModel.updateSecurity(this.e2eeEnabled, this.lanFirstEnabled);
                this.syncSettings();
              }
            })
          }
          .width('100%')
        }

        // Web端配对卡片
        CdSectionHeader({ title: '电脑浏览器扫码登录配对' })

        CdPanel({ hasShadow: true }) {
          Column({ space: AppSpacing.MD }) {
            CdTextField({
              label: '网页提取码配对',
              placeholder: '请输入电脑浏览器端显示的六位登录码',
              value: $loginCode
            })

            CdButton({
              label: '授权网页端登录',
              onTap: () => {
                this.confirmWebLogin();
              }
            })
            .width('100%')
          }
          .width('100%')
        }

        CdSectionHeader({ title: '账号安全' })

        CdPanel({ hasShadow: true }) {
          Column({ space: AppSpacing.MD }) {
            CdInfoRow({
              title: '账号绑定',
              value: this.viewModel.localIdentity === undefined || this.viewModel.localIdentity.accountId.length === 0 ?
                '未创建账号，默认使用本机指纹扫码' : this.viewModel.localIdentity.accountId,
              mark: 'ACC'
            })

            CdTextField({
              label: '账号名',
              placeholder: '用于可选的网页登录',
              value: $accountUsername
            })

            CdTextField({
              label: '密码',
              placeholder: '开启账号密码登录时使用',
              value: $accountPassword
            })

            CdSwitchRow({
              title: '允许账号密码登录',
              description: '默认推荐扫码登录；开启后电脑浏览器可输入账号密码',
              isOn: $accountPasswordLoginEnabled,
              onChange: (enabled: boolean) => {
                this.accountPasswordLoginEnabled = enabled;
                if (this.viewModel.localIdentity !== undefined && this.viewModel.localIdentity.accountId.length > 0) {
                  this.viewModel.updateAccountSecurity(enabled).then(() => {
                    this.syncSettings();
                  });
                }
              }
            })

            CdButton({
              label: '创建账号并绑定本机',
              variant: 'tonal',
              onTap: () => {
                this.viewModel.createAccount(
                  this.accountUsername,
                  this.accountPassword,
                  this.accountPasswordLoginEnabled
                ).then(() => {
                  this.accountPassword = '';
                  this.syncSettings();
                });
              }
            })
            .width('100%')

            CdButton({
              label: '登录已有账号并绑定本机',
              onTap: () => {
                this.viewModel.loginAccount(
                  this.accountUsername,
                  this.accountPassword
                ).then(() => {
                  this.accountPassword = '';
                  this.syncSettings();
                });
              }
            })
            .width('100%')
          }
          .width('100%')
        }

        // 扫码调试面板
        CdSectionHeader({ title: '扫码与解析' })

        CdPanel({ hasShadow: true }) {
          Column({ space: AppSpacing.MD }) {
            CdButton({
              label: '打开系统相机扫码',
              onTap: () => {
                this.openCameraScanner();
              }
            })
            .width('100%')

            Divider()
              .color(AppColors.BORDER)
              .strokeWidth(0.5)

            CdTextField({
              label: '解析内容粘贴',
              placeholder: '粘贴 login:/share: 等协议前缀的调试字符串',
              value: $scannedText
            })

            CdButton({
              label: '调试解析扫码流',
              variant: 'tonal',
              onTap: () => {
                this.handleScannedText();
              }
            })
            .width('100%')

            if (this.viewModel.lastScannedShareCode.length > 0) {
              CdButton({
                label: '打开识别到的分享',
                onTap: () => {
                  router.pushUrl({
                    url: 'pages/ShareDownloadPage',
                    params: {
                      code: this.viewModel.lastScannedShareText.length > 0 ?
                        this.viewModel.lastScannedShareText : this.viewModel.lastScannedShareCode
                    }
                  });
                }
              })
              .width('100%')
            }
          }
          .width('100%')
        }

        // 中转源
        CdSectionHeader({ title: '公网中转源配置' })

        CdPanel({ hasShadow: true }) {
          Row() {
            Column({ space: 4 }) {
              Text('管理公网中转服务器')
                .fontSize(AppTypography.BODY_SMALL)
                .fontWeight(FontWeight.Bold)
                .fontColor(AppColors.TEXT)
              
              Text('新增、编辑、删除或停用自定义的中转服务器')
                .fontSize(11)
                .fontColor(AppColors.TEXT_SECONDARY)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)

            Image($r('app.media.cd_icon_done')) // 用 done 作为右侧箭头
              .width(14)
              .height(14)
              .fillColor(AppColors.MUTED)
              .rotate({ angle: 270 })
          }
          .width('100%')
          .padding({ top: AppSpacing.SM, bottom: AppSpacing.SM })
          .onClick(() => {
            router.pushUrl({ url: 'pages/RelaySourcePage' });
          })
        }

        CdSectionHeader({ title: '诊断信息' })

        CdPanel({ hasShadow: false }) {
          Column({ space: AppSpacing.MD }) {
            CdInfoRow({
              title: '本地库目录',
              value: this.viewModel.getLibraryRoot().length === 0 ? '应用目录尚未初始化' : this.viewModel.getLibraryRoot(),
              mark: 'LIB'
            })

            CdInfoRow({
              title: '下载接收目录',
              value: this.viewModel.getIncomingRoot().length === 0 ? '应用目录尚未初始化' : this.viewModel.getIncomingRoot(),
              mark: 'IN'
            })

            CdInfoRow({
              title: '索引数量',
              value: `${this.viewModel.getLocalIndexCount()} 项`,
              mark: 'DB'
            })

            CdInfoRow({
              title: '中转源数量',
              value: `${this.viewModel.getRelaySourceCount()} 个`,
              mark: 'SRC'
            })
          }
          .width('100%')
        }

        // 安全
        CdSectionHeader({ title: '隐私与安全加密' })

        CdPanel({ hasShadow: true }) {
          Column({ space: AppSpacing.MD }) {
            CdSwitchRow({
              title: '端到端加密传输 (E2EE)',
              description: '公网中转服务器只存储加密密文，密钥在本地保留',
              isOn: $e2eeEnabled,
              onChange: (enabled: boolean) => {
                this.e2eeEnabled = enabled;
                this.viewModel.updateSecurity(this.e2eeEnabled, this.lanFirstEnabled);
                this.syncSettings();
              }
            })
          }
          .width('100%')
        }

        // 缓存策略
        CdSectionHeader({ title: '存储与缓存清理' })

        CdPanel({ hasShadow: true }) {
          Column({ space: AppSpacing.LG }) {
            CdSelectField({
              label: '默认提取链接时效',
              placeholder: '设置新生成提取码的有效时长',
              selectedValue: $expireOption,
              onChange: (value: string) => {
                this.expireOption = value;
                this.viewModel.updatePolicies(this.expireOption, this.cachePolicyValue(this.cachePolicy));
                this.syncSettings();
              },
              options: [
                { label: '1 小时', value: '1' },
                { label: '6 小时', value: '6' },
                { label: '24 小时', value: '24' },
                { label: '7 天', value: '168' }
              ]
            })

            Divider()
              .color(AppColors.BORDER)
              .strokeWidth(0.5)

            CdSelectField({
              label: '本地缓存清理机制',
              placeholder: '配置提取缓存目录的清理策略',
              selectedValue: $cachePolicy,
              onChange: (value: string) => {
                this.cachePolicy = this.cachePolicyValue(value);
                this.viewModel.updatePolicies(this.expireOption, this.cachePolicyValue(value));
                this.syncSettings();
              },
              options: [
                { label: '仅清理已过期内容', value: 'EXPIRED_ONLY' },
                { label: '每天定时自动清理', value: 'DAILY' },
                { label: '完全手动清理', value: 'MANUAL' }
              ]
            })
          }
          .width('100%')
        }

        // 设置底部的状态显示栏
        if (this.actionText.length > 0) {
          CdPanel({ hasShadow: false }) {
            Row() {
              Text(this.actionText)
                .fontSize(11)
                .fontColor(AppColors.TEXT_SECONDARY)
                .textAlign(TextAlign.Center)
                .width('100%')
            }
            .width('100%')
          }
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColors.BACKGROUND)
  }
}
