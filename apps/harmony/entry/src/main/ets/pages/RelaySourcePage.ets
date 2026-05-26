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
import { AppColors, AppSpacing, AppTypography } from '../common/Theme';
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
  @State probing: boolean = false;
  @State debugLines: string[] = [];
  private probeSequence: number = 0;

  private refreshView(): void {
    this.relayServers = this.viewModel.reloadRelayServers();
    this.actionText = this.viewModel.lastActionText;
    this.revision += 1;
  }

  private refreshRelayServers(): void {
    this.relayServers = this.viewModel.reloadRelayServers();
    this.revision += 1;
  }

  private resetForm(): void {
    this.editingId = '';
    this.relayUrl = '';
  }

  private appendDebug(message: string): void {
    const lines: string[] = [];
    lines.push(`${new Date().toLocaleTimeString()} ${message}`);
    this.debugLines.forEach((line: string, index: number) => {
      if (index < 5) {
        lines.push(line);
      }
    });
    this.debugLines = lines;
  }

  private findNewestRelayId(): string {
    let relayId = '';
    let priority = -1;
    this.relayServers.forEach((server: RelayServerConfig) => {
      if (server.priority > priority) {
        priority = server.priority;
        relayId = server.id;
      }
    });
    return relayId;
  }

  private submitRelaySource(): void {
    if (this.editingId.length === 0) {
      const added = this.viewModel.addRelayServer(this.relayUrl);
      if (added) {
        this.resetForm();
        this.appendDebug('已写入中转源，正在刷新列表');
      }
      this.refreshView();
      const newRelayId = this.findNewestRelayId();
      if (added && newRelayId.length > 0) {
        this.appendDebug(`新增源已出现在列表：${newRelayId}`);
        this.probeRelaySource(newRelayId);
      }
      return;
    }

    const updatedId = this.editingId;
    const updated = this.viewModel.updateRelayServer(updatedId, this.relayUrl);
    if (updated) {
      this.resetForm();
      this.appendDebug('已保存中转源，准备重新探测');
    }
    this.refreshView();
    if (updated) {
      this.probeRelaySource(updatedId);
    }
  }

  private editRelaySource(server: RelayServerConfig): void {
    this.editingId = server.id;
    this.relayUrl = server.url;
    this.actionText = '正在编辑中转源';
    this.revision += 1;
  }

  private probeRelaySource(id: string): void {
    const target = this.relayServers.find((server: RelayServerConfig) => server.id === id);
    if (target === undefined) {
      this.actionText = '中转源不存在';
      this.appendDebug(`探测取消：找不到 ${id}`);
      this.revision += 1;
      return;
    }

    this.probeSequence += 1;
    const currentSequence = this.probeSequence;
    this.actionText = '正在探测中转源...';
    this.probing = true;
    this.appendDebug(`开始探测 ${target.url}/api/health`);
    this.revision += 1;

    setTimeout(() => {
      if (this.probing && this.probeSequence === currentSequence) {
        this.probing = false;
        this.actionText = '探测超时：请确认地址只填写根域名，并检查应用网络权限';
        this.appendDebug('探测超时：HTTP 模块没有在 6 秒内返回');
        this.revision += 1;
      }
    }, 6000);

    this.viewModel.probeRelayServer(id)
      .then((message: string) => {
        if (this.probeSequence !== currentSequence) {
          return;
        }
        this.probing = false;
        this.actionText = message;
        this.appendDebug(`探测返回：${message}`);
        this.refreshRelayServers();
      })
      .catch((error: Error) => {
        if (this.probeSequence !== currentSequence) {
          return;
        }
        this.probing = false;
        this.actionText = `探测失败：${String(error)}`;
        this.appendDebug(this.actionText);
        this.revision += 1;
      });
  }

  @Builder
  relayRow(server: RelayServerConfig) {
    CdPanel() {
      Row({ space: AppSpacing.SM }) {
        Image($r('app.media.cd_icon_relay'))
          .width(24)
          .height(24)
          .fillColor(server.enabled ? AppColors.PRIMARY_SELECTED : AppColors.MUTED)
          .margin({ right: AppSpacing.SM })

        Column({ space: AppSpacing.XS }) {
          Text(server.name)
            .fontSize(AppTypography.BODY)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppColors.TEXT)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(server.url)
            .fontSize(AppTypography.CAPTION)
            .fontColor(AppColors.TEXT_SECONDARY)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(`${server.enabled ? '启用' : '停用'} · 优先级 ${server.priority}`)
            .fontSize(AppTypography.CAPTION)
            .fontColor(server.enabled ? AppColors.SUCCESS : AppColors.MUTED)
            .maxLines(1)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .onClick(() => {
          this.editRelaySource(server);
        })

        CdIconButton({
          icon: $r('app.media.cd_icon_edit'),
          variant: 'plain',
          onTap: () => {
            this.editRelaySource(server);
          }
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
          icon: $r('app.media.cd_icon_refresh'),
          variant: 'plain',
          onTap: () => {
            this.probeRelaySource(server.id);
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
              Row() {
                Image($r('app.media.cd_icon_server'))
                  .width(24)
                  .height(24)
                  .fillColor(this.probing ? AppColors.WARNING : AppColors.SUCCESS)
                  .margin({ right: AppSpacing.MD })

                Column({ space: AppSpacing.XS }) {
                  Text(this.actionText)
                    .fontSize(AppTypography.BODY)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(AppColors.TEXT)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })

                  Text(this.probing ? '正在请求 /api/health，超时会自动提示' : '中转源会决定公网分享接口地址')
                    .fontSize(AppTypography.CAPTION)
                    .fontColor(AppColors.TEXT_SECONDARY)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .width('100%')
              .alignItems(VerticalAlign.Center)
            }
          }

          CdSectionHeader({ title: `已配置中转源（${this.relayServers.length}）` })

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
          }, (server: RelayServerConfig) => `${server.id}-${this.revision}`)

          if (this.debugLines.length > 0) {
            CdSectionHeader({ title: '调试信息' })

            CdPanel() {
              Column({ space: AppSpacing.XS }) {
                ForEach(this.debugLines, (line: string) => {
                  Text(line)
                    .fontSize(12)
                    .fontColor('#667085')
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }, (line: string) => line)
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
            }
          }

          Blank()
        }
        .width('100%')
      }
    }
    .width('100%')
    .height('100%')
  }
}
