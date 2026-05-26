import { TransferItemType } from '../../models/CommonTypes';

export class FileTypeResolver {
  resolve(contentType: string, displayName: string): TransferItemType {
    const normalizedContentType = contentType.toLowerCase();
    const normalizedName = displayName.toLowerCase();
    if (normalizedContentType.startsWith('image/')) {
      return 'IMAGE';
    }
    if (normalizedContentType.startsWith('text/')) {
      return 'TEXT';
    }
    if (normalizedContentType === 'text/uri-list' || normalizedName.endsWith('.url')) {
      return 'LINK';
    }
    return 'FILE';
  }
}
