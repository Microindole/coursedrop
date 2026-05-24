import { AppColors } from '../../common/Theme';

@Component
export struct CdBottomTabs {
  @Link currentIndex: number;
  private tabsController: TabsController = new TabsController();
  @BuilderParam homeContent: () => void = this.defaultContent;
  @BuilderParam shareContent: () => void = this.defaultContent;
  @BuilderParam libraryContent: () => void = this.defaultContent;
  @BuilderParam deviceContent: () => void = this.defaultContent;
  @BuilderParam settingsContent: () => void = this.defaultContent;

  @Builder
  defaultContent() {
  }

  @Builder
  tabBuilder(index: number, icon: Resource) {
    Column() {
      Image(icon)
        .width(this.currentIndex === index ? 28 : 24)
        .height(this.currentIndex === index ? 28 : 24)
        .fillColor(this.currentIndex === index ? AppColors.PRIMARY_SELECTED : AppColors.TAB_NORMAL)
        .opacity(this.currentIndex === index ? 1 : 0.68)
        .animation({ duration: 160, curve: Curve.EaseOut })
    }
    .justifyContent(FlexAlign.Center)
    .height(56)
    .width('100%')
    .backgroundColor(AppColors.BACKGROUND)
    .onClick(() => {
      this.currentIndex = index;
      this.tabsController.changeIndex(index);
    })
  }

  build() {
    Tabs({
      barPosition: BarPosition.End,
      controller: this.tabsController
    }) {
      TabContent() {
        this.homeContent()
      }
      .backgroundColor(AppColors.BACKGROUND)
      .tabBar(this.tabBuilder(0, $r('app.media.cd_icon_home')))

      TabContent() {
        this.shareContent()
      }
      .backgroundColor(AppColors.BACKGROUND)
      .tabBar(this.tabBuilder(1, $r('app.media.cd_icon_share')))

      TabContent() {
        this.libraryContent()
      }
      .backgroundColor(AppColors.BACKGROUND)
      .tabBar(this.tabBuilder(2, $r('app.media.cd_icon_library')))

      TabContent() {
        this.deviceContent()
      }
      .backgroundColor(AppColors.BACKGROUND)
      .tabBar(this.tabBuilder(3, $r('app.media.cd_icon_devices')))

      TabContent() {
        this.settingsContent()
      }
      .backgroundColor(AppColors.BACKGROUND)
      .tabBar(this.tabBuilder(4, $r('app.media.cd_icon_settings')))
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColors.BACKGROUND)
    .barHeight(64)
    .barMode(BarMode.Fixed)
    .onChange((index: number) => {
      this.currentIndex = index;
    })
  }
}
