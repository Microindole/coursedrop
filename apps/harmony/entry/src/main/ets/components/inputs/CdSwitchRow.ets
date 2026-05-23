import { AppColors, AppSize, AppSpacing, AppTypography } from '../../common/Theme';

@Component
export struct CdSwitchRow {
  title: string = '';
  description: string = '';
  @Link isOn: boolean;
  enabled: boolean = true;

  build() {
    Row() {
      Column({ space: AppSpacing.XS }) {
        Text(this.title)
          .fontSize(AppTypography.BODY)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppColors.TEXT)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        if (this.description.length > 0) {
          Text(this.description)
            .fontSize(AppTypography.CAPTION)
            .fontColor(AppColors.TEXT_SECONDARY)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Toggle({ type: ToggleType.Switch, isOn: this.isOn })
        .selectedColor(AppColors.PRIMARY)
        .enabled(this.enabled)
        .onChange((value: boolean) => {
          this.isOn = value;
        })
    }
    .width('100%')
    .minHeight(AppSize.LIST_ROW_HEIGHT)
    .alignItems(VerticalAlign.Center)
    .opacity(this.enabled ? 1 : 0.45)
  }
}
