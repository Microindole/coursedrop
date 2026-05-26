import { ApiClient } from '../ApiClient';
import { RelayDownloadRequest, RelayDownloadResult, RelayUploadRequest, RelayUploadResponse } from './TransferModels';

export interface RelayTransferApi {
  uploadShareItem(request: RelayUploadRequest): Promise<RelayUploadResponse>;
  downloadShareItem(request: RelayDownloadRequest): Promise<RelayDownloadResult>;
}

export class HttpRelayTransferApi implements RelayTransferApi {
  private apiClient: ApiClient;

  constructor(apiClient: ApiClient) {
    this.apiClient = apiClient;
  }

  async uploadShareItem(request: RelayUploadRequest): Promise<RelayUploadResponse> {
    throw new Error(`文件上传客户端尚未接入 multipart：${request.shareId}, ${this.apiClient.getBaseUrl()}`);
  }

  async downloadShareItem(request: RelayDownloadRequest): Promise<RelayDownloadResult> {
    throw new Error(`文件下载保存尚未接入：${request.code}/${request.itemId}`);
  }
}
