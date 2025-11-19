// entry/src/main/ets/pages/Index.ets
import router from '@ohos.router';

@Entry
@Component
struct Index {
  @State message: string = '评价与反馈系统';

  build() {
    Column({ space: 20 }) {
      Text(this.message)
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.Blue)

      // 功能导航卡片
      NavigationCard({ title: '作业批改', desc: '查看和批改学生作业', icon: '📝', page: 'pages/GradingManagementPage' })
      NavigationCard({ title: '详细评分', desc: '详细评分和评语', icon: '✍️', page: 'pages/DetailedGradingPage' })
      NavigationCard({ title: '批量反馈', desc: '批量处理相同类型作业', icon: '📋', page: 'pages/BatchFeedbackPage' })
      NavigationCard({ title: '推荐优秀学生', desc: '标记和推荐表现优秀的学生', icon: '⭐', page: 'pages/StudentRecommendationPage' })
      NavigationCard({ title: '评分标准', desc: '管理作业评分标准', icon: '📊', page: 'pages/GradingStandardPage' })

    }
    .width('100%')
    .height('100%')
    .padding(20)
    .backgroundColor('#F5F5F5')
  }
}

@Component
struct NavigationCard {
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
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
      Text(this.desc)
        .fontSize(14)
        .fontColor(Color.Gray)
        .textAlign(TextAlign.Center)
    }
    .width('90%')
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