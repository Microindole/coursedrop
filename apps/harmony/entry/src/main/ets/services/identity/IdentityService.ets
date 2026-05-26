import { ApiClient } from '../ApiClient';
import { DeviceFingerprintResponse, LocalIdentity } from './IdentityModels';
import { IdentityRepository } from './IdentityRepository';

export class IdentityService {
  private apiClient: ApiClient;
  private repository: IdentityRepository;

  constructor(apiClient: ApiClient, repository: IdentityRepository) {
    this.apiClient = apiClient;
    this.repository = repository;
  }

  getLocalIdentity(): LocalIdentity | undefined {
    return this.repository.get();
  }

  async registerCurrentDevice(): Promise<LocalIdentity> {
    const existing = this.repository.get();
    const fingerprint = existing === undefined ? this.createFingerprint() : existing.fingerprint;
    const deviceName = existing === undefined ? 'HarmonyOS 设备' : existing.deviceName;
    const body = JSON.stringify({
      fingerprint: fingerprint,
      deviceName: deviceName,
      platform: 'HarmonyOS'
    });
    const responseText = await this.apiClient.postJson('/api/identity/fingerprints', body);
    const response = JSON.parse(responseText) as DeviceFingerprintResponse;
    const identity: LocalIdentity = {
      fingerprint: response.fingerprint,
      fingerprintId: response.id,
      deviceName: response.deviceName,
      accountId: response.accountId === null ? '' : response.accountId
    };
    this.repository.save(identity);
    return identity;
  }

  async confirmWebLogin(loginCode: string): Promise<void> {
    const identity = this.repository.get();
    if (identity === undefined || identity.fingerprintId.length === 0) {
      throw new Error('请先注册本机身份');
    }
    const body = JSON.stringify({
      fingerprintId: identity.fingerprintId
    });
    await this.apiClient.postJson(`/api/auth/web-login/${loginCode}/confirm`, body);
  }

  private createFingerprint(): string {
    return `harmony-${Date.now()}-${Math.floor(Math.random() * 1000000)}`;
  }
}
