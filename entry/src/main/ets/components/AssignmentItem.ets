// entry/src/main/ets/components/AssignmentItem.ets

import router from '@ohos.router';
import { Utils } from '../common/Utils';

interface Assignment {
  assignmentId: number;
  assignmentName: string;
  courseName: string;
  studentCount: number;
  submittedCount: number;
  startTime: string;
  endTime: string;
  status: string;
}

@Component
export struct AssignmentItem {
  private assignment: Assignment = {} as Assignment;
  private onGradingClick?: (assignment: Assignment) => void = () => {};

  build() {
    Column({ space: 8 }) {
      // 标题和状态
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
        Text(`提交率: ${Utils.calculateSubmissionRate(this.assignment.submittedCount, this.assignment.studentCount)}%`)
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
            if (this.onGradingClick) {
              this.onGradingClick(this.assignment);
            } else {
              router.pushUrl({
                url: 'pages/GradingPage',
                params: { assignmentId: this.assignment.assignmentId.toString() }
              });
            }
          })
        Button('查看统计', { type: ButtonType.Normal })
          .fontSize(14)
          .backgroundColor(Color.Gray)
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
    }
    .width('100%')
    .padding(15)
    .backgroundColor(Color.White)
    .borderRadius(10)
    .margin({ top: 5, bottom: 5 })
    .shadow({ radius: 5, color: '#1A000000', offsetX: 0, offsetY: 2 })
  }

  private getStatusColor(): ResourceColor {
    switch (this.assignment.status) {
      case '进行中': return '#1890FF';
      case '已截止': return '#FF4D4F';
      case '未开始': return '#52C41A';
      default: return '#999999';
    }
  }

  private getStatusBackgroundColor(): ResourceColor {
    switch (this.assignment.status) {
      case '进行中': return '#E6F7FF';
      case '已截止': return '#FFF2F0';
      case '未开始': return '#F6FFED';
      default: return '#F5F5F5';
    }
  }
}