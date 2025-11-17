import { Assignment, AssignmentStatus } from '../models/GradingModels';
import { GradingService } from '../utils/GradingService';
import router from '@ohos.router';

/**
 * 作业批改主页面
 */
@Entry
@Component
struct GradingPage {
  @State assignments: Assignment[] = [];
  @State filteredAssignments: Assignment[] = [];
  @State selectedStatus: string = 'all'; // 筛选状态：all, submitted, grading, graded
  @State selectedAssignments: Set<string> = new Set(); // 选中的作业ID（用于批量操作）
  @State isBatchMode: boolean = false; // 是否批量模式
  private taskId: string = 'task1'; // 任务ID，实际应从路由参数获取
  private gradingService: GradingService = GradingService.getInstance();

  aboutToAppear() {
    this.taskId = '1'; // 使用数据库中的assignment_id
    this.loadAssignments();
  }

  /**
   * 加载作业列表
   */
  async loadAssignments() {
    try {
      this.assignments = await this.gradingService.getAssignments(this.taskId, this.selectedStatus);
      this.filteredAssignments = [...this.assignments];
    } catch (error) {
      console.error('加载作业列表失败:', error);
    }
  }
  /**
   * 筛选作业
   */
  filterAssignments() {
    if (this.selectedStatus === 'all') {
      this.filteredAssignments = [...this.assignments];
    } else {
      this.filteredAssignments = this.assignments.filter(assignment => 
        assignment.status === this.selectedStatus
      );
    }
  }

  /**
   * 状态筛选改变
   */
  onStatusFilterChange(status: string) {
    this.selectedStatus = status;
    this.filterAssignments();
  }

  /**
   * 切换批量模式
   */
  toggleBatchMode() {
    this.isBatchMode = !this.isBatchMode;
    if (!this.isBatchMode) {
      this.selectedAssignments.clear();
    }
  }

  /**
   * 切换作业选中状态
   */
  toggleAssignmentSelection(assignmentId: string) {
    if (this.selectedAssignments.has(assignmentId)) {
      this.selectedAssignments.delete(assignmentId);
    } else {
      this.selectedAssignments.add(assignmentId);
    }
  }

  /**
   * 进入批量处理页面
   */
  navigateToBatchProcess() {
    if (this.selectedAssignments.size === 0) {
      // 提示选择作业
      return;
    }
    router.pushUrl({
      url: 'pages/BatchProcessPage',
      params: {
        assignmentIds: Array.from(this.selectedAssignments)
      }
    });
  }

  /**
   * 进入作业详情页面
   */
  navigateToAssignmentDetail(assignment: Assignment) {
    router.pushUrl({
      url: 'pages/AssignmentDetailPage',
      params: {
        assignmentId: assignment.id
      }
    });
  }

  /**
   * 获取状态文本
   */
  getStatusText(status: AssignmentStatus): string {
    switch (status) {
      case AssignmentStatus.SUBMITTED:
        return '已提交';
      case AssignmentStatus.GRADING:
        return '批改中';
      case AssignmentStatus.GRADED:
        return '已批改';
      case AssignmentStatus.RETURNED:
        return '已退回';
      default:
        return '未知';
    }
  }

  /**
   * 获取状态颜色
   */
  getStatusColor(status: AssignmentStatus): ResourceColor {
    switch (status) {
      case AssignmentStatus.SUBMITTED:
        return '#1890FF';
      case AssignmentStatus.GRADING:
        return '#FF9800';
      case AssignmentStatus.GRADED:
        return '#52C41A';
      case AssignmentStatus.RETURNED:
        return '#FF4D4F';
      default:
        return '#8C8C8C';
    }
  }

  build() {
    Column() {
      // 顶部工具栏
      Row() {
        Text('作业批改')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#000000')
          .layoutWeight(1)

        if (this.isBatchMode) {
          Button('取消')
            .type(ButtonType.Normal)
            .fontSize(14)
            .onClick(() => {
              this.toggleBatchMode();
            })

          Button(`批量处理(${this.selectedAssignments.size})`)
            .type(ButtonType.Capsule)
            .fontSize(14)
            .backgroundColor('#1890FF')
            .enabled(this.selectedAssignments.size > 0)
            .onClick(() => {
              this.navigateToBatchProcess();
            })
        } else {
          Button('批量')
            .type(ButtonType.Normal)
            .fontSize(14)
            .onClick(() => {
              this.toggleBatchMode();
            })
        }
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      // 状态筛选标签
      Row() {
        this.buildStatusFilter('all', '全部')
        this.buildStatusFilter('submitted', '已提交')
        this.buildStatusFilter('grading', '批改中')
        this.buildStatusFilter('graded', '已批改')
      }
      .width('100%')
      .height(48)
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor('#F5F5F5')
      .justifyContent(FlexAlign.Start)

      // 作业列表
      List() {
        ForEach(this.filteredAssignments, (assignment: Assignment) => {
          ListItem() {
            this.buildAssignmentItem(assignment)
          }
        }, (assignment: Assignment) => assignment.id)
      }
      .width('100%')
      .layoutWeight(1)
      .divider({ strokeWidth: 1, color: '#E5E5E5', startMargin: 16, endMargin: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  /**
   * 构建状态筛选标签
   */
  @Builder
  buildStatusFilter(status: string, text: string) {
    Button(text)
      .type(ButtonType.Capsule)
      .fontSize(14)
      .backgroundColor(this.selectedStatus === status ? '#1890FF' : '#FFFFFF')
      .fontColor(this.selectedStatus === status ? '#FFFFFF' : '#000000')
      .margin({ right: 8 })
      .onClick(() => {
        this.onStatusFilterChange(status);
      })
  }

  /**
   * 构建作业项
   */
  @Builder
  buildAssignmentItem(assignment: Assignment) {
    Row() {
      if (this.isBatchMode) {
        Checkbox()
          .select(this.selectedAssignments.has(assignment.id))
          .onChange((isChecked: boolean) => {
            if (isChecked) {
              this.selectedAssignments.add(assignment.id);
            } else {
              this.selectedAssignments.delete(assignment.id);
            }
          })
          .margin({ right: 12 })
      }

      Column() {
        Row() {
          Text(assignment.studentName)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#000000')
            .layoutWeight(1)

          if (assignment.isRecommended) {
            Text('教师推荐')
              .fontSize(12)
              .fontColor('#FF4D4F')
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .backgroundColor('#FFF1F0')
              .borderRadius(4)
              .margin({ right: 8 })
          }

          Text(this.getStatusText(assignment.status))
            .fontSize(12)
            .fontColor(this.getStatusColor(assignment.status))
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor('#F5F5F5')
            .borderRadius(4)
        }
        .width('100%')
        .margin({ bottom: 8 })

        Text(assignment.title)
          .fontSize(14)
          .fontColor('#666666')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ bottom: 8 })

        Row() {
          Text(`提交时间: ${assignment.submitTime}`)
            .fontSize(12)
            .fontColor('#999999')
            .layoutWeight(1)

          if (assignment.status === AssignmentStatus.GRADED || assignment.status === AssignmentStatus.GRADING) {
            Text(`得分: ${assignment.score}/${assignment.maxScore}`)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1890FF')
          }
        }
        .width('100%')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .onClick(() => {
        if (!this.isBatchMode) {
          this.navigateToAssignmentDetail(assignment);
        } else {
          this.toggleAssignmentSelection(assignment.id);
        }
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor('#FFFFFF')
  }
}

