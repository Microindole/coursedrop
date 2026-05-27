import { SystemClipboardService } from './ClipboardService';
import type { ClipboardService } from './ClipboardService';

export type { ClipboardService } from './ClipboardService';
export { SystemClipboardService } from './ClipboardService';

export const clipboardService: ClipboardService = new SystemClipboardService();
