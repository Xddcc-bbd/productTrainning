// entry/src/main/ets/components/NavigationCard.ets

import router from '@ohos.router';

@Component
export struct NavigationCard {
  private title: string = '';
  private desc: string = '';
  private icon: string = '';
  private page: string = '';
  private params?: Object;

  build() {
    Column({ space: 10 }) {
      Text(this.icon)
        .fontSize(40)
      Text(this.title)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Center)
      Text(this.desc)
        .fontSize(14)
        .fontColor(Color.Gray)
        .textAlign(TextAlign.Center)
        .maxLines(2)
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(15)
    .shadow({ radius: 10, color: '#1A000000', offsetX: 0, offsetY: 4 })
    .onClick(() => {
      if (this.params) {
        router.pushUrl({
          url: this.page,
          params: this.params
        });
      } else {
        router.pushUrl({ url: this.page });
      }
    })
  }
}