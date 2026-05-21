import { AppConfig } from '../common/AppConfig';

export class ApiClient {
  private baseUrl: string = AppConfig.DEFAULT_SERVER_URL;

  setBaseUrl(baseUrl: string): void {
    this.baseUrl = baseUrl.replace(/\/$/, '');
  }

  getBaseUrl(): string {
    return this.baseUrl;
  }
}

export const apiClient = new ApiClient();

