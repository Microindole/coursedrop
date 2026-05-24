import { mockLocalFiles } from '../mocks';
import { TransferItemType } from '../models/CommonTypes';
import { LocalFileEntry } from '../models/LocalFileEntry';

export type LocalLibraryFilter = 'ALL' | TransferItemType;

export class LocalLibraryViewModel {
  searchKeyword: string = '';
  filter: LocalLibraryFilter = 'ALL';
  selectedIds: string[] = [];
  files: LocalFileEntry[] = mockLocalFiles.slice();
  lastActionText: string = '';
  pageSize: number = 4;

  getFilteredFiles(): LocalFileEntry[] {
    return this.files.filter((file) => {
      let matchesKeyword = this.searchKeyword.length === 0 ||
        file.displayName.toLowerCase().includes(this.searchKeyword.toLowerCase());
      let matchesFilter = this.filter === 'ALL' || file.type === this.filter;
      return matchesKeyword && matchesFilter;
    });
  }

  isSelected(id: string): boolean {
    return this.selectedIds.includes(id);
  }

  getTotalPages(): number {
    const totalItems = this.getFilteredFiles().length;
    if (totalItems === 0) {
      return 1;
    }
    return Math.ceil(totalItems / this.pageSize);
  }

  getPagedFiles(page: number): LocalFileEntry[] {
    const safePage = Math.min(Math.max(page, 1), this.getTotalPages());
    const startIndex = (safePage - 1) * this.pageSize;
    return this.getFilteredFiles().slice(startIndex, startIndex + this.pageSize);
  }

  toggleSelected(id: string): void {
    if (this.isSelected(id)) {
      this.selectedIds = this.selectedIds.filter((selectedId) => selectedId !== id);
      return;
    }
    this.selectedIds.push(id);
  }

  selectFiltered(): void {
    this.selectedIds = this.getFilteredFiles().map((file) => file.id);
    this.lastActionText = `已选择 ${this.selectedIds.length} 项`;
  }

  clearSelection(): void {
    this.selectedIds = [];
    this.lastActionText = '已清空选择';
  }

  shareSelected(): void {
    this.files = this.files.map((file) => {
      if (!this.selectedIds.includes(file.id)) {
        return file;
      }
      file.shareCount = file.shareCount + 1;
      file.remoteCached = true;
      file.lastSharedAt = '2026-05-24T12:00:00+08:00';
      return file;
    });
    this.lastActionText = `已重新分享 ${this.selectedIds.length} 项`;
  }

  deleteSelected(): void {
    const selectedCount = this.selectedIds.length;
    this.files = this.files.filter((file) => !this.selectedIds.includes(file.id));
    this.selectedIds = [];
    this.lastActionText = `已删除 ${selectedCount} 项`;
  }
}
