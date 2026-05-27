import { AppColors, AppRadius, AppSpacing, AppTypography, AppShadows } from '../../common/Theme';
import { CdIconButton } from '../common/CdIconButton';

@Component
export struct CdLocalFileActionBar {
  @Prop isEditMode: boolean = false;
  @Link selectedIds: string[];
  @Prop isAllSelected: boolean = false;
  onShareSelected: () => void = () => {};
  onDeleteSelected: () => void = () => {};

  build() {
    Row() {
      if (this.isEditMode && this.selectedIds.length > 0) {
        Row() {
          Row({ space: AppSpacing.MD }) {
            Column({ space: 2 }) {
              Text(`已选择 ${this.selectedIds.length} 项`)
                .fontSize(AppTypography.BODY_SMALL)
                .fontWeight(FontWeight.Bold)
                .fontColor(AppColors.PRIMARY)
              
              Text(this.isAllSelected ? '已全选过滤到的项目' : '点击操作项批量处理')
                .fontSize(10)
                .fontColor(AppColors.TEXT_SECONDARY)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Row({ space: AppSpacing.SM }) {
              CdIconButton({
                icon: $r('app.media.cd_icon_share'),
                variant: 'tonal',
                onTap: () => {
                  this.onShareSelected();
                }
              })

              CdIconButton({
                icon: $r('app.media.cd_icon_trash'),
                variant: 'danger',
                onTap: () => {
                  this.onDeleteSelected();
                }
              })
            }
          }
          .width('100%')
          .padding({ left: AppSpacing.LG, right: AppSpacing.LG, top: AppSpacing.MD, bottom: AppSpacing.MD })
          .backgroundColor('#CCFFFFFF') // 半透明磨砂
          .borderRadius(AppRadius.XL)
          .shadow(AppShadows.FLOATING)
          .border({ width: 0.5, color: AppColors.BORDER })
        }
        .width('100%')
        .padding({ left: AppSpacing.XL, right: AppSpacing.XL, bottom: AppSpacing.XL })
        .transition({ translate: { y: 100 } })
      }
    }
  }
}
