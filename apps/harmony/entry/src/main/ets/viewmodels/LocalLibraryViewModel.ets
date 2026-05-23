import { mockLocalFiles } from '../mocks';
import { TransferItemType } from '../models/CommonTypes';
import { LocalFileEntry } from '../models/LocalFileEntry';

export type LocalLibraryFilter = 'ALL' | TransferItemType;

export class LocalLibraryViewModel {
  searchKeyword: string = '';
  filter: LocalLibraryFilter = 'ALL';
  selectedIds: string[] = [];
  files: LocalFileEntry[] = mockLocalFiles;

  getFilteredFiles(): LocalFileEntry[] {
    return this.files.filter((file) => {
      var matchesKeyword = this.searchKeyword.length === 0 ||
        file.displayName.toLowerCase().includes(this.searchKeyword.toLowerCase());
      var matchesFilter = this.filter === 'ALL' || file.type === this.filter;
      return matchesKeyword && matchesFilter;
    });
  }

  isSelected(id: string): boolean {
    return this.selectedIds.includes(id);
  }

  toggleSelected(id: string): void {
    if (this.isSelected(id)) {
      this.selectedIds = this.selectedIds.filter((selectedId) => selectedId !== id);
      return;
    }
    this.selectedIds.push(id);
  }

  clearSelection(): void {
    this.selectedIds = [];
  }
}
