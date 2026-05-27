import { AppColors, AppSpacing, AppTypography } from '../../common/Theme';
import { CdButton } from '../common/CdButton';
import { CdPanel } from '../common/CdPanel';

@Component
export struct CdLocalLibraryActions {
  @Prop isEditMode: boolean = false;
  onImportFile: () => void = () => {};
  onImportMedia: () => void = () => {};
  onCreateDebug: () => void = () => {};

  build() {
    CdPanel() {
      Column({ space: AppSpacing.MD }) {
        Row() {
          Text('管理应用专属目录与传输索引')
            .fontSize(AppTypography.BODY_SMALL)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppColors.TEXT_SECONDARY)
            .layoutWeight(1)
          
          if (!this.isEditMode) {
            Text('生成测试项')
              .fontSize(AppTypography.BODY_SMALL)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppColors.PRIMARY)
              .onClick(() => {
                this.onCreateDebug();
              })
          }
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)

        if (!this.isEditMode) {
          Row({ space: AppSpacing.MD }) {
            CdButton({
              label: '导入系统文件',
              variant: 'tonal',
              onTap: () => {
                this.onImportFile();
              }
            })
            .layoutWeight(1)

            CdButton({
              label: '导入图片/媒体',
              onTap: () => {
                this.onImportMedia();
              }
            })
            .layoutWeight(1)
          }
          .width('100%')
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }
}
