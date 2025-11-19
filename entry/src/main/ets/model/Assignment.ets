// entry/src/main/ets/model/Assignment.ets

import { DateUtils } from '../common/DateUtils';

export class Assignment {
  assignmentId: number = 0;
  courseId: number = 0;
  assignmentName: string = '';
  assignmentType: string = 'personal'; // personal, team
  description: string = '';
  fullScore: number = 100;
  gradingCriteria: string = '';
  heatIndex: number = 0;
  viewCount: number = 0;
  discussionCount: number = 0;
  startTime: string = '';
  endTime: string = '';
  expectedDuration: number = 0;
  createdTime: string = '';
  studentCount: number = 0;
  submittedCount: number = 0;
  status: string = 'not_started';

  // 修改构造函数
  constructor(data?: Partial<Assignment>) {
    if (data) {
      // 手动赋值代替 Object.assign
      if (data.assignmentId !== undefined) this.assignmentId = data.assignmentId;
      if (data.courseId !== undefined) this.courseId = data.courseId;
      if (data.assignmentName !== undefined) this.assignmentName = data.assignmentName;
      if (data.assignmentType !== undefined) this.assignmentType = data.assignmentType;
      if (data.description !== undefined) this.description = data.description;
      if (data.fullScore !== undefined) this.fullScore = data.fullScore;
      if (data.gradingCriteria !== undefined) this.gradingCriteria = data.gradingCriteria;
      if (data.heatIndex !== undefined) this.heatIndex = data.heatIndex;
      if (data.viewCount !== undefined) this.viewCount = data.viewCount;
      if (data.discussionCount !== undefined) this.discussionCount = data.discussionCount;
      if (data.startTime !== undefined) this.startTime = data.startTime;
      if (data.endTime !== undefined) this.endTime = data.endTime;
      if (data.expectedDuration !== undefined) this.expectedDuration = data.expectedDuration;
      if (data.createdTime !== undefined) this.createdTime = data.createdTime;
      if (data.studentCount !== undefined) this.studentCount = data.studentCount;
      if (data.submittedCount !== undefined) this.submittedCount = data.submittedCount;
      if (data.status !== undefined) this.status = data.status;
    }
  }

  // 计算提交率
  get submissionRate(): number {
    if (this.studentCount === 0) return 0;
    return Math.round((this.submittedCount / this.studentCount) * 100);
  }

  // 检查是否已截止
  get isEnded(): boolean {
    return DateUtils.isExpired(this.endTime);
  }

  // 获取剩余时间
  get remainingTime(): string {
    return DateUtils.getRemainingTime(this.endTime);
  }

  // 格式化开始时间
  get formattedStartTime(): string {
    return DateUtils.formatISODate(this.startTime);
  }

  // 格式化截止时间
  get formattedEndTime(): string {
    return DateUtils.formatISODate(this.endTime);
  }

  // 格式化创建时间
  get formattedCreatedTime(): string {
    return DateUtils.formatISODate(this.createdTime);
  }
}