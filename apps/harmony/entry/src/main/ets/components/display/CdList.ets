import { AppSpacing } from '../../common/Theme';

@Component
export struct CdList {
  space: number = AppSpacing.SM;
  @BuilderParam content: () => void = this.defaultContent;

  @Builder
  defaultContent() {
  }

  build() {
    List({ space: this.space }) {
      this.content()
    }
    .width('100%')
    .scrollBar(BarState.Off)
  }
}
