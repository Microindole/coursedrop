import { RelayServerConfig } from '../../models/RelayServerConfig';

export interface RelaySourceRepository {
  list(): RelayServerConfig[];
  save(server: RelayServerConfig): void;
  remove(id: string): void;
}

export class LocalRelaySourceRepository implements RelaySourceRepository {
  private relayServers: RelayServerConfig[] = [];

  list(): RelayServerConfig[] {
    return this.relayServers;
  }

  save(server: RelayServerConfig): void {
    const index = this.relayServers.findIndex((next) => next.id === server.id);
    if (index < 0) {
      this.relayServers.push(server);
      return;
    }
    this.relayServers[index] = server;
  }

  remove(id: string): void {
    this.relayServers = this.relayServers.filter((server) => server.id !== id);
  }
}
