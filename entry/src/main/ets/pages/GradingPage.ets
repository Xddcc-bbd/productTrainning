// entry/src/main/ets/pages/GradingPage.ets
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

interface Submission {
  submissionId: number;
  studentId: string;
  studentName: string;
  submissionTime: string;
  contentUrl: string;
  status: string;
  score?: number;
  isTeacherRecommended?: boolean;
  textComment?: string;
}

@Entry
@Component
struct GradingPage {
  @State submissions: Submission[] = [
    {
      submissionId: 1,
      studentId: 'S001',
      studentName: '张三',
      submissionTime: '2024-01-10 14:30',
      contentUrl: '',
      status: '已提交',
      score: 85,
      isTeacherRecommended: false
    },
    {
      submissionId: 2,
      studentId: 'S002',
      studentName: '李四',
      submissionTime: '2024-01-11 09:15',
      contentUrl: '',
      status: '已提交',
      score: undefined,
      isTeacherRecommended: false
    }
  ];

  @State currentSubmission: Submission | null = null;
  @State showGradingPanel: boolean = false;
  @State score: number = 0;
  @State comment: string = '';
  @State useAIRecommendation: boolean = false;

  aboutToAppear() {
    const params = router.getParams() as Record<string, string>;
    if (params && params.assignmentId) {
      console.log('加载作业ID:', params.assignmentId);
    }
  }

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
        Text('作业批改')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
        Blank()
        Button('批量操作', { type: ButtonType.Normal })
          .fontSize(14)
          .onClick(() => {
            router.pushUrl({ url: 'pages/BatchFeedbackPage' });
          })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 10, bottom: 10 })
      .backgroundColor(Color.White)

      // 主要内容区域
      Row({ space: 0 }) {
        // 左侧提交列表
        Column({ space: 0 }) {
          Text('提交列表 (' + this.submissions.length + ')')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .padding(15)
            .backgroundColor('#FAFAFA')
            .width('100%')

          List({ space: 5 }) {
            ForEach(this.submissions, (submission: Submission) => {
              ListItem() {
                SubmissionListItem({
                  submission: submission,
                  onItemClick: (sub: Submission) => {
                    this.currentSubmission = sub;
                    this.score = sub.score || 0;
                    this.comment = sub.textComment || '';
                    this.showGradingPanel = true;
                  }
                })
              }
            }, (submission: Submission) => submission.submissionId.toString())
          }
          .layoutWeight(1)
        }
        .width('35%')
        .backgroundColor(Color.White)

        // 右侧批改面板
        Column({ space: 0 }) {
          if (this.showGradingPanel && this.currentSubmission) {
            this.buildGradingPanel()
          } else {
            this.buildEmptyState()
          }
        }
        .layoutWeight(1)
        .backgroundColor('#F8F9FA')
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }

  @Builder buildEmptyState() {
    Column({ space: 20 }) {
      Text('←')
        .fontSize(24)
        .fontColor(Color.Blue)
      Text('请选择要批改的作业')
        .fontSize(18)
        .fontColor(Color.Gray)
      Text('点击左侧列表中的学生提交开始批改')
        .fontSize(14)
        .fontColor('#999999')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder buildGradingPanel() {
    Column({ space: 15 }) {
      // 学生信息头
      Row({ space: 10 }) {
        Column({ space: 4 }) {
          Text(this.currentSubmission!.studentName)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
          Text('学号: ' + this.currentSubmission!.studentId)
            .fontSize(14)
            .fontColor(Color.Gray)
          Text('提交时间: ' + this.currentSubmission!.submissionTime)
            .fontSize(12)
            .fontColor(Color.Gray)
        }
        .layoutWeight(1)

        // 推荐标记
        if (this.currentSubmission!.isTeacherRecommended) {
          Text('⭐ 教师推荐')
            .fontSize(12)
            .fontColor('#FA8C16')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor('#FFF7E6')
            .borderRadius(10)
        }
      }
      .width('100%')
      .padding(15)
      .backgroundColor(Color.White)
      .borderRadius(10)

      // 作品展示区域
      Column({ space: 10 }) {
        Text('作品内容')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .textAlign(TextAlign.Start)

        // 作品预览
        Column({ space: 10 }) {
          Text('←')
            .fontSize(24)
            .fontColor(Color.Blue)
            .onClick(() => {
              router.back();
            })

          Row({ space: 10 }) {
            Button('查看完整作品', { type: ButtonType.Normal })
              .fontSize(14)
            Button('运行演示', { type: ButtonType.Normal })
              .fontSize(14)
              .backgroundColor(Color.Green)
          }
        }
        .padding(15)
        .backgroundColor(Color.White)
        .borderRadius(10)
      }

      // 评分区域
      Column({ space: 10 }) {
        Text('评分')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .textAlign(TextAlign.Start)

        Row({ space: 15 }) {
          Text('分数:')
            .fontSize(16)
          Slider({
            value: this.score,
            min: 0,
            max: 100,
            step: 1,
            style: SliderStyle.OutSet
          })
            .layoutWeight(1)
            .onChange((value: number) => {
              this.score = value;
            })
          Text(this.score.toString())
            .fontSize(16)
            .fontColor(Color.Blue)
            .width(40)
        }

        // AI评分建议
        Row({ space: 10 }) {
          Checkbox({ name: 'useAI', group: 'ai' })
            .select(this.useAIRecommendation)
            .onChange((value: boolean) => {
              this.useAIRecommendation = value;
              if (value) {
                this.score = 88; // 模拟AI评分
                this.comment = 'AI建议: 代码结构清晰，功能完整，建议优化变量命名。';
              }
            })
          Text('使用AI评分建议')
            .fontSize(14)
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
      }
      .padding(15)
      .backgroundColor(Color.White)
      .borderRadius(10)

      // 评语区域
      Column({ space: 10 }) {
        Text('评语')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .textAlign(TextAlign.Start)

        TextInput({ placeholder: '请输入评语...', text: this.comment })
          .width('100%')
          .height(100)
          .onChange((value: string) => {
            this.comment = value;
          })

        Row({ space: 10 }) {
          Button('语音评语', { type: ButtonType.Normal })
            .fontSize(14)
          Button('选择模板', { type: ButtonType.Normal })
            .fontSize(14)
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
      }
      .padding(15)
      .backgroundColor(Color.White)
      .borderRadius(10)

      // 操作按钮
      Row({ space: 15 }) {
        Button('保存评分', { type: ButtonType.Normal })
          .fontSize(16)
          .backgroundColor(Color.Blue)
          .onClick(() => {
            this.saveGrading();
          })
        Button('标记推荐', { type: ButtonType.Normal })
          .fontSize(16)
          .backgroundColor(this.currentSubmission!.isTeacherRecommended ? Color.Gray : Color.Orange)
          .onClick(() => {
            this.toggleRecommendation();
          })
        Button('下一个', { type: ButtonType.Normal })
          .fontSize(16)
          .onClick(() => {
            this.nextSubmission();
          })
      }
      .width('100%')
      .padding(15)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .padding(15)
  }

  private saveGrading() {
    // 调用后端保存评分接口
    console.log('保存评分:', {
      submissionId: this.currentSubmission!.submissionId,
      score: this.score,
      comment: this.comment
    });

    promptAction.showToast({
      message: '评分保存成功',
      duration: 2000
    });
  }

  private toggleRecommendation() {
    if (this.currentSubmission) {
      this.currentSubmission.isTeacherRecommended = !this.currentSubmission.isTeacherRecommended;
    }
  }

  private nextSubmission() {
    const currentIndex = this.submissions.findIndex(s => s.submissionId === this.currentSubmission!.submissionId);
    if (currentIndex < this.submissions.length - 1) {
      this.currentSubmission = this.submissions[currentIndex + 1];
      this.score = this.currentSubmission.score || 0;
      this.comment = this.currentSubmission.textComment || '';
    }
  }
}

@Component
struct SubmissionListItem {
  private submission: Submission = {} as Submission;
  private onItemClick: (submission: Submission) => void = () => {};

  build() {
    Row({ space: 10 }) {
      Column({ space: 4 }) {
        Text(this.submission.studentName)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        Text(this.submission.submissionTime)
          .fontSize(12)
          .fontColor(Color.Gray)
      }
      .layoutWeight(1)

      if (this.submission.score !== undefined) {
        Text(this.submission.score.toString())
          .fontSize(16)
          .fontColor(Color.Blue)
          .fontWeight(FontWeight.Bold)
      } else {
        Text('待批改')
          .fontSize(12)
          .fontColor(Color.Orange)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor('#FFF7E6')
          .borderRadius(10)
      }
    }
    .width('100%')
    .padding(12)
    .backgroundColor(this.submission.score !== undefined ? '#F8F9FA' : Color.White)
    .onClick(() => {
      this.onItemClick(this.submission);
    })
  }
}