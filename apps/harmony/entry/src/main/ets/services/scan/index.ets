import { identityService } from '../identity';
import { QrPayloadParser } from './QrPayloadParser';
import { ScanDispatchService } from './ScanDispatchService';
import { CameraScanService } from './CameraScanService';

export type { QrPayload, QrPayloadType } from './QrPayloadParser';
export { QrPayloadParser } from './QrPayloadParser';
export type { ScanDispatchResult } from './ScanDispatchService';
export { ScanDispatchService } from './ScanDispatchService';
export type { CameraScanResult } from './CameraScanService';
export { CameraScanService } from './CameraScanService';

export const qrPayloadParser = new QrPayloadParser();
export const scanDispatchService = new ScanDispatchService(qrPayloadParser, identityService);
export const cameraScanService = new CameraScanService();
