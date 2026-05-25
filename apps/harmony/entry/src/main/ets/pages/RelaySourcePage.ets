import router from '@ohos.router';
import {
  CdButton,
  CdIconButton,
  CdInfoRow,
  CdPanel,
  CdScrollContainer,
  CdSectionHeader,
  CdTextField,
  CdTopBar
} from '../components/index';
import { AppSpacing } from '../common/Theme';
import { RelayServerConfig } from '../models/RelayServerConfig';
import { SettingsViewModel } from '../viewmodels/SettingsViewModel';

@Entry
@Component
struct RelaySourcePage {
  private viewModel: SettingsViewModel = new SettingsViewModel();
  @State relayServers: RelayServerConfig[] = this.viewModel.relayServers;
  @State editingId: string = '';
  @State relayUrl: string = '';
  @State actionText: string = '';
  @State revision: number = 0;

  private refreshView(): void {
    this.relayServers = this.viewModel.relayServers;
    this.actionText = this.viewModel.lastActionText;
    this.revision += 1;
  }

  private resetForm(): void {
    this.editingId = '';
    this.relayUrl = '';
  }

  private submitRelaySource(): void {
    if (this.editingId.length === 0) {
      const added = this.viewModel.addRelayServer(this.relayUrl);
      if (added) {
        this.resetForm();
      }
      this.refreshView();
      return;
    }

    const updated = this.viewModel.updateRelayServer(this.editingId, this.relayUrl);
    if (updated) {
      this.resetForm();
    }
    this.refreshView();
  }

  private editRelaySource(server: RelayServerConfig): void {
    this.editingId = server.id;
    this.relayUrl = server.url;
    this.actionText = '正在编辑中转源';
    this.revision += 1;
  }

  @Builder
  relayRow(server: RelayServerConfig) {
    CdPanel() {
      Row({ space: AppSpacing.SM }) {
        Column() {
          CdInfoRow({
            title: server.name,
            value: `${server.enabled ? '启用' : '停用'} · 优先级 ${server.priority} · ${server.url}`,
            mark: 'SERVER'
          })
        }
        .layoutWeight(1)
        .onClick(() => {
          this.editRelaySource(server);
        })

        CdIconButton({
          icon: server.enabled ? $r('app.media.cd_icon_done') : $r('app.media.cd_icon_close'),
          variant: server.enabled ? 'tonal' : 'plain',
          onTap: () => {
            this.viewModel.toggleRelayServer(server.id);
            this.refreshView();
          }
        })

        CdIconButton({
          icon: $r('app.media.cd_icon_server'),
          variant: 'plain',
          onTap: () => {
            this.viewModel.promoteRelayServer(server.id);
            this.refreshView();
          }
        })

        CdIconButton({
          icon: $r('app.media.cd_icon_trash'),
          variant: 'danger',
          onTap: () => {
            this.viewModel.removeRelayServer(server.id);
            if (this.editingId === server.id) {
              this.resetForm();
            }
            this.refreshView();
          }
        })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      CdScrollContainer() {
        Column({ space: AppSpacing.MD }) {
          if (this.revision < 0) {
            Blank()
          }

          CdTopBar({
            title: '中转源',
            subtitle: '管理公网中转服务器',
            leadingText: '返回',
            onLeadingTap: () => {
              router.back();
            }
          })

          CdPanel() {
            Column({ space: AppSpacing.MD }) {
              CdTextField({
                label: this.editingId.length === 0 ? '新增中转源' : '编辑中转源',
                placeholder: 'https://你的中转域名',
                value: $relayUrl
              })

              Row({ space: AppSpacing.SM }) {
                CdButton({
                  label: this.editingId.length === 0 ? '添加' : '保存',
                  variant: 'contained',
                  onTap: () => {
                    this.submitRelaySource();
                  }
                })
                .layoutWeight(1)

                CdButton({
                  label: '清空',
                  variant: 'tonal',
                  onTap: () => {
                    this.resetForm();
                    this.refreshView();
                  }
                })
                .layoutWeight(1)
              }
              .width('100%')
            }
            .width('100%')
          }

          if (this.actionText.length > 0) {
            CdPanel() {
              CdInfoRow({
                title: this.actionText,
                value: '中转源会决定公网分享接口地址',
                mark: 'SERVER'
              })
            }
          }

          CdSectionHeader({ title: '已配置中转源' })

          if (this.relayServers.length === 0) {
            CdPanel() {
              CdInfoRow({
                title: '暂无中转源',
                value: '添加你的公网服务器地址后再创建公网分享',
                mark: 'SERVER'
              })
            }
          }

          ForEach(this.relayServers, (server: RelayServerConfig) => {
            this.relayRow(server);
          }, (server: RelayServerConfig) => server.id)

          Blank()
        }
        .width('100%')
      }
    }
    .width('100%')
    .height('100%')
  }
}
