import { RelayServerConfig } from '../../models/RelayServerConfig';
import { ApiClient } from '../ApiClient';
import { RelaySourceRepository } from './RelaySourceRepository';
import { RelaySourceService } from './RelaySourceService';

export class ConfigurableRelaySourceService implements RelaySourceService {
  private repository: RelaySourceRepository;
  private apiClient: ApiClient;

  constructor(repository: RelaySourceRepository, apiClient: ApiClient) {
    this.repository = repository;
    this.apiClient = apiClient;
  }

  listRelayServers(): RelayServerConfig[] {
    const servers: RelayServerConfig[] = [];
    this.repository.list().forEach((server) => {
      servers.push(server);
    });
    return servers.sort((left, right) => left.priority - right.priority);
  }

  getActiveRelayServer(): RelayServerConfig | undefined {
    return this.listRelayServers().find((server) => server.enabled);
  }

  addRelayServer(url: string): string {
    const normalizedUrl = this.normalizeUrl(url);
    if (normalizedUrl === '') {
      return '中转源地址为空';
    }
    const duplicated = this.repository.list().find((server) => server.url === normalizedUrl);
    if (duplicated !== undefined) {
      return '中转源已存在';
    }
    const nextPriority = this.repository.list().length + 1;
    this.repository.save({
      id: `relay-${Date.now()}`,
      name: `中转源 ${nextPriority}`,
      url: normalizedUrl,
      enabled: true,
      priority: nextPriority
    });
    this.syncApiBaseUrl();
    return '已新增中转源';
  }

  updateRelayServer(id: string, url: string): string {
    const server = this.repository.list().find((next) => next.id === id);
    if (server === undefined) {
      return '中转源不存在';
    }
    const normalizedUrl = this.normalizeUrl(url);
    if (normalizedUrl === '') {
      return '中转源地址为空';
    }
    const duplicated = this.repository.list().find((next) => next.id !== id && next.url === normalizedUrl);
    if (duplicated !== undefined) {
      return '中转源已存在';
    }
    server.url = normalizedUrl;
    this.repository.save(server);
    this.syncApiBaseUrl();
    return '中转源已更新';
  }

  removeRelayServer(id: string): string {
    const server = this.repository.list().find((next) => next.id === id);
    if (server === undefined) {
      return '中转源不存在';
    }
    this.repository.remove(id);
    this.reorderPriority();
    this.syncApiBaseUrl();
    return '中转源已删除';
  }

  toggleRelayServer(id: string): string {
    const server = this.repository.list().find((next) => next.id === id);
    if (server === undefined) {
      return '中转源不存在';
    }
    server.enabled = !server.enabled;
    this.repository.save(server);
    this.syncApiBaseUrl();
    return '中转源状态已更新';
  }

  promoteRelayServer(id: string): string {
    const servers = this.repository.list();
    const target = servers.find((server) => server.id === id);
    if (target === undefined || target.priority <= 1) {
      return '';
    }
    const previousPriority = target.priority - 1;
    const targetPriority = target.priority;
    servers.forEach((server) => {
      if (server.id === id) {
        server.priority = previousPriority;
        this.repository.save(server);
      } else if (server.priority === previousPriority) {
        server.priority = targetPriority;
        this.repository.save(server);
      }
    });
    this.syncApiBaseUrl();
    return '中转源优先级已调整';
  }

  private normalizeUrl(url: string): string {
    let normalizedUrl = url.trim();
    if (normalizedUrl.length === 0) {
      return '';
    }
    if (!normalizedUrl.startsWith('http://') && !normalizedUrl.startsWith('https://')) {
      normalizedUrl = `https://${normalizedUrl}`;
    }
    return normalizedUrl;
  }

  private reorderPriority(): void {
    const servers = this.listRelayServers();
    let priority = 1;
    servers.forEach((server) => {
      server.priority = priority;
      priority += 1;
      this.repository.save(server);
    });
  }

  applyActiveServer(): void {
    this.syncApiBaseUrl();
  }

  private syncApiBaseUrl(): void {
    const activeRelayServer = this.getActiveRelayServer();
    if (activeRelayServer === undefined) {
      this.apiClient.setBaseUrl('');
      return;
    }
    this.apiClient.setBaseUrl(activeRelayServer.url);
  }
}
