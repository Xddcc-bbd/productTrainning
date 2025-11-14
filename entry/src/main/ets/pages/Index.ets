import router from '@ohos.router';

/**
 * 主页面 - 爱从游教师移动端
 */
@Entry
@Component
struct Index {
  build() {
    Column() {
      // 顶部标题
      Row() {
        Text('爱从游')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#000000')
      }
      .width('100%')
      .height(60)
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#FFFFFF')

      // 功能入口
      Column() {
        Text('评价与反馈功能')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#000000')
          .margin({ bottom: 24, top: 32 })

        // 作业批改入口
        Button('作业批改')
          .type(ButtonType.Capsule)
          .width('80%')
          .height(50)
          .fontSize(16)
          .backgroundColor('#1890FF')
          .margin({ bottom: 16 })
          .onClick(() => {
            router.pushUrl({
              url: 'pages/GradingPage'
            });
          })

        // 评分标准管理入口
        Button('评分标准管理')
          .type(ButtonType.Capsule)
          .width('80%')
          .height(50)
          .fontSize(16)
          .backgroundColor('#52C41A')
          .margin({ bottom: 16 })
          .onClick(() => {
            router.pushUrl({
              url: 'pages/GradingStandardPage',
              params: {
                taskId: 'task1'
              }
            });
          })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
  }
}