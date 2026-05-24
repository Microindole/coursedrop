import { AppConfig } from '../common/AppConfig';
import { RelayServerConfig } from '../models/RelayServerConfig';

export type CachePolicy = 'MANUAL' | 'DAILY' | 'EXPIRED_ONLY';

export class SettingsViewModel {
  relayServers: RelayServerConfig[] = [
    {
      id: 'local-dev',
      name: '本机调试源',
      url: AppConfig.DEFAULT_SERVER_URL,
      enabled: true,
      priority: 1
    },
    {
      id: 'course-relay',
      name: '课程公网源',
      url: 'https://relay.coursedrop.example',
      enabled: false,
      priority: 2
    }
  ];
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

  addRelayServer(url: string): void {
    const normalizedUrl = url.trim();
    if (normalizedUrl.length === 0) {
      this.lastActionText = '中转源地址为空';
      return;
    }
    const nextPriority = this.relayServers.length + 1;
    this.relayServers = this.relayServers.concat([{
      id: `relay-${nextPriority}`,
      name: `自定义源 ${nextPriority}`,
      url: normalizedUrl,
      enabled: true,
      priority: nextPriority
    }]);
    this.lastActionText = '已新增中转源';
  }

  toggleRelayServer(id: string): void {
    this.relayServers = this.relayServers.map((server) => {
      if (server.id !== id) {
        return server;
      }
      server.enabled = !server.enabled;
      return server;
    });
    this.lastActionText = '中转源状态已更新';
  }

  promoteRelayServer(id: string): void {
    const target = this.relayServers.find((server) => server.id === id);
    if (target === undefined || target.priority <= 1) {
      return;
    }
    const previousPriority = target.priority - 1;
    this.relayServers = this.relayServers.map((server) => {
      if (server.id === id) {
        server.priority = previousPriority;
        return server;
      }
      if (server.priority === previousPriority) {
        server.priority = target.priority;
        return server;
      }
      return server;
    }).sort((left, right) => left.priority - right.priority);
    this.lastActionText = '中转源优先级已调整';
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
