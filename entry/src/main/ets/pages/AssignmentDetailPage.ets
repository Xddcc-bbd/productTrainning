import { Assignment, Annotation, AnnotationType, Comment, CommentType, GradingStandard ,GradingItem} from '../models/GradingModels';
import { GradingService, AIGradingResult } from '../utils/GradingService';
import router from '@ohos.router';
import { promptAction } from '@kit.ArkUI';

/**
 * 作业批改详情页面
 */
@Entry
@Component
struct AssignmentDetailPage {
  @State assignment: Assignment | null = null;
  @State gradingStandard: GradingStandard | null = null;
  @State annotations: Annotation[] = [];
  @State comment: string = '';
  @State score: number = 0;
  @State aiScore: number = 0;
  @State aiComment: string = '';
  @State showAIGrading: boolean = false;
  @State isRecording: boolean = false;
  @State showAnnotationDialog: boolean = false;
  @State newAnnotationText: string = '';
  private assignmentId: string = '';
  private gradingService: GradingService = GradingService.getInstance();

  aboutToAppear() {
    const params = router.getParams() as Record<string, string | number | boolean>;
    if (params && params['assignmentId']) {
      this.assignmentId = params['assignmentId'] as string;
      this.loadAssignmentDetail();
    }
  }

  /**
   * 加载作业详情
   */
  async loadAssignmentDetail() {
    // 加载作业信息
    const assignments = await this.gradingService.getAssignments('task1');
    this.assignment = assignments.find(a => a.id === this.assignmentId) || null;

    if (this.assignment) {
      // 加载评分标准
      this.gradingStandard = await this.gradingService.getGradingStandard(this.assignment.gradingStandardId);
      this.score = this.assignment.score;
    }
  }

  /**
   * 获取AI评分和评语
   */
  async loadAIGrading() {
    if (!this.assignment || !this.gradingStandard) {
      return;
    }

    this.showAIGrading = true;
    const aiGrading = await this.gradingService.getAIGrading(this.assignment.id, this.gradingStandard.id);
    this.aiScore = aiGrading.score;
    this.aiComment = aiGrading.comment;
  }

  /**
   * 使用AI评分
   */
  useAIScore() {
    this.score = this.aiScore;
    promptAction.showToast({ message: '已使用AI评分' });
  }

  /**
   * 使用AI评语
   */
  useAIComment() {
    this.comment = this.aiComment;
    promptAction.showToast({ message: '已使用AI评语' });
  }

  /**
   * 添加文字批注
   */
  async addTextAnnotation() {
    if (!this.assignment) {
      return;
    }

    // 使用自定义对话框输入批注内容
    this.showAnnotationDialog = true;
    this.newAnnotationText = '';
  }

  /**
   * 保存文字批注
   */
  async saveTextAnnotation() {
    if (!this.assignment || !this.newAnnotationText.trim()) {
      return;
    }

    const annotation: Annotation = {
      id: `ann_${Date.now()}`,
      assignmentId: this.assignment.id,
      type: AnnotationType.TEXT,
      content: this.newAnnotationText,
      audioUrl: '',
      createTime: new Date().toLocaleString()
    };

    const success = await this.gradingService.addAnnotation(annotation);
    if (success) {
      this.annotations.push(annotation);
      this.showAnnotationDialog = false;
      this.newAnnotationText = '';
      promptAction.showToast({ message: '批注已添加' });
    } else {
      promptAction.showToast({ message: '添加批注失败，请重试' });
    }
  }

  /**
   * 添加语音评语
   */
  startVoiceRecording() {
    this.isRecording = !this.isRecording;
    if (this.isRecording) {
      promptAction.showToast({ message: '开始录音...' });
      // 实际应该调用录音API
    } else {
      promptAction.showToast({ message: '录音结束' });
      // 实际应该停止录音并保存
    }
  }

  /**
   * 保存评分
   */
  async saveGrading() {
    if (!this.assignment) {
      return;
    }

    const success = await this.gradingService.submitGrading(
      this.assignment.id,
      this.score,
      this.comment
    );

    if (success) {
      promptAction.showToast({ message: '评分已保存' });
      router.back();
    } else {
      promptAction.showToast({ message: '保存失败，请重试' });
    }
  }

