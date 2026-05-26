import { ConfigurableRelaySourceService } from './ConfigurableRelaySourceService';
import { apiClient } from '../ApiClient';
import { LocalRelaySourceRepository } from './RelaySourceRepository';
import { RelaySourceService } from './RelaySourceService';
import { RelayHealthService } from './RelayHealthService';

export { ConfigurableRelaySourceService } from './ConfigurableRelaySourceService';
export type { RelayHealthProbe } from './RelayHealthService';
export { RelayHealthService } from './RelayHealthService';
export type { RelaySourceRepository } from './RelaySourceRepository';
export { LocalRelaySourceRepository } from './RelaySourceRepository';
export type { RelaySourceService } from './RelaySourceService';

export const relaySourceService: RelaySourceService = new ConfigurableRelaySourceService(
  new LocalRelaySourceRepository(),
  apiClient
);
export const relayHealthService: RelayHealthService = new RelayHealthService(apiClient);
