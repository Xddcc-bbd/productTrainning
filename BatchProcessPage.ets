import { BatchOperation, BatchOperationType, Assignment } from '../models/GradingModels';
import { GradingService, IBatchOperation } from '../utils/GradingService'; // FIX: Import IBatchOperation interface
import router from '@ohos.router';
import { promptAction } from '@kit.ArkUI';

/**
 * 批量处理页面
 */
@Entry
@Component
struct BatchProcessPage {
  @State operationType: BatchOperationType = BatchOperationType.SCORE;
  @State batchScore: number = 0;
  @State batchComment: string = '';
  @State commonIssues: string[] = [];
  @State newIssue: string = '';
  @State assignments: Assignment[] = [];
  @State selectedAssignmentIds: string[] = [];
  private gradingService: GradingService = GradingService.getInstance();

  aboutToAppear() {
    const params = router.getParams() as Record<string, string | number | boolean | string[]>;
    if (params && params['assignmentIds']) {
      this.selectedAssignmentIds = params['assignmentIds'] as string[];
      this.loadAssignments();
    }
  }

  /**
   * 加载作业信息
   */
  async loadAssignments() {
    // FIX for structural typing when filtering results from service call
    const allAssignments: Assignment[] = await this.gradingService.getAssignments('task1');

    // Explicitly filter the array
    const filtered: Assignment[] = [];
    for (let i = 0; i < allAssignments.length; i++) {
      const assignment: Assignment = allAssignments[i];
      if (this.selectedAssignmentIds.includes(assignment.id)) {
        filtered.push(assignment);
      }
    }
    this.assignments = filtered;
  }

  addCommonIssue() {
    if (this.newIssue.trim()) {
      this.commonIssues.push(this.newIssue.trim());
      this.newIssue = '';
    }
  }

  removeCommonIssue(index: number) {
    this.commonIssues.splice(index, 1);
  }

  /**
   * 执行批量操作
   */
  async executeBatchOperation() {
    if (this.selectedAssignmentIds.length === 0) {
      promptAction.showToast({ message: '请选择要处理的作业' });
      return;
    }

    // FIX: Instantiate the Class and type the variable using the Service's public interface (IBatchOperation)
    // This resolves the structural typing conflict on the function call.
    const operation: IBatchOperation = {
      type: this.operationType,
      assignmentIds: [...this.selectedAssignmentIds],
      value: this.operationType === BatchOperationType.SCORE ? this.batchScore : this.batchComment,
      commonIssues: [...this.commonIssues]
    };

    operation.type = this.operationType;
    operation.assignmentIds = [...this.selectedAssignmentIds]; // Copy array
    operation.value = this.operationType === BatchOperationType.SCORE ? this.batchScore : this.batchComment;
    operation.commonIssues = [...this.commonIssues];

    // 验证
    if (this.operationType === BatchOperationType.SCORE && this.batchScore <= 0) {
      promptAction.showToast({ message: '请输入有效的分数' });
      return;
    }

    if (this.operationType === BatchOperationType.COMMENT && !this.batchComment.trim()) {
      promptAction.showToast({ message: '请输入评语' });
      return;
    }

    if (this.operationType === BatchOperationType.ANNOTATION && this.commonIssues.length === 0) {
      promptAction.showToast({ message: '请添加至少一个共性问题' });
      return;
    }

    // Line 60: The call to the service function
    const success = await this.gradingService.batchProcess(operation);
    if (success) {
      promptAction.showToast({ message: '批量处理成功' });
      router.back();
    } else {
      promptAction.showToast({ message: '批量处理失败，请重试' });
    }
  }

