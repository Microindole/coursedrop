import { ConfigurableRelaySourceService } from './ConfigurableRelaySourceService';
import { apiClient } from '../ApiClient';
import { PreferencesRelaySourceRepository } from './RelaySourceRepository';
import { RelaySourceService } from './RelaySourceService';
import { RelayHealthService } from './RelayHealthService';

export { ConfigurableRelaySourceService } from './ConfigurableRelaySourceService';
export type { RelayHealthProbe } from './RelayHealthService';
export { RelayHealthService } from './RelayHealthService';
export type { RelaySourceRepository } from './RelaySourceRepository';
export { LocalRelaySourceRepository, PreferencesRelaySourceRepository } from './RelaySourceRepository';
export type { RelaySourceService } from './RelaySourceService';

export const relaySourceService: RelaySourceService = new ConfigurableRelaySourceService(
  new PreferencesRelaySourceRepository(),
  apiClient
);
export const relayHealthService: RelayHealthService = new RelayHealthService(apiClient);
