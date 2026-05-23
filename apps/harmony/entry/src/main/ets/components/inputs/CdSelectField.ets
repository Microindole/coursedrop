import { AppColors, AppRadius, AppSpacing, AppTypography } from '../../common/Theme';

export interface CdSelectOption {
  label: string;
  value: string;
}

@Component
export struct CdSelectField {
  label: string = '';
  placeholder: string = '请选择';
  options: CdSelectOption[] = [];
  @Link selectedValue: string;
  @State expanded: boolean = false;

  private selectedLabel(): string {
    for (let index = 0; index < this.options.length; index++) {
      if (this.options[index].value === this.selectedValue) {
        return this.options[index].label;
      }
    }
    return this.placeholder;
  }

  build() {
    Column({ space: AppSpacing.XS }) {
      if (this.label.length > 0) {
        Text(this.label)
          .fontSize(AppTypography.CAPTION)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppColors.TEXT_SECONDARY)
      }

      Row() {
        Text(this.selectedLabel())
          .fontSize(AppTypography.BODY)
          .fontColor(this.selectedValue.length > 0 ? AppColors.TEXT : AppColors.TEXT_SECONDARY)
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(this.expanded ? '^' : 'v')
          .fontSize(AppTypography.BODY)
          .fontColor(AppColors.TEXT_SECONDARY)
      }
      .width('100%')
      .padding({ top: AppSpacing.SM, bottom: AppSpacing.SM })
      .onClick(() => {
        this.expanded = !this.expanded;
      })

      Divider()
        .strokeWidth(1)
        .color(AppColors.BORDER_STRONG)

      if (this.expanded) {
        Column() {
          ForEach(this.options, (option: CdSelectOption) => {
            Row() {
              Text(option.label)
                .fontSize(AppTypography.BODY_SMALL)
                .fontColor(AppColors.TEXT)
                .layoutWeight(1)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })

              if (option.value === this.selectedValue) {
                Text('OK')
                  .fontSize(AppTypography.CAPTION)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(AppColors.PRIMARY_SELECTED)
              }
            }
            .width('100%')
            .padding({
              left: AppSpacing.MD,
              right: AppSpacing.MD,
              top: AppSpacing.SM,
              bottom: AppSpacing.SM
            })
            .onClick(() => {
              this.selectedValue = option.value;
              this.expanded = false;
            })
          }, (option: CdSelectOption) => option.value)
        }
        .width('100%')
        .backgroundColor(AppColors.SURFACE)
        .borderRadius(AppRadius.MD)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
