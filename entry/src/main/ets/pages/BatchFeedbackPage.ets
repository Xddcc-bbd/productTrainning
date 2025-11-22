// entry/src/main/ets/pages/BatchFeedbackPage.ets

import { BatchFeedback } from '../model/BatchFeedback';
import { batchFeedbackService } from '../service/BatchFeedbackService';
import { assignmentService } from '../service/AssignmentService';
import { Assignment } from '../model/Assignment';
import router from '@ohos.router';

@Component
struct FeedbackItem {
  @Prop feedback: BatchFeedback;
  @Link selectedFeedbackIds: string[];
  
  build() {
    Row() {
      // 选择框 - 使用Checkbox组件
      Checkbox()
        .select(this.selectedFeedbackIds.includes(this.feedback.feedbackId))
        .onChange((value: boolean) => {
          if (value) {
            // 添加选择
            this.selectedFeedbackIds.push(this.feedback.feedbackId);
          } else {
            // 取消选择
            const index = this.selectedFeedbackIds.indexOf(this.feedback.feedbackId);
            this.selectedFeedbackIds.splice(index, 1);
          }
        })
        .margin({ right: 12 })
      
      Column() {
        Row() {
          Text(this.feedback.typeText)
            .fontSize(12)
            .backgroundColor(this.feedback.typeColor)
            .padding({ left: 6, right: 6 })
            .borderRadius(4)
            .fontColor(Color.White)
          
          Blank()
          
          Text('使用次数: ' + this.feedback.usedCount)
            .fontSize(12)
            .fontColor('#999999')
        }
        .width('100%')
        
        Text(this.feedback.content)
          .fontSize(14)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 4 })
      }
      .layoutWeight(1)
    }
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .onClick(() => {
      // 点击反馈项可以查看详情或编辑
      console.log('点击反馈项:', this.feedback);
    })
  }
}

@Entry
@Component
struct BatchFeedbackPage {
  @State feedbacks: BatchFeedback[] = [];
  @State selectedFeedbackIds: string[] = [];
  @State showCreateForm: boolean = false;
  @State newFeedback: BatchFeedback = new BatchFeedback();
  @State feedbackTypes: string[] = ['common_issue', 'suggestion', 'praise'];
  @State selectedType: string = 'common_issue';
  @State isLoading: boolean = false;
  @State assignments: Assignment[] = [];
  @State selectedAssignmentId: string = '';
  
  aboutToAppear() {
    this.loadAssignments();
    this.loadFeedbacks();
  }
  
  async loadAssignments() {
    try {
      console.log('加载作业列表...');
      this.assignments = await assignmentService.getTeacherAssignments('teacher_zhao');
      if (this.assignments.length > 0) {
        this.selectedAssignmentId = this.assignments[0].assignmentId;
      }
      console.log(`✅ 加载到 ${this.assignments.length} 个作业`);
    } catch (error) {
      console.error('加载作业列表失败:', error);
    }
  }
  
  async loadFeedbacks() {
    try {
      this.isLoading = true;
      console.log('加载批量反馈列表...');
      // 如果有选中的作业，加载该作业的反馈
      if (this.selectedAssignmentId) {
        this.feedbacks = await batchFeedbackService.getCommonFeedbacks(this.selectedAssignmentId);
      } else {
        // 否则加载默认作业的反馈
        this.feedbacks = await batchFeedbackService.getCommonFeedbacks('assign_01');
      }
      console.log(`✅ 加载到 ${this.feedbacks.length} 条反馈`);
    } catch (error) {
      console.error('❌ 加载反馈列表失败:', error);
    } finally {
      this.isLoading = false;
    }
  }
  
  async createFeedback() {
    try {
      this.newFeedback.courseId = 'course_01';
      this.newFeedback.assignmentId = 'assign_01';
      this.newFeedback.feedbackType = this.selectedType;
      this.newFeedback.createdBy = 'T001';
      this.newFeedback.createdTime = new Date().toISOString();
      
      const result = await batchFeedbackService.addBatchFeedback(this.newFeedback);
      if (result) {
        console.log('创建反馈成功');
        this.showCreateForm = false;
        this.newFeedback = new BatchFeedback();
        this.loadFeedbacks(); // 重新加载列表
      }
    } catch (error) {
      console.error('创建反馈失败:', error);
    }
  }
  
