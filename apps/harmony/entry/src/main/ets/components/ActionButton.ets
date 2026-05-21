import { AppColors } from '../common/Theme';

@Component
export struct ActionButton {
  label: string = '';
  primary: boolean = false;
  onTap: () => void = () => {};

  build() {
    Button(this.label)
      .width('100%')
      .height(48)
      .fontSize(16)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.primary ? Color.White : AppColors.PRIMARY)
      .backgroundColor(this.primary ? AppColors.PRIMARY : '#EEF4FF')
      .borderRadius(12)
      .onClick(() => {
        this.onTap();
      })
  }
}

