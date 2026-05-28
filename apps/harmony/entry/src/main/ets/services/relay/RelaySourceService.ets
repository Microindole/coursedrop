import { RelayServerConfig } from '../../models/RelayServerConfig';

export interface RelaySourceService {
  listRelayServers(): RelayServerConfig[];
  getActiveRelayServer(): RelayServerConfig | undefined;
  addRelayServer(url: string): string;
  updateRelayServer(id: string, url: string): string;
  removeRelayServer(id: string): string;
  toggleRelayServer(id: string): string;
  promoteRelayServer(id: string): string;
  applyActiveServer(): void;
}
