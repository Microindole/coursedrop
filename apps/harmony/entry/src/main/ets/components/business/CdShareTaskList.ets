import { AppColors, AppSpacing, AppTypography } from '../../common/Theme';
import { TransferTask } from '../../models/TransferTask';
import { CdPanel } from '../common/CdPanel';
import { CdButton } from '../common/CdButton';

@Component
export struct CdShareTaskList {
  tasks: TransferTask[] = [];
  onGetItemName: (itemId: string) => string = () => '';
  onRetry: (itemId: string) => void = () => {};

  private taskText(task: TransferTask): string {
    if (task.status === 'RUNNING') return '正在上传';
    if (task.status === 'COMPLETED') return '已完成';
    if (task.status === 'FAILED') return '上传失败';
    if (task.status === 'CANCELED') return '已取消';
    return '待上传';
  }

  build() {
    if (this.tasks.length > 0) {
      CdPanel() {
        Column() {
          ForEach(this.tasks, (task: TransferTask, index: number) => {
            Column({ space: AppSpacing.SM }) {
              Row() {
                Text(this.onGetItemName(task.itemId))
                  .fontSize(AppTypography.BODY_SMALL)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(AppColors.TEXT)
                  .layoutWeight(1)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                
                Text(`${task.progress}%`)
                  .fontSize(AppTypography.BODY_SMALL)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(AppColors.PRIMARY)
              }
              .width('100%')

              Row({ space: AppSpacing.SM }) {
                Text(this.taskText(task))
                  .fontSize(AppTypography.CAPTION)
                  .fontColor(AppColors.TEXT_SECONDARY)
                
                Text(`·`)
                  .fontSize(AppTypography.CAPTION)
                  .fontColor(AppColors.TEXT_SECONDARY)

                Text(task.networkMode)
                  .fontSize(AppTypography.CAPTION)
                  .fontColor(AppColors.TEXT_SECONDARY)

                if (task.errorMessage !== undefined && task.errorMessage.length > 0) {
                  Text(`· ${task.errorMessage}`)
                    .fontSize(AppTypography.CAPTION)
                    .fontColor(AppColors.DANGER)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .layoutWeight(1)
                }
              }
              .width('100%')

              Progress({ value: task.progress, total: 100, type: ProgressType.Linear })
                .width('100%')
                .color(task.status === 'FAILED' ? AppColors.DANGER : AppColors.ACCENT)
                .backgroundColor(AppColors.SURFACE_MUTED)
                .height(6)

              if (task.status === 'FAILED') {
                CdButton({
                  label: '重试上传',
                  variant: 'tonal',
                  onTap: () => {
                    this.onRetry(task.itemId);
                  }
                })
              }
            }
            .width('100%')
            .padding({ top: AppSpacing.MD, bottom: AppSpacing.MD })

            if (index < this.tasks.length - 1) {
              Divider()
                .color(AppColors.BORDER)
                .strokeWidth(0.5)
            }
          }, (task: TransferTask) => task.id)
        }
        .width('100%')
      }
    }
  }
}
