import router from '@ohos.router';
import { AppColors, AppRadius, AppSize, AppSpacing, AppTypography } from '../common/Theme';
import {
  CdBanner,
  CdButton,
  CdIconButton,
  CdPanel,
  CdPagination,
  CdScrollContainer,
  CdSearchField,
  CdSegmentedControl,
  CdSectionHeader,
  CdTopBar
} from '../components/index';
import { LocalFileEntry } from '../models/LocalFileEntry';
import { LocalLibraryViewModel } from '../viewmodels/LocalLibraryViewModel';

@Component
export default struct LocalLibraryPage {
  showBack: boolean = true;
  private viewModel: LocalLibraryViewModel = new LocalLibraryViewModel();
  @State keyword: string = '';
  @State segmentIndex: number = 0;
  @State page: number = 1;
  @State revision: number = 0;

  private refreshView(): void {
    this.revision += 1;
    const totalPages = this.viewModel.getTotalPages();
    if (this.page > totalPages) {
      this.page = totalPages;
    }
  }

  private applyFilter(index: number): void {
    this.page = 1;
    if (index === 1) {
      this.viewModel.filter = 'FILE';
    } else if (index === 2) {
      this.viewModel.filter = 'IMAGE';
    } else if (index === 3) {
      this.viewModel.filter = 'TEXT';
    } else if (index === 4) {
      this.viewModel.filter = 'LINK';
    } else {
      this.viewModel.filter = 'ALL';
    }
    this.refreshView();
  }

  private syncSearch(): void {
    this.viewModel.searchKeyword = this.keyword;
    this.page = 1;
    this.refreshView();
  }

  private formatSize(sizeBytes: number): string {
    if (sizeBytes < 1024) {
      return `${sizeBytes} B`;
    }
    if (sizeBytes < 1024 * 1024) {
      return `${Math.round(sizeBytes / 1024)} KB`;
    }
    return `${Math.round(sizeBytes / 1024 / 1024)} MB`;
  }

  private typeText(file: LocalFileEntry): string {
    if (file.type === 'IMAGE') {
      return '图片';
    }
    if (file.type === 'TEXT') {
      return '文本';
    }
    if (file.type === 'LINK') {
      return '链接';
    }
    return '文件';
  }

  private typeIcon(file: LocalFileEntry): Resource {
    if (file.type === 'IMAGE') {
      return $r('app.media.cd_icon_image');
    }
    if (file.type === 'TEXT') {
      return $r('app.media.cd_icon_text');
    }
    if (file.type === 'LINK') {
      return $r('app.media.cd_icon_link');
    }
    return $r('app.media.cd_icon_file');
  }

