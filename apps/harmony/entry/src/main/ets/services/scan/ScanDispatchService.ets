import { IdentityService } from '../identity';
import { QrPayloadParser, QrPayload } from './QrPayloadParser';

export interface ScanDispatchResult {
  success: boolean;
  message: string;
  payload: QrPayload;
}

export class ScanDispatchService {
  private parser: QrPayloadParser;
  private identityService: IdentityService;

  constructor(parser: QrPayloadParser, identityService: IdentityService) {
    this.parser = parser;
    this.identityService = identityService;
  }

  async dispatch(rawText: string): Promise<ScanDispatchResult> {
    const payload = this.parser.parse(rawText);
    if (payload.type === 'WEB_LOGIN') {
      await this.identityService.confirmWebLogin(payload.code);
      return {
        success: true,
        message: '网页登录已确认',
        payload: payload
      };
    }
    if (payload.type === 'SHARE') {
      return {
        success: true,
        message: `识别到分享码：${payload.code}`,
        payload: payload
      };
    }
    return {
      success: false,
      message: '无法识别二维码内容',
      payload: payload
    };
  }
}
