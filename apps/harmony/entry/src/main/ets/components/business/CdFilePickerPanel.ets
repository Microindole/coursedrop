import { AppColors, AppRadius, AppSpacing, AppTypography } from '../../common/Theme';
import { CdActionTile } from '../actions/CdActionTile';

@Component
export struct CdFilePickerPanel {
  onPickFile: () => void = () => {};
  onPickImage: () => void = () => {};
  onSendText: () => void = () => {};
  onSendLink: () => void = () => {};

  build() {
    Column({ space: AppSpacing.MD }) {
      Text('添加内容')
        .fontSize(AppTypography.TITLE)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppColors.TEXT)
        .width('100%')

      Grid() {
        GridItem() {
          CdActionTile({
            title: '文件',
            subtitle: '文档/压缩包',
            mark: 'FILE',
            onTap: () => {
              this.onPickFile();
            }
          })
        }

        GridItem() {
          CdActionTile({
            title: '图片',
            subtitle: '相册或截图',
            mark: 'IMG',
            onTap: () => {
              this.onPickImage();
            }
          })
        }

        GridItem() {
          CdActionTile({
            title: '文本',
            subtitle: '片段/说明',
            mark: 'TXT',
            onTap: () => {
              this.onSendText();
            }
          })
        }

        GridItem() {
          CdActionTile({
            title: '链接',
            subtitle: '网页/资料',
            mark: 'URL',
            onTap: () => {
              this.onSendLink();
            }
          })
        }
      }
      .columnsTemplate('1fr 1fr')
      .rowsTemplate('1fr 1fr')
      .columnsGap(AppSpacing.SM)
      .rowsGap(AppSpacing.SM)
      .width('100%')
      .height(200)
    }
    .width('100%')
    .padding(AppSpacing.MD)
    .backgroundColor(AppColors.SURFACE)
    .borderRadius(AppRadius.LG)
  }
}
