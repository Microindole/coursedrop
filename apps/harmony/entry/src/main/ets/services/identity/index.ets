import { apiClient } from '../ApiClient';
import { IdentityService } from './IdentityService';
import { PreferencesIdentityRepository } from './IdentityRepository';

export type { DeviceFingerprintResponse, LocalIdentity } from './IdentityModels';
export type { IdentityRepository } from './IdentityRepository';
export { LocalIdentityRepository, PreferencesIdentityRepository } from './IdentityRepository';
export { IdentityService } from './IdentityService';

export const identityService: IdentityService = new IdentityService(
  apiClient,
  new PreferencesIdentityRepository()
);
