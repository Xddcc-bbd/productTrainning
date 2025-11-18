// entry/src/main/ets/components/StudentRecommendationItem.ets

interface Student {
  studentId: string;
  studentName: string;
  className: string;
  totalScore: number;
  ranking: number;
  isRecommended: boolean;
  recommendationReason?: string;
}

@Component
export struct StudentRecommendationItem {
  private student: Student = {} as Student;
  private onToggleRecommend: (student: Student) => void = () => {};

  @State showReasonInput: boolean = false;
  @State reason: string = '';

  build() {
    Column({ space: 12 }) {
      // 学生基本信息
      Row({ space: 10 }) {
        Column({ space: 4 }) {
          Text(this.student.studentName)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
          Row({ space: 15 }) {
            Text('学号: ' + this.student.studentId)
              .fontSize(12)
              .fontColor(Color.Gray)
            Text(this.student.className)
              .fontSize(12)
              .fontColor(Color.Gray)
          }
        }
        .layoutWeight(1)

        // 成绩信息
        Column({ space: 2 }) {
          Text('总分: ' + this.student.totalScore)
            .fontSize(16)
            .fontColor(Color.Blue)
          Text('排名: 第' + this.student.ranking + '名')
            .fontSize(12)
            .fontColor(Color.Gray)
        }
        .alignItems(HorizontalAlign.End)
      }

      // 推荐状态和原因
      if (this.student.isRecommended) {
        Column({ space: 8 }) {
          Row({ space: 10 }) {
            Text('⭐ 已推荐')
              .fontSize(14)
              .fontColor(Color.Orange)
            Button('取消推荐', { type: ButtonType.Normal })
              .fontSize(12)
              .backgroundColor(Color.Gray)
              .onClick(() => {
                this.onToggleRecommend(this.student);
              })
          }

          if (this.student.recommendationReason) {
            Text('推荐理由: ' + this.student.recommendationReason)
              .fontSize(14)
              .fontColor(Color.Gray)
              .width('100%')
              .textAlign(TextAlign.Start)
          }
        }
        .width('100%')
        .padding(10)
        .backgroundColor('#FFF7E6')
        .borderRadius(8)
      } else {
        Row({ space: 10 }) {
          Button('推荐该学生', { type: ButtonType.Normal })
            .fontSize(14)
            .backgroundColor(Color.Green)
            .onClick(() => {
              this.showReasonInput = true;
            })
        }
        .width('100%')
      }

      // 推荐理由输入
      if (this.showReasonInput) {
        Column({ space: 10 }) {
          TextInput({ placeholder: '请输入推荐理由...', text: this.reason })
            .width('100%')
            .height(60)
            .onChange((value: string) => {
              this.reason = value;
            })

          Row({ space: 10 }) {
            Button('确认推荐', { type: ButtonType.Normal })
              .fontSize(14)
              .backgroundColor(Color.Blue)
              .enabled(this.reason.length > 0)
              .onClick(() => {
                this.student.recommendationReason = this.reason;
                this.onToggleRecommend(this.student);
                this.showReasonInput = false;
                this.reason = '';
              })
            Button('取消', { type: ButtonType.Normal })
              .fontSize(14)
              .backgroundColor(Color.Gray)
              .onClick(() => {
                this.showReasonInput = false;
                this.reason = '';
              })
          }
        }
        .width('100%')
        .padding(10)
        .backgroundColor('#F0F8FF')
        .borderRadius(8)
      }
    }
    .width('100%')
    .padding(15)
    .backgroundColor(Color.White)
    .borderRadius(10)
    .margin({ top: 5, bottom: 5 })
    .shadow({ radius: 5, color: '#1A000000', offsetX: 0, offsetY: 2 })
  }
}