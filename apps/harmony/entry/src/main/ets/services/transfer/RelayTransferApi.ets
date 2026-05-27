import http from '@ohos.net.http';
import { fileIo, fileUri } from '@kit.CoreFileKit';
import { ApiClient } from '../ApiClient';
import { FileSystemService } from '../file';
import { RelayDownloadRequest, RelayDownloadResult, RelayUploadRequest, RelayUploadResponse } from './TransferModels';

export interface RelayTransferApi {
  uploadShareItem(request: RelayUploadRequest): Promise<RelayUploadResponse>;
  downloadShareItem(request: RelayDownloadRequest): Promise<RelayDownloadResult>;
}

export class HttpRelayTransferApi implements RelayTransferApi {
  private apiClient: ApiClient;
  private fileSystemService: FileSystemService;

  constructor(apiClient: ApiClient, fileSystemService: FileSystemService) {
    this.apiClient = apiClient;
    this.fileSystemService = fileSystemService;
  }

  async uploadShareItem(request: RelayUploadRequest): Promise<RelayUploadResponse> {
    if (!this.apiClient.hasBaseUrl()) {
      throw new Error('未配置中转源');
    }
    const boundary = `----CourseDrop${Date.now()}`;
    const body = this.buildMultipartBody(request, boundary);
    const httpRequest = http.createHttp();
    const url = `${this.apiClient.getBaseUrl()}/api/shares/${request.shareId}/items`;
    try {
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.POST,
        header: new MultipartHeader(boundary),
        extraData: body,
        connectTimeout: 15000,
        readTimeout: 60000
      });
      if (response.responseCode < 200 || response.responseCode >= 300) {
        throw new Error(`HTTP ${response.responseCode}`);
      }
      return JSON.parse(String(response.result)) as RelayUploadResponse;
    } finally {
      httpRequest.destroy();
    }
  }

  async downloadShareItem(request: RelayDownloadRequest): Promise<RelayDownloadResult> {
    if (!this.apiClient.hasBaseUrl()) {
      throw new Error('未配置中转源');
    }
    const url = `${this.apiClient.getBaseUrl()}/api/shares/${request.code}/items/${request.itemId}/download`;
    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        expectDataType: http.HttpDataType.ARRAY_BUFFER,
        connectTimeout: 15000,
        readTimeout: 60000
      });
      if (response.responseCode < 200 || response.responseCode >= 300) {
        throw new Error(`HTTP ${response.responseCode}`);
      }

      const displayName = `downloaded-${request.itemId}`;
      const contentType = 'application/octet-stream';

      const buffer = response.result as ArrayBuffer;
      const sizeBytes = buffer.byteLength;

      this.fileSystemService.ensureDirectory(request.targetDirectory);
      const targetPath = `${request.targetDirectory}/${Date.now()}-${displayName}`;

      const file = fileIo.openSync(targetPath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE);
      try {
        fileIo.writeSync(file.fd, buffer);
      } finally {
        fileIo.closeSync(file.fd);
      }

      return {
        localUri: fileUri.getUriFromPath(targetPath),
        displayName: displayName,
        sizeBytes: sizeBytes,
        contentType: contentType
      };
    } finally {
      httpRequest.destroy();
    }
  }

  private buildMultipartBody(request: RelayUploadRequest, boundary: string): ArrayBuffer {
    const fileData = this.fileSystemService.readAll(request.localUri);
    const fields = this.buildFieldParts(request, boundary);
    const fileHeader = this.toUtf8(
      `--${boundary}\r\n` +
      `Content-Disposition: form-data; name="file"; filename="${request.displayName}"\r\n` +
      `Content-Type: ${request.contentType}\r\n\r\n`
    );
    const lineBreak = this.toUtf8('\r\n');
    const end = this.toUtf8(`--${boundary}--\r\n`);
    return this.concatBuffers(fields, fileHeader, fileData, lineBreak, end);
  }

  private buildFieldParts(request: RelayUploadRequest, boundary: string): ArrayBuffer {
    let text = '';
    text += this.fieldPart(boundary, 'encrypted', request.encrypted ? 'true' : 'false');
    if (request.sha256 !== undefined) {
      text += this.fieldPart(boundary, 'sha256', request.sha256);
    }
    if (request.encryptionAlgorithm !== undefined) {
      text += this.fieldPart(boundary, 'encryptionAlgorithm', request.encryptionAlgorithm);
    }
    if (request.kdfAlgorithm !== undefined) {
      text += this.fieldPart(boundary, 'kdfAlgorithm', request.kdfAlgorithm);
    }
    if (request.kdfSalt !== undefined) {
      text += this.fieldPart(boundary, 'kdfSalt', request.kdfSalt);
    }
    if (request.nonce !== undefined) {
      text += this.fieldPart(boundary, 'nonce', request.nonce);
    }
    if (request.plainSizeBytes !== undefined) {
      text += this.fieldPart(boundary, 'plainSizeBytes', `${request.plainSizeBytes}`);
    }
    return this.toUtf8(text);
  }

  private fieldPart(boundary: string, name: string, value: string): string {
    return `--${boundary}\r\nContent-Disposition: form-data; name="${name}"\r\n\r\n${value}\r\n`;
  }

  private toUtf8(text: string): ArrayBuffer {
    const encoded = new Uint8Array(text.length);
    for (let index = 0; index < text.length; index += 1) {
      encoded[index] = text.charCodeAt(index);
    }
    return encoded.buffer;
  }

  private concatBuffers(
    first: ArrayBuffer,
    second: ArrayBuffer,
    third: ArrayBuffer,
    fourth: ArrayBuffer,
    fifth: ArrayBuffer
  ): ArrayBuffer {
    const totalLength = first.byteLength + second.byteLength + third.byteLength + fourth.byteLength + fifth.byteLength;
    const result = new Uint8Array(totalLength);
    let offset = 0;
    offset = this.copyBuffer(result, first, offset);
    offset = this.copyBuffer(result, second, offset);
    offset = this.copyBuffer(result, third, offset);
    offset = this.copyBuffer(result, fourth, offset);
    this.copyBuffer(result, fifth, offset);
    return result.buffer;
  }

  private copyBuffer(target: Uint8Array, source: ArrayBuffer, offset: number): number {
    target.set(new Uint8Array(source), offset);
    return offset + source.byteLength;
  }
}

class MultipartHeader {
  contentType: string;

  constructor(boundary: string) {
    this.contentType = `multipart/form-data; boundary=${boundary}`;
  }
}
