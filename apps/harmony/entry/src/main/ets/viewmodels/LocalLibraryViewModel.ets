import { TransferItemType } from '../models/CommonTypes';
import { LocalFileEntry } from '../models/LocalFileEntry';
import { localLibraryService } from '../services/local';

export type LocalLibraryFilter = 'ALL' | TransferItemType;

export class LocalLibraryViewModel {
  searchKeyword: string = '';
  filter: LocalLibraryFilter = 'ALL';
  selectedIds: string[] = [];
  files: LocalFileEntry[] = localLibraryService.listFiles();
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
    localLibraryService.markShared(this.selectedIds);
    this.files = localLibraryService.listFiles();
    this.lastActionText = `已重新分享 ${this.selectedIds.length} 项`;
  }

  deleteSelected(): void {
    const selectedCount = this.selectedIds.length;
    localLibraryService.removeFiles(this.selectedIds);
    this.files = localLibraryService.listFiles();
    this.selectedIds = [];
    this.lastActionText = `已删除 ${selectedCount} 项`;
  }
}
