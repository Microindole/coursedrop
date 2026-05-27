import { identityService } from '../identity';
import { QrPayloadParser } from './QrPayloadParser';
import { ScanDispatchService } from './ScanDispatchService';

export type { QrPayload, QrPayloadType } from './QrPayloadParser';
export { QrPayloadParser } from './QrPayloadParser';
export type { ScanDispatchResult } from './ScanDispatchService';
export { ScanDispatchService } from './ScanDispatchService';

export const qrPayloadParser = new QrPayloadParser();
export const scanDispatchService = new ScanDispatchService(qrPayloadParser, identityService);
