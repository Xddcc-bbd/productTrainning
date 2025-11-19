// entry/src/main/ets/pages/AssignmentListPage.ets

@Entry
@Component
struct AssignmentListPage {
  @State message: string = 'Assignment List Page';

  build() {
    Column() {
      Text(this.message)
        .fontSize(24)
        .margin({ top: 100 })
      
      Button('返回')
        .onClick(() => {
          // 返回逻辑
        })
        .margin({ top: 20 })
    }
    .width('100%')
    .height('100%')
  }
}