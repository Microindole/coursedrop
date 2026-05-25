import { ConfigurableRelaySourceService } from './ConfigurableRelaySourceService';
import { apiClient } from '../ApiClient';
import { LocalRelaySourceRepository } from './RelaySourceRepository';
import { RelaySourceService } from './RelaySourceService';

export { ConfigurableRelaySourceService } from './ConfigurableRelaySourceService';
export type { RelaySourceRepository } from './RelaySourceRepository';
export { LocalRelaySourceRepository } from './RelaySourceRepository';
export type { RelaySourceService } from './RelaySourceService';

export const relaySourceService: RelaySourceService = new ConfigurableRelaySourceService(
  new LocalRelaySourceRepository(),
  apiClient
);
