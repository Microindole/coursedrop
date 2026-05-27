import pasteboard from '@ohos.pasteboard';

export interface ClipboardService {
  copyText(text: string): Promise<void>;
}

export class SystemClipboardService implements ClipboardService {
  async copyText(text: string): Promise<void> {
    if (text.length === 0) {
      throw new Error('复制内容为空');
    }
    const data = pasteboard.createPlainTextData(text);
    const systemPasteboard = pasteboard.getSystemPasteboard();
    await systemPasteboard.setData(data);
  }
}
