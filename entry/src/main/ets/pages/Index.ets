// entry/src/main/ets/pages/Index.ets
import router from '@ohos.router';

@Entry
@Component
struct Index {
  @State message: string = '评价与反馈系统';

  build() {
    Column({ space: 0 }) {
      // 标题栏
      Text(this.message)
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.Black)
        .padding(20)
        .width('100%')
        .textAlign(TextAlign.Center)
        .backgroundColor('#F5F5F5')

      // 功能导航卡片
      Column({ space: 15 }) {
        NavigationCard({ title: '作业批改', desc: '查看和批改学生作业', icon: '📝', page: 'pages/GradingManagementPage' })
        NavigationCard({ title: '推荐优秀学生', desc: '标记和推荐表现优秀的学生', icon: '⭐', page: 'pages/StudentRecommendationPage' })
        NavigationCard({ title: '评分标准', desc: '管理作业评分标准', icon: '📊', page: 'pages/GradingStandardPage' })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 20, bottom: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}

@Component
struct NavigationCard {
  @Prop title: string = '';
  @Prop desc: string = '';
  @Prop icon: string = '';
  @Prop page: string = '';
  @Prop params?: Object;

  build() {
    Column({ space: 10 }) {
      Text(this.icon)
        .fontSize(32)
      Text(this.title)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
      Text(this.desc)
        .fontSize(13)
        .fontColor(Color.Gray)
        .textAlign(TextAlign.Center)
    }
    .width('90%')
    .padding(15)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 3 })
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