  @Builder
  FileRow(file: LocalFileEntry) {
    CdPanel() {
      Row({ space: AppSpacing.MD }) {
        Stack() {
          Image(this.typeIcon(file))
            .width(AppSize.ICON_MD)
            .height(AppSize.ICON_MD)
            .fillColor(AppColors.PRIMARY_SELECTED)
        }
        .width(44)
        .height(44)
        .backgroundColor(AppColors.PRIMARY_SOFT)
        .borderRadius(AppRadius.MD)

        Column({ space: AppSpacing.XS }) {
          Text(file.displayName)
            .fontSize(AppTypography.BODY)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppColors.TEXT)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(`${this.typeText(file)} · ${this.formatSize(file.sizeBytes)} · ${file.encrypted ? '已加密' : '未加密'}`)
            .fontSize(AppTypography.CAPTION)
            .fontColor(AppColors.TEXT_SECONDARY)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        if (this.viewModel.isSelected(file.id)) {
          Image($r('app.media.cd_icon_done'))
            .width(AppSize.ICON_MD)
            .height(AppSize.ICON_MD)
            .fillColor(AppColors.SUCCESS)
        }
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        this.viewModel.toggleSelected(file.id);
        this.refreshView();
      })
    }
  }

  @Builder
  ActionPanel() {
    CdPanel() {
      Column({ space: AppSpacing.MD }) {
        Text('本地库只管理 CourseDrop 应用目录和索引')
          .fontSize(AppTypography.BODY_SMALL)
          .fontColor(AppColors.TEXT_SECONDARY)

        Row({ space: AppSpacing.SM }) {
          CdButton({
            label: '生成测试文件',
            variant: 'tonal',
            onTap: () => {
              this.viewModel.createDebugTextFile();
              this.refreshView();
            }
          })
          .layoutWeight(1)

          CdButton({
            label: '导入文件',
            onTap: () => {
              this.viewModel.importFiles('FILE').then(() => {
                this.refreshView();
              });
            }
          })
          .layoutWeight(1)
        }
        .width('100%')

        CdButton({
          label: '导入图片',
          variant: 'tonal',
          onTap: () => {
            this.viewModel.importFiles('IMAGE').then(() => {
              this.refreshView();
            });
          }
        })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  SelectionPanel() {
    if (this.viewModel.selectedIds.length > 0) {
      CdPanel() {
        Row({ space: AppSpacing.SM }) {
          Text(`已选择 ${this.viewModel.selectedIds.length} 项`)
            .fontSize(AppTypography.BODY_SMALL)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppColors.TEXT)
            .layoutWeight(1)

          CdIconButton({
            icon: $r('app.media.cd_icon_close'),
            onTap: () => {
              this.viewModel.clearSelection();
              this.refreshView();
            }
          })

          CdIconButton({
            icon: $r('app.media.cd_icon_share'),
            variant: 'tonal',
            onTap: () => {
              this.viewModel.shareSelected();
              this.refreshView();
            }
          })

          CdIconButton({
            icon: $r('app.media.cd_icon_trash'),
            variant: 'danger',
            onTap: () => {
              this.viewModel.deleteSelected();
              this.refreshView();
            }
          })
        }
        .width('100%')
      }
    }
  }

  @Builder
  FileList() {
    if (this.viewModel.getPagedFiles(this.page).length === 0) {
      CdPanel() {
        Column({ space: AppSpacing.SM }) {
          Image($r('app.media.cd_icon_library'))
            .width(36)
            .height(36)
            .fillColor(AppColors.TEXT_SECONDARY)
          Text('本地库暂无内容')
            .fontSize(AppTypography.BODY)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppColors.TEXT)
          Text('可以先生成测试文件，或者从系统文件选择器导入。')
            .fontSize(AppTypography.BODY_SMALL)
            .fontColor(AppColors.TEXT_SECONDARY)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .padding({ top: AppSpacing.LG, bottom: AppSpacing.LG })
      }
    } else {
      ForEach(this.viewModel.getPagedFiles(this.page), (file: LocalFileEntry) => {
        this.FileRow(file);
      }, (file: LocalFileEntry) => file.id)

      if (this.viewModel.getTotalPages() > 1) {
        CdPagination({
          totalPages: this.viewModel.getTotalPages(),
          currentPage: $page,
          onChange: (nextPage: number) => {
            this.page = nextPage;
            this.refreshView();
          }
        })
      }
    }
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      CdScrollContainer({ showScrollBar: true }) {
        if (this.revision < 0) {
          Blank()
        }

        CdTopBar({
          title: '本地库',
          subtitle: `${this.viewModel.getTotalCount()} 项内容`,
          leadingText: this.showBack ? '返回' : '',
          onLeadingTap: () => {
            router.back();
          }
        })

        CdBanner({
          title: this.viewModel.getVisibleActionText(),
          description: '文件先进入本机索引，再由分享页创建公网链接或后续局域网传输。',
          tone: 'info'
        })

        this.ActionPanel();

        CdSearchField({
          placeholder: '搜索本地库',
          value: $keyword,
          onChangeValue: (value: string) => {
            this.keyword = value;
            this.syncSearch();
          },
          onSubmit: () => {
            this.syncSearch();
          }
        })

        CdSegmentedControl({
          options: ['全部', '文件', '图片', '文本', '链接'],
          selectedIndex: $segmentIndex,
          onChange: (index: number) => {
            this.applyFilter(index);
          }
        })

        this.SelectionPanel();

        CdSectionHeader({
          title: '文件',
          actionText: this.viewModel.getFilteredFiles().length > 0 ? '全选' : '',
          onAction: () => {
            this.viewModel.selectFiltered();
            this.refreshView();
          }
        })

        this.FileList();
      }
    }
    .width('100%')
    .height('100%')
  }
}
