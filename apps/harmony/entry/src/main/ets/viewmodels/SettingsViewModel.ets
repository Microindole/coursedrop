import { RelayServerConfig } from '../models/RelayServerConfig';
import { apiClient } from '../services/ApiClient';
import { identityService } from '../services/identity';
import { LocalIdentity } from '../services/identity';
import { relaySourceService } from '../services/relay';
import { relayHealthService } from '../services/relay';
import { scanDispatchService } from '../services/scan';
import { settingsService } from '../services/settings';
import type { CachePolicy } from '../services/settings';

export type { CachePolicy } from '../services/settings';

export class SettingsViewModel {
  relayServers: RelayServerConfig[] = relaySourceService.listRelayServers();
  private settings = settingsService.getSettings();
  e2eeEnabled: boolean = this.settings.e2eeEnabled;
  lanFirstEnabled: boolean = this.settings.lanFirstEnabled;
  defaultExpireHours: string = this.settings.defaultExpireHours;
  cachePolicy: CachePolicy = this.settings.cachePolicy;
  lastActionText: string = '';
  localIdentity: LocalIdentity | undefined = identityService.getLocalIdentity();

  reloadRelayServers(): RelayServerConfig[] {
    this.relayServers = relaySourceService.listRelayServers();
    return this.copyRelayServers(this.relayServers);
  }

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
    this.reloadRelayServers();
    return this.relayServers.length > previousCount;
  }

  updateRelayServer(id: string, url: string): boolean {
    this.lastActionText = relaySourceService.updateRelayServer(id, url);
    this.reloadRelayServers();
    return this.lastActionText === '中转源已更新';
  }

  removeRelayServer(id: string): void {
    this.lastActionText = relaySourceService.removeRelayServer(id);
    this.reloadRelayServers();
  }

  toggleRelayServer(id: string): void {
    this.lastActionText = relaySourceService.toggleRelayServer(id);
    this.reloadRelayServers();
  }

  promoteRelayServer(id: string): void {
    this.lastActionText = relaySourceService.promoteRelayServer(id);
    this.reloadRelayServers();
  }

  private copyRelayServers(source: RelayServerConfig[]): RelayServerConfig[] {
    const servers: RelayServerConfig[] = [];
    source.forEach((server: RelayServerConfig) => {
      servers.push({
        id: server.id,
        name: server.name,
        url: server.url,
        enabled: server.enabled,
        priority: server.priority
      });
    });
    return servers;
  }

  async probeRelayServer(id: string): Promise<string> {
    const server = this.relayServers.find((next: RelayServerConfig) => next.id === id);
    if (server === undefined) {
      this.lastActionText = '中转源不存在';
      return this.lastActionText;
    }
    apiClient.setBaseUrl(server.url);
    const result = await relayHealthService.probe();
    if (result.ok) {
      if (result.version.length > 0) {
        this.lastActionText = `${result.message} · ${result.service} ${result.version}`;
        return this.lastActionText;
      }
      this.lastActionText = `${result.message} · ${result.service}`;
      return this.lastActionText;
    }
    this.lastActionText = result.message;
    return this.lastActionText;
  }

  async registerCurrentDevice(): Promise<void> {
    try {
      this.localIdentity = await identityService.registerCurrentDevice();
      this.lastActionText = `本机身份已注册：${this.localIdentity.fingerprintId}`;
    } catch (error) {
      this.lastActionText = `本机身份注册失败：${String(error)}`;
    }
  }

  async confirmWebLogin(loginCode: string): Promise<void> {
    const normalizedCode = loginCode.trim();
    if (normalizedCode.length === 0) {
      this.lastActionText = '请输入网页登录码';
      return;
    }
    try {
      await identityService.confirmWebLogin(normalizedCode);
      this.lastActionText = '网页登录已确认';
    } catch (error) {
      this.lastActionText = `确认失败：${String(error)}`;
    }
  }

  updateSecurity(e2eeEnabled: boolean, lanFirstEnabled: boolean): void {
    this.settings = settingsService.updateSecurity(e2eeEnabled, lanFirstEnabled);
    this.e2eeEnabled = this.settings.e2eeEnabled;
    this.lanFirstEnabled = this.settings.lanFirstEnabled;
    this.lastActionText = '连接策略已更新';
  }

  async handleScannedText(rawText: string): Promise<void> {
    try {
      const result = await scanDispatchService.dispatch(rawText);
      this.lastActionText = result.message;
    } catch (error) {
      this.lastActionText = `扫码处理失败：${String(error)}`;
    }
  }

  updatePolicies(expireHours: string, cachePolicy: CachePolicy): void {
    this.settings = settingsService.updatePolicies(expireHours, cachePolicy);
    this.defaultExpireHours = this.settings.defaultExpireHours;
    this.cachePolicy = this.settings.cachePolicy;
    this.lastActionText = '过期与缓存策略已更新';
  }
}