  build() {
    Column() {
      Row() {
        Text('←')
          .fontSize(24)
          .fontColor('#000000')
          .onClick(() => {
            router.back();
          })

        Text('批量处理')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#000000')
          .layoutWeight(1)
          .margin({ left: 12 })

        Button('执行')
          .type(ButtonType.Normal)
          .fontSize(14)
          .onClick(() => {
            this.executeBatchOperation();
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      Scroll() {
        Column() {
          this.buildSelectedAssignmentsSection()
          this.buildOperationTypeSection()
          if (this.operationType === BatchOperationType.SCORE) {
            this.buildBatchScoreSection()
          }
          if (this.operationType === BatchOperationType.COMMENT) {
            this.buildBatchCommentSection()
          }
          if (this.operationType === BatchOperationType.ANNOTATION) {
            this.buildBatchAnnotationSection()
          }
        }
        .width('100%')
        .padding({ bottom: 16 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  buildSelectedAssignmentsSection() {
    Column() {
      Row() {
        Text('已选择作业')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#000000')
          .layoutWeight(1)

        Text(`${this.selectedAssignmentIds.length}个`)
          .fontSize(14)
          .fontColor('#1890FF')
      }
      .width('100%')
      .margin({ bottom: 12 })

      Column() {
        ForEach(this.assignments, (assignment: Assignment) => {
          Row() {
            Text(assignment.studentName)
              .fontSize(14)
              .fontColor('#333333')
              .layoutWeight(1)

            Text(assignment.title)
              .fontSize(12)
              .fontColor('#999999')
          }
          .width('100%')
          .padding({ top: 8, bottom: 8 })
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .margin({ top: 8, left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
  }

  @Builder
  buildOperationTypeSection() {
    Column() {
      Text('操作类型')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#000000')
        .margin({ bottom: 12 })

      Row() {
        Button('批量打分')
          .type(ButtonType.Capsule)
          .fontSize(14)
          .layoutWeight(1)
          .height(40)
          .backgroundColor(this.operationType === BatchOperationType.SCORE ? '#1890FF' : '#F5F5F5')
          .fontColor(this.operationType === BatchOperationType.SCORE ? '#FFFFFF' : '#000000')
          .margin({ right: 8 })
          .onClick(() => {
            this.operationType = BatchOperationType.SCORE;
          })

        Button('批量评语')
          .type(ButtonType.Capsule)
          .fontSize(14)
          .layoutWeight(1)
          .height(40)
          .backgroundColor(this.operationType === BatchOperationType.COMMENT ? '#1890FF' : '#F5F5F5')
          .fontColor(this.operationType === BatchOperationType.COMMENT ? '#FFFFFF' : '#000000')
          .margin({ right: 8 })
          .onClick(() => {
            this.operationType = BatchOperationType.COMMENT;
          })

        Button('批量标注')
          .type(ButtonType.Capsule)
          .fontSize(14)
          .layoutWeight(1)
          .height(40)
          .backgroundColor(this.operationType === BatchOperationType.ANNOTATION ? '#1890FF' : '#F5F5F5')
          .fontColor(this.operationType === BatchOperationType.ANNOTATION ? '#FFFFFF' : '#000000')
          .onClick(() => {
            this.operationType = BatchOperationType.ANNOTATION;
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .margin({ top: 8, left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
  }

  @Builder
  buildBatchScoreSection() {
    Column() {
      Text('批量打分')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#000000')
        .margin({ bottom: 12 })

      Row() {
        Text('统一分数:')
          .fontSize(14)
          .fontColor('#666666')
          .width(80)

        TextInput({ placeholder: '请输入分数', text: this.batchScore.toString() })
          .type(InputType.Number)
          .layoutWeight(1)
          .height(40)
          .onChange((value: string) => {
            this.batchScore = Number.parseInt(value) || 0;
          })
      }
      .width('100%')

      Text('将为所有选中的作业统一设置此分数')
        .fontSize(12)
        .fontColor('#999999')
        .margin({ top: 8 })
    }
    .width('100%')
    .padding(16)
    .margin({ top: 8, left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
  }

  @Builder
  buildBatchCommentSection() {
    Column() {
      Text('批量评语')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#000000')
        .margin({ bottom: 12 })

      TextArea({ placeholder: '请输入通用评语...', text: this.batchComment })
        .width('100%')
        .height(120)
        .fontSize(14)
        .onChange((value: string) => {
          this.batchComment = value;
        })

      Text('将为所有选中的作业添加此评语')
        .fontSize(12)
        .fontColor('#999999')
        .margin({ top: 8 })
    }
    .width('100%')
    .padding(16)
    .margin({ top: 8, left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
  }

  @Builder
  buildBatchAnnotationSection() {
    Column() {
      Text('批量标注共性问题')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#000000')
        .margin({ bottom: 12 })

      Row() {
        TextInput({ placeholder: '输入共性问题', text: this.newIssue })
          .layoutWeight(1)
          .height(40)
          .onChange((value: string) => {
            this.newIssue = value;
          })

        Button('添加')
          .type(ButtonType.Capsule)
          .fontSize(14)
          .height(40)
          .margin({ left: 8 })
          .backgroundColor('#1890FF')
          .onClick(() => {
            this.addCommonIssue();
          })
      }
      .width('100%')
      .margin({ bottom: 12 })

      if (this.commonIssues.length > 0) {
        Column() {
          ForEach(this.commonIssues, (issue: string, index: number) => {
            Row() {
              Text(issue)
                .fontSize(14)
                .fontColor('#333333')
                .layoutWeight(1)
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })

              Text('×')
                .fontSize(20)
                .fontColor('#999999')
                .margin({ left: 8 })
                .onClick(() => {
                  this.removeCommonIssue(index);
                })
            }
            .width('100%')
            .padding(12)
            .margin({ bottom: 8 })
            .backgroundColor('#F5F5F5')
            .borderRadius(4)
          })
        }
        .width('100%')
      } else {
        Text('暂无共性问题，请添加')
          .fontSize(14)
          .fontColor('#999999')
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding(16)
      }

      Text('将为所有选中的作业标注这些共性问题')
        .fontSize(12)
        .fontColor('#999999')
        .margin({ top: 8 })
    }
    .width('100%')
    .padding(16)
    .margin({ top: 8, left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
  }
}