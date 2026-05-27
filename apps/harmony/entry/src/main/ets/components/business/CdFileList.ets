import { AppSpacing } from '../../common/Theme';
import { TransferItemType } from '../../models/CommonTypes';
import { LocalFileEntry } from '../../models/LocalFileEntry';
import { TransferItem } from '../../models/TransferItem';
import { CdFileItem, CdFileTone } from '../display/CdFileItem';

@Component
export struct CdFileList {
  @Prop localFiles: LocalFileEntry[] = [];
  @Prop transferItems: TransferItem[] = [];
  @Prop selectedIds: string[] = [];
  @Prop source: 'local' | 'transfer' = 'local';
  onLocalTap: (id: string) => void = (_id: string) => {};
  onTransferTap: (id: string) => void = (_id: string) => {};

  private fileTone(type: TransferItemType): CdFileTone {
    if (type === 'IMAGE') {
      return 'image';
    }
    if (type === 'LINK') {
      return 'link';
    }
    if (type === 'TEXT') {
      return 'text';
    }
    return 'file';
  }

  private selectedPrefix(id: string): string {
    return this.selectedIds.includes(id) ? '已选择 · ' : '';
  }

  build() {
    Column({ space: AppSpacing.SM }) {
      if (this.source === 'local') {
        ForEach(this.localFiles, (file: LocalFileEntry) => {
          CdFileItem({
            name: file.displayName,
            meta: `${this.selectedPrefix(file.id)}${file.shareCount} 次分享 · ${file.remoteCached ? '公网副本有效' : '仅本地'}`,
            tone: this.fileTone(file.type),
            onTap: () => {
              this.onLocalTap(file.id);
            }
          })
        }, (file: LocalFileEntry) => file.id)
      } else {
        ForEach(this.transferItems, (item: TransferItem) => {
          CdFileItem({
            name: item.displayName,
            meta: `${item.contentType} · ${item.sizeBytes} bytes`,
            tone: this.fileTone(item.type),
            onTap: () => {
              this.onTransferTap(item.id);
            }
          })
        }, (item: TransferItem) => item.id)
      }
    }
    .width('100%')
  }
}
