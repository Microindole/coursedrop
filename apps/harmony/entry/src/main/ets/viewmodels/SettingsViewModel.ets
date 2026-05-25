import { RelayServerConfig } from '../models/RelayServerConfig';
import { relaySourceService } from '../services/relay';

export type CachePolicy = 'MANUAL' | 'DAILY' | 'EXPIRED_ONLY';

export class SettingsViewModel {
  relayServers: RelayServerConfig[] = relaySourceService.listRelayServers();
  e2eeEnabled: boolean = true;
  lanFirstEnabled: boolean = true;
  defaultExpireHours: string = '24';
  cachePolicy: CachePolicy = 'EXPIRED_ONLY';
  lastActionText: string = '';

  getExpireOptions(): string[] {
    return ['1 小时', '6 小时', '24 小时', '7 天'];
  }

  getCachePolicyLabel(): string {
    if (this.cachePolicy === 'MANUAL') {
      return '手动清理';
    }
    if (this.cachePolicy === 'DAILY') {
      return '每天自动清理';
    }
    return '仅清理过期内容';
  }

  addRelayServer(url: string): boolean {
    const previousCount = this.relayServers.length;
    this.lastActionText = relaySourceService.addRelayServer(url);
    this.relayServers = relaySourceService.listRelayServers();
    return this.relayServers.length > previousCount;
  }

  updateRelayServer(id: string, url: string): boolean {
    this.lastActionText = relaySourceService.updateRelayServer(id, url);
    this.relayServers = relaySourceService.listRelayServers();
    return this.lastActionText === '中转源已更新';
  }

  removeRelayServer(id: string): void {
    this.lastActionText = relaySourceService.removeRelayServer(id);
    this.relayServers = relaySourceService.listRelayServers();
  }

  toggleRelayServer(id: string): void {
    this.lastActionText = relaySourceService.toggleRelayServer(id);
    this.relayServers = relaySourceService.listRelayServers();
  }

  promoteRelayServer(id: string): void {
    this.lastActionText = relaySourceService.promoteRelayServer(id);
    this.relayServers = relaySourceService.listRelayServers();
  }

  updateSecurity(e2eeEnabled: boolean, lanFirstEnabled: boolean): void {
    this.e2eeEnabled = e2eeEnabled;
    this.lanFirstEnabled = lanFirstEnabled;
    this.lastActionText = '连接策略已更新';
  }

  updatePolicies(expireHours: string, cachePolicy: CachePolicy): void {
    this.defaultExpireHours = expireHours;
    this.cachePolicy = cachePolicy;
    this.lastActionText = '过期与缓存策略已更新';
  }
}
