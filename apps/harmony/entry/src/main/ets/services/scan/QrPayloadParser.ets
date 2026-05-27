export type QrPayloadType = 'WEB_LOGIN' | 'SHARE' | 'UNKNOWN';

export interface QrPayload {
  type: QrPayloadType;
  rawText: string;
  code: string;
}

export class QrPayloadParser {
  parse(rawText: string): QrPayload {
    const normalized = rawText.trim();
    if (normalized.length === 0) {
      return this.unknown(rawText);
    }
    const loginCode = this.extractAfter(normalized, '/m/login/');
    if (loginCode.length > 0) {
      return {
        type: 'WEB_LOGIN',
        rawText: rawText,
        code: loginCode
      };
    }
    const shareCode = this.extractAfter(normalized, '/s/');
    if (shareCode.length > 0) {
      return {
        type: 'SHARE',
        rawText: rawText,
        code: shareCode
      };
    }
    if (normalized.startsWith('login:')) {
      return {
        type: 'WEB_LOGIN',
        rawText: rawText,
        code: normalized.replace('login:', '').trim()
      };
    }
    if (normalized.startsWith('share:')) {
      return {
        type: 'SHARE',
        rawText: rawText,
        code: normalized.replace('share:', '').trim()
      };
    }
    return this.unknown(rawText);
  }

  private extractAfter(text: string, marker: string): string {
    const markerIndex = text.indexOf(marker);
    if (markerIndex < 0) {
      return '';
    }
    const start = markerIndex + marker.length;
    let end = text.length;
    const queryIndex = text.indexOf('?', start);
    const hashIndex = text.indexOf('#', start);
    if (queryIndex >= 0 && queryIndex < end) {
      end = queryIndex;
    }
    if (hashIndex >= 0 && hashIndex < end) {
      end = hashIndex;
    }
    return text.substring(start, end).trim();
  }

  private unknown(rawText: string): QrPayload {
    return {
      type: 'UNKNOWN',
      rawText: rawText,
      code: ''
    };
  }
}
