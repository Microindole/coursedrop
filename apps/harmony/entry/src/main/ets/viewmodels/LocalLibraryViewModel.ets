import { TransferItemType } from '../models/CommonTypes';
import { LocalFileEntry } from '../models/LocalFileEntry';
import { localLibraryService } from '../services/local';
import { localFileImportWorkflow } from '../services/file';
import { shareService } from '../services/share';

export type LocalLibraryFilter = 'ALL' | TransferItemType;

export class LocalLibraryViewModel {
  searchKeyword: string = '';
  filter: LocalLibraryFilter = 'ALL';
  selectedIds: string[] = [];
  files: LocalFileEntry[] = localLibraryService.listFiles();
  lastActionText: string = '';
  pageSize: number = 5;

  reload(): void {
    this.files = localLibraryService.listFiles();
  }

  getVisibleActionText(): string {
    if (this.lastActionText.length > 0) {
      return this.lastActionText;
    }
    return '本地库只管理 CourseDrop 索引内容';
  }

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

  getTotalCount(): number {
    return this.getFilteredFiles().length;
  }

  async importFiles(type?: TransferItemType): Promise<void> {
    const result = await localFileImportWorkflow.importFiles(type);
    this.reload();
    this.lastActionText = result.message;
  }

  createDebugTextFile(): void {
    this.lastActionText = '正在生成测试文件...';
    const result = localFileImportWorkflow.createDebugTextFile();
    this.reload();
    this.lastActionText = result.message;
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
    let attachedCount = 0;
    const session = shareService.getCurrentSession();
    for (let index = 0; index < this.selectedIds.length; index += 1) {
      const result = shareService.attachLocalFile(session.id, this.selectedIds[index]);
      if (result.success) {
        attachedCount += 1;
      }
    }
    localLibraryService.markShared(this.selectedIds);
    this.files = localLibraryService.listFiles();
    this.selectedIds = [];
    this.lastActionText = attachedCount > 0 ? `已加入分享草稿 ${attachedCount} 项` : '所选内容已在分享草稿中';
  }

  deleteSelected(): void {
    const selectedCount = this.selectedIds.length;
    localLibraryService.removeFiles(this.selectedIds);
    this.files = localLibraryService.listFiles();
    this.selectedIds = [];
    this.lastActionText = `已删除 ${selectedCount} 项`;
  }
}
