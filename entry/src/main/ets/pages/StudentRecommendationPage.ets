// entry/src/main/ets/pages/StudentRecommendationPage.ets
import router from '@ohos.router';

interface Student {
  studentId: string;
  studentName: string;
  className: string;
  totalScore: number;
  ranking: number;
  isRecommended: boolean;
  recommendationReason?: string;
}

@Entry
@Component
struct StudentRecommendationPage {
  @State students: Student[] = [
    {
      studentId: 'S001',
      studentName: '张三',
      className: '计算机1班',
      totalScore: 95,
      ranking: 1,
      isRecommended: true,
      recommendationReason: '代码质量高，学习态度认真'
    },
    {
      studentId: 'S002',
      studentName: '李四',
      className: '计算机1班',
      totalScore: 92,
      ranking: 2,
      isRecommended: false
    },
    {
      studentId: 'S003',
      studentName: '王五',
      className: '计算机2班',
      totalScore: 88,
      ranking: 3,
      isRecommended: true,
      recommendationReason: '创新能力强，项目完成出色'
    }
  ];
  @State filter: string = 'all'; // 'all', 'recommended', 'notRecommended'

  build() {
    Column({ space: 0 }) {
      // 标题栏
      Row({ space: 10 }) {
        Text('←')
          .fontSize(24)
          .fontColor(Color.Blue)
          .onClick(() => {
            router.back();
          })
        Text('推荐优秀学生')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .padding({
        left: 20,
        right: 20,
        top: 10,
        bottom: 10
      })
      .backgroundColor(Color.White)

      // 筛选栏
      Row({ space: 15 }) {
        Text('全部')
          .fontSize(14)
          .fontColor(this.filter === 'all' ? Color.White : Color.Blue)
          .padding({
            left: 12,
            right: 12,
            top: 6,
            bottom: 6
          })
          .backgroundColor(this.filter === 'all' ? Color.Blue : '#F0F0F0')
          .borderRadius(20)
          .onClick(() => {
            this.filter = 'all';
          })

        Text('已推荐')
          .fontSize(14)
          .fontColor(this.filter === 'recommended' ? Color.White : Color.Green)
          .padding({
            left: 12,
            right: 12,
            top: 6,
            bottom: 6
          })
          .backgroundColor(this.filter === 'recommended' ? Color.Green : '#F0F0F0')
          .borderRadius(20)
          .onClick(() => {
            this.filter = 'recommended';
          })

        Text('未推荐')
          .fontSize(14)
          .fontColor(this.filter === 'notRecommended' ? Color.White : Color.Gray)
          .padding({
            left: 12,
            right: 12,
            top: 6,
            bottom: 6
          })
          .backgroundColor(this.filter === 'notRecommended' ? Color.Gray : '#F0F0F0')
          .borderRadius(20)
          .onClick(() => {
            this.filter = 'notRecommended';
          })
      }
      .width('100%')
      .padding(15)
      .justifyContent(FlexAlign.Start)

      // 学生列表
      List({ space: 10 }) {
        ForEach(this.getFilteredStudents(), (student: Student) => {
          ListItem() {
            StudentRecommendationItem({
              student: student,
              onToggleRecommend: (s: Student): void => this.toggleRecommendation(s)
            })
          }
        })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  private getFilteredStudents(): Student[] {
    switch (this.filter) {
      case 'recommended':
        return this.students.filter(s => s.isRecommended);
      case 'notRecommended':
        return this.students.filter(s => !s.isRecommended);
      default:
        return this.students;
    }
  }

  private toggleRecommendation(student: Student) {
    student.isRecommended = !student.isRecommended;

    if (student.isRecommended && !student.recommendationReason) {
      student.recommendationReason = '表现优秀，特此推荐';
    }
  }
}

@Component
struct StudentRecommendationItem {
  private student: Student = {} as Student;
  private onToggleRecommend: (student: Student) => void = () => {
  };
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
    .width('90%')
    .padding(15)
    .backgroundColor(Color.White)
    .borderRadius(10)
    .margin({
      left: 20,
      right: 20,
      top: 5,
      bottom: 5
    })
    .shadow({
      radius: 5,
      color: '#1A000000',
      offsetX: 0,
      offsetY: 2
    })
  }
}