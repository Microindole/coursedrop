import { AppColors, AppRadius, AppSpacing, AppTypography } from '../../common/Theme';

export interface CdSelectOption {
  label: string;
  value: string;
}

@Component
export struct CdSelectField {
  label: string = '';
  placeholder: string = '';
  @Link selectedValue: string;
  options: CdSelectOption[] = [];
  onChange: (value: string) => void = () => {};

  private getSelectOptions(): SelectOption[] {
    return this.options.map(opt => {
      // 鸿蒙原生 SelectOption 结构为 { value: string, icon?: string | Resource }
      return { value: opt.label } as SelectOption;
    });
  }

  private getSelectedLabel(): string {
    const found = this.options.find(opt => opt.value === this.selectedValue);
    return found ? found.label : (this.placeholder || '请选择');
  }

  private getSelectedIndex(): number {
    return this.options.findIndex(opt => opt.value === this.selectedValue);
  }

  build() {
    Column({ space: AppSpacing.XS }) {
      // 标签说明
      if (this.label && this.label.length > 0) {
        Text(this.label)
          .fontSize(AppTypography.BODY_SMALL)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.TEXT)
      }

      // 下拉框选择容器
      Row() {
        Select(this.getSelectOptions())
          .selected(this.getSelectedIndex())
          .value(this.getSelectedLabel())
          .font({ size: AppTypography.BODY_SMALL, weight: FontWeight.Medium })
          .fontColor(AppColors.TEXT)
          .selectedOptionFont({ size: AppTypography.BODY_SMALL })
          .optionFont({ size: AppTypography.BODY_SMALL })
          .backgroundColor(Color.Transparent) // 使用外壳样式，透明原生背景
          .width('100%')
          .height('100%')
          .padding({ left: AppSpacing.MD, right: AppSpacing.MD })
          .onSelect((index: number, value?: string) => {
            if (index >= 0 && index < this.options.length) {
              const selectedVal = this.options[index].value;
              this.selectedValue = selectedVal;
              this.onChange(selectedVal);
            }
          })
      }
      .width('100%')
      .height(44)
      .backgroundColor(AppColors.SURFACE)
      .borderRadius(AppRadius.MD)
      .border({ width: 0.7, color: AppColors.BORDER })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ top: AppSpacing.XS, bottom: AppSpacing.XS })
  }
}