  /**
   * 标记为教师推荐
   */
  async toggleRecommended() {
    if (!this.assignment) {
      return;
    }

    const newStatus = !this.assignment.isRecommended;
    const success = await this.gradingService.markAsRecommended(this.assignment.id, newStatus);

    if (success) {
      this.assignment.isRecommended = newStatus;
      promptAction.showToast({
        message: newStatus ? '已标记为教师推荐' : '已取消教师推荐'
      });
    }
  }

  /**
   * 进入评分标准定义页面
   */
  navigateToGradingStandard() {
    if (!this.assignment) {
      return;
    }
    router.pushUrl({
      url: 'pages/GradingStandardPage',
      params: {
        standardId: this.assignment.gradingStandardId,
        taskId: this.assignment.taskId
      }
    });
  }

  build() {
    Stack() {
      if (this.assignment) {
        // 主要内容
        Column() {
          // 顶部工具栏
          Row() {
            Text('←')
              .fontSize(24)
              .fontColor('#000000')
              .onClick(() => {
                router.back();
              })

            Text('作业批改')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#000000')
              .layoutWeight(1)
              .margin({ left: 12 })

            Button('保存')
              .type(ButtonType.Normal)
              .fontSize(14)
              .onClick(() => {
                this.saveGrading();
              })
          }
          .width('100%')
          .height(56)
          .padding({ left: 16, right: 16 })
          .backgroundColor('#FFFFFF')

          Scroll() {
            Column() {
              // 学生信息卡片
              this.buildStudentInfoCard()

              // 积木作品预览
              this.buildWorkPreview()

              // 评分标准
              this.buildGradingStandardCard()

              // 评分区域
              this.buildScoringSection()

              // AI评分和评语
              this.buildAIGradingSection()

              // 批注区域
              this.buildAnnotationSection()

              // 评语区域
              this.buildCommentSection()

              // 操作按钮
              this.buildActionButtons()
            }
            .width('100%')
            .padding({ bottom: 16 })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Auto)
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#F5F5F5')

        // 批注输入对话框 - 覆盖层
        this.buildAnnotationOverlay()
      } else {
        // 加载状态
        this.buildLoading()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildLoading() {
    Column() {
      LoadingProgress()
        .width(40)
        .height(40)
        .color('#1890FF')
      Text('加载中...')
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 12 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildStudentInfoCard() {
    if (this.assignment) {
      Column() {
        Row() {
          Text('学生信息')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#000000')
            .layoutWeight(1)

          if (this.assignment.isRecommended) {
            Text('教师推荐')
              .fontSize(12)
              .fontColor('#FF4D4F')
              .padding({
                left: 8,
                right: 8,
                top: 4,
                bottom: 4
              })
              .backgroundColor('#FFF1F0')
              .borderRadius(4)
          }
        }
        .width('100%')
        .margin({ bottom: 12 })

        Row() {
          Text(`学生姓名: ${this.assignment.studentName}`)
            .fontSize(14)
            .fontColor('#666666')
            .layoutWeight(1)

          Text(`提交时间: ${this.assignment.submitTime}`)
            .fontSize(14)
            .fontColor('#666666')
        }
        .width('100%')
      }
      .width('100%')
      .padding(16)
      .margin({ top: 8, left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .borderRadius(8)
    }
  }

  @Builder
  buildWorkPreview() {
    if (this.assignment) {
      Column() {
        Row() {
          Text('积木作品预览')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#000000')
            .layoutWeight(1)

          Button('查看详情')
            .type(ButtonType.Normal)
            .fontSize(12)
            .height(28)
            .onClick(() => {
              router.pushUrl({
                url: 'pages/WorkPreviewPage',
                params: {
                  workUrl: this.assignment!.workUrl
                }
              });
            })
        }
        .width('100%')
        .margin({ bottom: 12 })

        // 作品预览占位
        Column() {
          Text('📦')
            .fontSize(48)
          Text('点击查看积木作品')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 8 })
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .onClick(() => {
          router.pushUrl({
            url: 'pages/WorkPreviewPage',
            params: {
              workUrl: this.assignment!.workUrl
            }
          });
        })
      }
      .width('100%')
      .padding(16)
      .margin({ top: 8, left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .borderRadius(8)
    }
  }

  @Builder
  buildGradingStandardCard() {
    Column() {
      Row() {
        Text('评分标准')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#000000')
          .layoutWeight(1)

        Button('编辑')
          .type(ButtonType.Normal)
          .fontSize(12)
          .height(28)
          .onClick(() => {
            this.navigateToGradingStandard();
          })
      }
      .width('100%')
      .margin({ bottom: 12 })

      if (this.gradingStandard) {
        Column() {
          ForEach(this.gradingStandard.items, (item: GradingItem) => {
            Row() {
              Text(item.name)
                .fontSize(14)
                .fontColor('#666666')
                .layoutWeight(1)

              Text(`${item.score}分 (权重: ${(item.weight * 100).toFixed(0)}%)`)
                .fontSize(14)
                .fontColor('#1890FF')
            }
            .width('100%')
            .margin({ bottom: 8 })
          })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      } else {
        Text('暂无评分标准')
          .fontSize(14)
          .fontColor('#999999')
      }
    }
    .width('100%')
    .padding(16)
    .margin({ top: 8, left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
  }

  @Builder
  buildScoringSection() {
    if (this.assignment) {
      Column() {
        Text('评分')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#000000')
          .margin({ bottom: 12 })

        Row() {
          Text('得分:')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ right: 12 })

          TextInput({ placeholder: '请输入分数' })
            .type(InputType.Number)
            .layoutWeight(1)
            .height(40)
            .onChange((value: string) => {
              this.score = Number.parseInt(value) || 0;
            })

          Text(`/ ${this.assignment.maxScore}`)
            .fontSize(14)
            .fontColor('#999999')
            .margin({ left: 8 })
        }
        .width('100%')
      }
      .width('100%')
      .padding(16)
      .margin({ top: 8, left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .borderRadius(8)
    }
  }

  @Builder
  buildAIGradingSection() {
    Column() {
      Row() {
        Text('AI评分与评语')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#000000')
          .layoutWeight(1)

        Button('获取AI评分')
          .type(ButtonType.Normal)
          .fontSize(12)
          .height(28)
          .onClick(() => {
            this.loadAIGrading();
          })
      }
      .width('100%')
      .margin({ bottom: 12 })

      if (this.showAIGrading) {
        Column() {
          Row() {
            Text(`AI评分: ${this.aiScore}分`)
              .fontSize(14)
              .fontColor('#1890FF')
              .layoutWeight(1)

            Button('采用')
              .type(ButtonType.Normal)
              .fontSize(12)
              .height(28)
              .onClick(() => {
                this.useAIScore();
              })
          }
          .width('100%')
          .margin({ bottom: 12 })

          Row() {
            Text('AI评语:')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ bottom: 8 })

            Button('采用')
              .type(ButtonType.Normal)
              .fontSize(12)
              .height(28)
              .onClick(() => {
                this.useAIComment();
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)

          Text(this.aiComment)
            .fontSize(14)
            .fontColor('#333333')
            .width('100%')
            .margin({ top: 8 })
            .padding(12)
            .backgroundColor('#F5F5F5')
            .borderRadius(4)
        }
        .width('100%')
      } else {
        Text('点击"获取AI评分"按钮获取AI评分和评语')
          .fontSize(14)
          .fontColor('#999999')
      }
    }
    .width('100%')
    .padding(16)
    .margin({ top: 8, left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
  }

  @Builder
  buildAnnotationSection() {
    Column() {
      Row() {
        Text('批注')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#000000')
          .layoutWeight(1)

        Button('添加文字批注')
          .type(ButtonType.Normal)
          .fontSize(12)
          .height(28)
          .margin({ right: 8 })
          .onClick(() => {
            this.addTextAnnotation();
          })

        Button(this.isRecording ? '停止录音' : '语音批注')
          .type(ButtonType.Normal)
          .fontSize(12)
          .height(28)
          .backgroundColor(this.isRecording ? '#FF4D4F' : '#1890FF')
          .onClick(() => {
            this.startVoiceRecording();
          })
      }
      .width('100%')
      .margin({ bottom: 12 })

      if (this.annotations.length === 0) {
        Text('暂无批注')
          .fontSize(14)
          .fontColor('#999999')
      } else {
        Column() {
          ForEach(this.annotations, (annotation: Annotation) => {
            this.buildAnnotationItem(annotation)
          })
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding(16)
    .margin({ top: 8, left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
  }

  @Builder
  buildAnnotationItem(annotation: Annotation) {
    Column() {
      Row() {
        Text(annotation.type === AnnotationType.TEXT ? '文字批注' : '语音批注')
          .fontSize(12)
          .fontColor('#1890FF')
          .padding({
            left: 6,
            right: 6,
            top: 2,
            bottom: 2
          })
          .backgroundColor('#E6F7FF')
          .borderRadius(4)

        Text(annotation.createTime)
          .fontSize(12)
          .fontColor('#999999')
          .layoutWeight(1)
          .textAlign(TextAlign.End)
      }
      .width('100%')
      .margin({ bottom: 8 })

      if (annotation.type === AnnotationType.TEXT) {
        Text(annotation.content)
          .fontSize(14)
          .fontColor('#333333')
          .width('100%')
      } else {
        Row() {
          Text('🔊')
            .fontSize(20)
          Text('点击播放语音')
            .fontSize(14)
            .fontColor('#1890FF')
            .margin({ left: 8 })
        }
        .width('100%')
        .onClick(() => {
          // 播放语音
          promptAction.showToast({ message: '播放语音功能需要实现' });
        })
      }
    }
    .width('100%')
    .padding(12)
    .margin({ bottom: 8 })
    .backgroundColor('#F5F5F5')
    .borderRadius(4)
  }

  @Builder
  buildCommentSection() {
    Column() {
      Text('评语')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#000000')
        .margin({ bottom: 12 })

      TextArea({ placeholder: '请输入评语...' })
        .width('100%')
        .height(120)
        .fontSize(14)
        .onChange((value: string) => {
          this.comment = value;
        })
    }
    .width('100%')
    .padding(16)
    .margin({ top: 8, left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
  }

  @Builder
  buildActionButtons() {
    if (this.assignment) {
      Row() {
        Button(this.assignment.isRecommended ? '取消推荐' : '标记为教师推荐')
          .type(ButtonType.Normal)
          .fontSize(14)
          .layoutWeight(1)
          .height(44)
          .backgroundColor(this.assignment.isRecommended ? '#FF4D4F' : '#52C41A')
          .onClick(() => {
            this.toggleRecommended();
          })

        Button('保存评分')
          .type(ButtonType.Capsule)
          .fontSize(14)
          .layoutWeight(1)
          .height(44)
          .margin({ left: 12 })
          .backgroundColor('#1890FF')
          .onClick(() => {
            this.saveGrading();
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16 })
    }
  }

  @Builder
  buildAnnotationOverlay() {
    if (this.showAnnotationDialog) {
      Column() {
        // 半透明背景
        Blank()
          .layoutWeight(1)
          .onClick(() => {
            this.showAnnotationDialog = false;
            this.newAnnotationText = '';
          })

        // 对话框
        this.buildAnnotationDialog()

        Blank()
          .layoutWeight(1)
          .onClick(() => {
            this.showAnnotationDialog = false;
            this.newAnnotationText = '';
          })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#80000000')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
  }

  @Builder
  buildAnnotationDialog() {
    Column() {
      Row() {
        Text('添加文字批注')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#000000')
          .layoutWeight(1)

        Text('×')
          .fontSize(24)
          .fontColor('#999999')
          .onClick(() => {
            this.showAnnotationDialog = false;
            this.newAnnotationText = '';
          })
      }
      .width('100%')
      .margin({ bottom: 16 })

      TextArea({ placeholder: '请输入批注内容...', text: this.newAnnotationText })
        .width('100%')
        .height(120)
        .fontSize(14)
        .onChange((value: string) => {
          this.newAnnotationText = value;
        })
        .margin({ bottom: 16 })

      Row() {
        Button('取消')
          .type(ButtonType.Normal)
          .fontSize(14)
          .layoutWeight(1)
          .height(44)
          .margin({ right: 8 })
          .onClick(() => {
            this.showAnnotationDialog = false;
            this.newAnnotationText = '';
          })

        Button('确定')
          .type(ButtonType.Capsule)
          .fontSize(14)
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#1890FF')
          .onClick(() => {
            this.saveTextAnnotation();
          })
      }
      .width('100%')
    }
    .width('90%')
    .padding(24)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({
      radius: 20,
      color: '#000000',
      offsetX: 0,
      offsetY: 4
    })
  }
}

