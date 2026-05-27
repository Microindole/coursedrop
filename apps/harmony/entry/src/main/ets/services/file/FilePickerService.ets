import picker from '@ohos.file.picker';
import { TransferItemType } from '../../models/CommonTypes';
import { FileTypeResolver } from './FileTypeResolver';
import { PickedFile } from './FileModels';

export interface FilePickerService {
  pickFiles(typeHint?: TransferItemType): Promise<PickedFile[]>;
}

export class SystemFilePickerService implements FilePickerService {
  private typeResolver: FileTypeResolver = new FileTypeResolver();

  async pickFiles(typeHint?: TransferItemType): Promise<PickedFile[]> {
    const documentSelectOptions = new picker.DocumentSelectOptions();
    const documentViewPicker = new picker.DocumentViewPicker();
    const uris = await documentViewPicker.select(documentSelectOptions);
    const files: PickedFile[] = [];
    uris.forEach((uri: string) => {
      const displayName = this.resolveDisplayName(uri);
      const contentType = this.resolveContentType(displayName, typeHint);
      files.push({
        uri: uri,
        displayName: displayName,
        contentType: contentType,
        sizeBytes: 0,
        type: this.typeResolver.resolve(contentType, displayName)
      });
    });
    return files;
  }

  private resolveDisplayName(uri: string): string {
    const normalized = uri.split('?')[0];
    const parts = normalized.split('/');
    if (parts.length === 0) {
      return '未命名文件';
    }
    const name = decodeURIComponent(parts[parts.length - 1]);
    if (name.length === 0) {
      return '未命名文件';
    }
    return name;
  }

  private resolveContentType(displayName: string, typeHint?: TransferItemType): string {
    if (typeHint === 'IMAGE') {
      return 'image/*';
    }
    if (typeHint === 'TEXT') {
      return 'text/plain';
    }
    if (typeHint === 'LINK') {
      return 'text/uri-list';
    }
    const normalizedName = displayName.toLowerCase();
    if (normalizedName.endsWith('.png')) {
      return 'image/png';
    }
    if (normalizedName.endsWith('.jpg') || normalizedName.endsWith('.jpeg')) {
      return 'image/jpeg';
    }
    if (normalizedName.endsWith('.webp')) {
      return 'image/webp';
    }
    if (normalizedName.endsWith('.txt') || normalizedName.endsWith('.md')) {
      return 'text/plain';
    }
    if (normalizedName.endsWith('.pdf')) {
      return 'application/pdf';
    }
    return 'application/octet-stream';
  }
}
