// entry/src/main/ets/model/BatchFeedback.ets

export class BatchFeedback {
  feedbackId: string = '';
  courseId: string = '';
  assignmentId: string = '';
  feedbackType: string = 'common_issue'; // common_issue, suggestion, praise, template
  content: string = '';
  usedCount: number = 0;
  createdBy: string = '';
  createdTime: string = '';

  constructor(data?: Partial<BatchFeedback>) {
    if (data) {
      // 手动赋值代替 Object.assign
      if (data.feedbackId !== undefined) this.feedbackId = data.feedbackId;
      if (data.courseId !== undefined) this.courseId = data.courseId;
      if (data.assignmentId !== undefined) this.assignmentId = data.assignmentId;
      if (data.feedbackType !== undefined) this.feedbackType = data.feedbackType;
      if (data.content !== undefined) this.content = data.content;
      if (data.usedCount !== undefined) this.usedCount = data.usedCount;
      if (data.createdBy !== undefined) this.createdBy = data.createdBy;
      if (data.createdTime !== undefined) this.createdTime = data.createdTime;
    }
  }

  // 获取反馈类型文本
  get typeText(): string {
    switch (this.feedbackType) {
      case 'common_issue': return '常见问题';
      case 'suggestion': return '改进建议';
      case 'praise': return '表扬鼓励';
      default: return '其他';
    }
  }

  // 获取反馈类型颜色
  get typeColor(): ResourceColor {
    switch (this.feedbackType) {
      case 'common_issue': return '#FF4D4F';
      case 'suggestion': return '#1890FF';
      case 'praise': return '#52C41A';
      default: return '#999999';
    }
  }
}