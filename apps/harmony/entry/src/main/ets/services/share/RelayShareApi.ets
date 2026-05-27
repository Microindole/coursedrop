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

export interface RelayShareItemResponse {
  id: string;
  shareId: string;
  displayName: string;
  contentType: string;
  sizeBytes: number;
  encrypted: boolean;
  expiresAt: string;
}

export interface RelayShareDownloadResponse {
  code: string;
  status: string;
  downloadPolicy: string;
  downloadAuthRequired: boolean;
  expiresAt: string;
  items: RelayShareItemResponse[];
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

  async revokeShare(shareId: string): Promise<void> {
    await this.apiClient.delete(`/api/shares/${shareId}`);
  }

  async extendShare(shareId: string, expireHours: number): Promise<CreateRelayShareResponse> {
    const body = JSON.stringify({
      expireHours: expireHours
    });
    const responseText = await this.apiClient.postJson(`/api/shares/${shareId}/expiry`, body);
    const response = JSON.parse(responseText) as CreateRelayShareResponse;
    if (response.downloadUrl.startsWith('/')) {
      response.downloadUrl = `${this.apiClient.getBaseUrl()}${response.downloadUrl}`;
    }
    return response;
  }

  async getShareByCode(code: string): Promise<RelayShareDownloadResponse> {
    const responseText = await this.apiClient.get(`/api/shares/${code}`);
    return JSON.parse(responseText) as RelayShareDownloadResponse;
  }
}