  async applySelectedFeedback() {
    if (this.selectedFeedbackIds.length === 0) {
      console.log('请选择要应用的反馈');
      return;
    }
    
    try {
      // 这里应该传入实际的作业ID列表
      const submissionIds = ['sub_01', 'sub_02', 'sub_03']; 
      
      for (const feedbackId of this.selectedFeedbackIds) {
        const result = await batchFeedbackService.applyBatchFeedback(submissionIds);
        if (result) {
          console.log('应用反馈成功:', feedbackId);
        }
      }
      
      // 清空选择
      this.selectedFeedbackIds = [];
      console.log('批量反馈应用完成');
    } catch (error) {
      console.error('应用反馈失败:', error);
    }
  }
  
  build() {
    Column() {
      // 顶部导航
      Row() {
        Text('←')
          .fontSize(24)
          .fontColor('#1890FF')
          .onClick(() => {
            router.back();
          })
          .margin({ right: 12 })
        
        Text('批量反馈')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
        
        // 条件渲染按钮
        if (this.showCreateForm) {
          Button('取消')
            .type(ButtonType.Normal)
            .onClick(() => {
              this.showCreateForm = false;
              this.newFeedback = new BatchFeedback();
            })
        } else {
          Button('新建')
            .type(ButtonType.Normal)
            .onClick(() => {
              this.showCreateForm = true;
            })
        }
      }
      .padding({ left: 16, right: 16, top: 16, bottom: 16 })
      
      // 条件渲染内容
      if (this.showCreateForm) {
        // 创建反馈表单
        Scroll() {
          Column() {
            Text('新建反馈')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .width('100%')
              .margin({ bottom: 16 })
            
            // 反馈类型选择
            Column() {
              Text('反馈类型')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .width('100%')
                .margin({ bottom: 8 })
              
              Row() {
                ForEach(this.feedbackTypes, (type: string, index: number) => {
                  Button(this.getFeedbackTypeText(type))
                    .type(type === this.selectedType ? ButtonType.Capsule : ButtonType.Normal)
                    .backgroundColor(type === this.selectedType ? '#1890FF' : '#F5F5F5')
                    .fontColor(type === this.selectedType ? '#FFFFFF' : '#333333')
                    .layoutWeight(1)
                    .margin({ right: 8 })
                    .onClick(() => {
                      this.selectedType = type;
                    })
                })
              }
              .width('100%')
            }
            .width('100%')
            .margin({ bottom: 16 })
            
            // 反馈内容
            Column() {
              Text('反馈内容')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .width('100%')
                .margin({ bottom: 8 })
              
              TextArea({ placeholder: '请输入反馈内容...', text: this.newFeedback.content })
                .onChange((value: string) => {
                  this.newFeedback.content = value;
                })
                .width('100%')
                .height(120)
            }
            .width('100%')
            .margin({ bottom: 24 })
            
            // 保存按钮
            Button('保存反馈')
              .type(ButtonType.Capsule)
              .width('100%')
              .backgroundColor('#1890FF')
              .fontColor('#FFFFFF')
              .onClick(() => {
                this.createFeedback();
              })
          }
          .padding({ left: 16, right: 16 })
        }
        .layoutWeight(1)
      } else {
        // 反馈列表
        Column() {
          // 已选择的反馈
          if (this.selectedFeedbackIds.length > 0) {
            Row() {
              Text('已选择 ' + this.selectedFeedbackIds.length + ' 项')
                .fontSize(14)
                .layoutWeight(1)
              
              Button('应用到作业')
                .type(ButtonType.Normal)
                .backgroundColor('#52C41A')
                .fontColor('#FFFFFF')
                .onClick(() => {
                  this.applySelectedFeedback();
                })
            }
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .backgroundColor('#F0F8FF')
          }
          
          // 反馈列表
          List() {
            ForEach(this.feedbacks, (feedback: BatchFeedback, index: number) => {
              ListItem() {
                Column() {
                  FeedbackItem({
                    feedback: feedback,
                    selectedFeedbackIds: $selectedFeedbackIds
                  })
                  
                  Divider()
                    .color('#EEEEEE')
                    .strokeWidth(1)
                }
              }
            }, (item: BatchFeedback, index: number) => {
              return item.feedbackId.toString();
            })
          }
          .layoutWeight(1)
          .divider({ strokeWidth: 0 })
        }
      }
    }
  }
  
  getFeedbackTypeText(type: string): string {
    switch (type) {
      case 'common_issue': return '常见问题';
      case 'suggestion': return '改进建议';
      case 'praise': return '表扬鼓励';
      default: return '其他';
    }
  }
}