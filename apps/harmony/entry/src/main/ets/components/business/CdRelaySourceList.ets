import { AppSpacing } from '../../common/Theme';
import { RelayServerConfig } from '../../models/RelayServerConfig';
import { CdIconButton } from '../actions/CdIconButton';
import { CdInfoRow } from '../display/CdInfoRow';

@Component
export struct CdRelaySourceList {
  relayServers: RelayServerConfig[] = [];
  onToggle: (id: string) => void = (_id: string) => {};
  onPromote: (id: string) => void = (_id: string) => {};

  build() {
    Column({ space: AppSpacing.SM }) {
      ForEach(this.relayServers, (server: RelayServerConfig) => {
        Row() {
          Column() {
            CdInfoRow({
              title: server.name,
              value: `${server.enabled ? '启用' : '停用'} · 优先级 ${server.priority} · ${server.url}`,
              mark: 'SERVER'
            })
          }
          .layoutWeight(1)
          .onClick(() => {
            this.onPromote(server.id);
          })

          CdIconButton({
            icon: server.enabled ? $r('app.media.cd_icon_done') : $r('app.media.cd_icon_close'),
            variant: server.enabled ? 'tonal' : 'plain',
            onTap: () => {
              this.onToggle(server.id);
            }
          })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
      }, (server: RelayServerConfig) => server.id)
    }
    .width('100%')
  }
}
