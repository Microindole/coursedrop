import { ApiClient } from '../ApiClient';

export interface RelayHealthProbe {
  ok: boolean;
  message: string;
  service: string;
  version: string;
  publicBaseUrl: string;
}

interface HealthResponse {
  status: string;
  service: string;
  time: string;
}

interface CapabilityResponse {
  service: string;
  version: string;
  publicBaseUrl: string;
}

export class RelayHealthService {
  private apiClient: ApiClient;

  constructor(apiClient: ApiClient) {
    this.apiClient = apiClient;
  }

  async probe(): Promise<RelayHealthProbe> {
    try {
      const healthText = await this.apiClient.getWithTimeout('/api/health', 3000);
      const health = JSON.parse(healthText) as HealthResponse;
      if (health.status !== 'UP') {
        return {
          ok: false,
          message: '中转源状态异常',
          service: health.service,
          version: '',
          publicBaseUrl: ''
        };
      }
      return await this.probeCapabilities(health.service);
    } catch (error) {
      return {
        ok: false,
        message: `中转源不可用：${String(error)}`,
        service: '',
        version: '',
        publicBaseUrl: ''
      };
    }
  }

  private async probeCapabilities(serviceName: string): Promise<RelayHealthProbe> {
    try {
      const capabilitiesText = await this.apiClient.getWithTimeout('/api/health/capabilities', 3000);
      const capabilities = JSON.parse(capabilitiesText) as CapabilityResponse;
      return {
        ok: true,
        message: '中转源连接正常',
        service: capabilities.service,
        version: capabilities.version,
        publicBaseUrl: capabilities.publicBaseUrl
      };
    } catch (_error) {
      return {
        ok: true,
        message: '中转源连接正常',
        service: serviceName,
        version: '',
        publicBaseUrl: ''
      };
    }
  }
}
