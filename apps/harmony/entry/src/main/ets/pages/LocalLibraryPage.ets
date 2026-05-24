import {
    CdCheckboxRow,
    CdFileActionBar,
    CdFileList,
    CdPagination,
    CdScrollContainer,
    CdSearchField,
    CdSectionHeader,
    CdSegmentedControl,
    CdTopBar
} from '../components/index';
import { LocalLibraryFilter, LocalLibraryViewModel } from '../viewmodels/LocalLibraryViewModel';

@Component
export default struct LocalLibraryPage {
    private viewModel: LocalLibraryViewModel = new LocalLibraryViewModel();
    showBack: boolean = false;
    @State keyword: string = '';
    @State selectedSegment: number = 0;
    @State checkedFile: boolean = false;
    @State revision: number = 0;
    @State currentPage: number = 1;

    private refreshView(): void {
        this.revision += 1;
    }

    private updateFilter(index: number): void {
        this.selectedSegment = index;
        const filters: LocalLibraryFilter[] = ['ALL', 'FILE', 'IMAGE', 'TEXT', 'LINK'];
        this.viewModel.filter = filters[index];
        this.checkedFile = false;
        this.currentPage = 1;
        this.viewModel.clearSelection();
        this.refreshView();
    }

    build() {
        Stack({ alignContent: Alignment.TopStart }) {
            CdScrollContainer() {
                Column() {
                    if (this.revision < 0) {
                        Blank()
                    }

                    CdTopBar({
                        title: '本地库',
                        subtitle: '按分享状态管理本地内容',
                        leadingText: this.showBack ? '返回' : '',
                        onLeadingTap: () => {}
                    })

                    CdSearchField({
                        placeholder: '搜索文件、图片、文本或链接',
                        value: $keyword,
                        onSubmit: () => {
                            this.viewModel.searchKeyword = this.keyword;
                            this.refreshView();
                        }
                    })

                    CdSegmentedControl({
                        options: ['全部', '文件', '图片', '文本', '链接'],
                        selectedIndex: $selectedSegment,
                        onChange: (index: number) => {
                            this.updateFilter(index);
                        }
                    })

                    CdSectionHeader({ title: '本地内容' })

                    CdFileList({
                        source: 'local',
                        localFiles: this.viewModel.getPagedFiles(this.currentPage),
                        selectedIds: this.viewModel.selectedIds,
                        onLocalTap: (id: string) => {
                            this.viewModel.toggleSelected(id);
                            this.checkedFile = this.viewModel.selectedIds.length === this.viewModel.getFilteredFiles().length;
                            this.refreshView();
                        }
                    })

                    CdPagination({
                        currentPage: $currentPage,
                        totalPages: this.viewModel.getTotalPages(),
                        onChange: (_page: number) => {
                            this.refreshView();
                        }
                    })

                    CdCheckboxRow({
                        title: '选择当前筛选结果',
                        description: '后续接批量操作时替换为多选列表',
                        checked: $checkedFile,
                        onChange: (checked: boolean) => {
                            if (checked) {
                                this.viewModel.selectFiltered();
                            } else {
                                this.viewModel.clearSelection();
                            }
                            this.refreshView();
                        }
                    })

                    CdFileActionBar({
                        selectedCount: this.viewModel.selectedIds.length,
                        onShare: () => {
                            this.viewModel.shareSelected();
                            this.refreshView();
                        },
                        onDelete: () => {
                            this.viewModel.deleteSelected();
                            this.checkedFile = false;
                            this.refreshView();
                        },
                        onClear: () => {
                            this.viewModel.clearSelection();
                            this.checkedFile = false;
                            this.refreshView();
                        }
                    })
                }
                .width('100%')
            }
        }
        .width('100%')
        .height('100%')
    }
}
