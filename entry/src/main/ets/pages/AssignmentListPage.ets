// entry/src/main/ets/pages/AssignmentListPage.ets
import router from '@ohos.router';

interface Assignment {
  assignmentId: number;
  assignmentName: string;
  courseId: number;
  courseName: string;
  studentCount: number;
  submittedCount: number;
  startTime: string;
  endTime: string;
  status: string; // '未开始' | '进行中' | '已截止'
}

@Entry
@Component
struct AssignmentListPage {
  @State assignments: Assignment[] = [
    {
      assignmentId: 1,
      assignmentName: '积木编程任务1',
      courseId: 101,
      courseName: 'Java程序设计',
      studentCount: 45,
      submittedCount: 38,
      startTime: '2024-01-01',
      endTime: '2024-01-15',
      status: '进行中'
    },
    {
      assignmentId: 2,
      assignmentName: '数据结构实验',
      courseId: 102,
      courseName: '数据结构',
      studentCount: 50,
      submittedCount: 45,
      startTime: '2024-01-10',
      endTime: '2024-01-25',
      status: '进行中'
    }
  ];

  build() {
    Column({ space: 0 }) {
      // 标题栏
      Row({ space: 10 }) {
        Text('←')  // 使用箭头符号
          .fontSize(24)
          .fontColor(Color.Blue)
          .onClick(() => {
            router.back();
          })
        Text('作业列表')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 10, bottom: 10 })
      .backgroundColor(Color.White)

      // 筛选栏
      Row({ space: 15 }) {
        Text('全部')
          .fontSize(16)
          .fontColor(Color.Blue)
          .border({ width: 1, color: Color.Blue })
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .borderRadius(20)
        Text('待批改')
          .fontSize(16)
          .fontColor(Color.Gray)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .borderRadius(20)
          .backgroundColor('#F0F0F0')
        Text('已批改')
          .fontSize(16)
          .fontColor(Color.Gray)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .borderRadius(20)
          .backgroundColor('#F0F0F0')
      }
      .width('100%')
      .padding(15)
      .justifyContent(FlexAlign.Start)

      // 作业列表
      List({ space: 10 }) {
        ForEach(this.assignments, (assignment: Assignment) => {
          ListItem() {
            AssignmentItem({ assignment: assignment })
          }
        }, (assignment: Assignment) => assignment.assignmentId.toString())
      }
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}

@Component
struct AssignmentItem {
  private assignment: Assignment = {} as Assignment;

  build() {
    Column({ space: 8 }) {
      Row({ space: 10 }) {
        Column({ space: 4 }) {
          Text(this.assignment.assignmentName)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Start)
          Text(this.assignment.courseName)
            .fontSize(14)
            .fontColor(Color.Gray)
        }
        .layoutWeight(1)

        // 状态标签
        Text(this.assignment.status)
          .fontSize(12)
          .fontColor(this.getStatusColor())
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor(this.getStatusBackgroundColor())
          .borderRadius(10)
      }
      .width('100%')

      // 进度信息
      Row({ space: 15 }) {
        Text(`学生: ${this.assignment.submittedCount}/${this.assignment.studentCount}`)
          .fontSize(14)
          .fontColor(Color.Gray)
        Text(`提交率: ${Math.round((this.assignment.submittedCount / this.assignment.studentCount) * 100)}%`)
          .fontSize(14)
          .fontColor(Color.Blue)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)

      // 时间信息
      Text(`截止时间: ${this.assignment.endTime}`)
        .fontSize(12)
        .fontColor(Color.Gray)
        .width('100%')
        .textAlign(TextAlign.Start)

      // 操作按钮
      Row({ space: 10 }) {
        Button('批改作业', { type: ButtonType.Normal })
          .fontSize(14)
          .backgroundColor(Color.Blue)
          .onClick(() => {
            router.pushUrl({
              url: 'pages/GradingPage',
              params: { assignmentId: this.assignment.assignmentId.toString() }
            });
          })
        Button('查看统计', { type: ButtonType.Normal })
          .fontSize(14)
          .backgroundColor(Color.Gray)
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
    }
    .width('90%')
    .padding(15)
    .backgroundColor(Color.White)
    .borderRadius(10)
    .margin({ left: 20, right: 20, top: 5, bottom: 5 })
    .shadow({ radius: 5, color: '#1A000000', offsetX: 0, offsetY: 2 })
  }

  private getStatusColor(): ResourceColor {
    switch (this.assignment.status) {
      case '进行中': return '#1890FF';
      case '已截止': return '#FF4D4F';
      default: return '#52C41A';
    }
  }

  private getStatusBackgroundColor(): ResourceColor {
    switch (this.assignment.status) {
      case '进行中': return '#E6F7FF';
      case '已截止': return '#FFF2F0';
      default: return '#F6FFED';
    }
  }
}