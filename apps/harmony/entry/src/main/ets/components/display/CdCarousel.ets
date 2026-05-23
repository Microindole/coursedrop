import { AppRadius } from '../../common/Theme';

@Component
export struct CdCarousel {
  images: Resource[] = [];
  height: number = 148;
  autoPlay: boolean = true;
  private controller: SwiperController = new SwiperController();

  build() {
    Swiper(this.controller) {
      ForEach(this.images, (image: Resource) => {
        Image(image)
          .width('100%')
          .height(this.height)
          .objectFit(ImageFit.Cover)
          .borderRadius(AppRadius.LG)
      }, (image: Resource) => JSON.stringify(image))
    }
    .width('100%')
    .height(this.height)
    .autoPlay(this.autoPlay)
    .indicator(true)
  }
}
