import { ApiClient } from '../ApiClient';

export interface CreateRelayShareResponse {
  id: string;
  code: string;
  downloadUrl: string;
  status: string;
  downloadPolicy: string;
  expiresAt: string;
  createdAt: string;
}

export class RelayShareApi {
  private apiClient: ApiClient;

  constructor(apiClient: ApiClient) {
    this.apiClient = apiClient;
  }

  async createShare(
    expireHours: number,
    downloadPolicy: string,
    ownerIdentityId: string,
    ownerIdentityType: string
  ): Promise<CreateRelayShareResponse> {
    let body = '';
    if (ownerIdentityId.length === 0) {
      body = JSON.stringify({
        expireHours: expireHours,
        downloadPolicy: downloadPolicy,
        ownerIdentityType: ownerIdentityType
      });
    } else {
      body = JSON.stringify({
        expireHours: expireHours,
        downloadPolicy: downloadPolicy,
        ownerIdentityId: ownerIdentityId,
        ownerIdentityType: ownerIdentityType
      });
    }
    const responseText = await this.apiClient.postJson('/api/shares', body);
    const response = JSON.parse(responseText) as CreateRelayShareResponse;
    if (response.downloadUrl.startsWith('/')) {
      response.downloadUrl = `${this.apiClient.getBaseUrl()}${response.downloadUrl}`;
    }
    return response;
  }
}
