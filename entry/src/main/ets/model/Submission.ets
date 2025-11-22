// entry/src/main/ets/model/Submission.ets

export class Submission {
  submissionId: string = '';
  assignmentId: string = '';
  studentId: string = '';
  studentName: string = '';
  teamId?: string;
  contentUrl: string = '';
  contributionRate: number = 1.00;
  submissionTime: string = '';
  status: string = 'submitted'; // submitted, late
  actualDuration: number = 0;
  isLate: number = 0;
  likeCount: number = 0;
  favoriteCount: number = 0;
  createdTime: string = '';

  constructor(data?: Partial<Submission>) {
    if (data) {
      // 手动赋值代替 Object.assign
      if (data.submissionId !== undefined) this.submissionId = data.submissionId;
      if (data.assignmentId !== undefined) this.assignmentId = data.assignmentId;
      if (data.studentId !== undefined) this.studentId = data.studentId;
      if (data.studentName !== undefined) this.studentName = data.studentName;
      if (data.teamId !== undefined) this.teamId = data.teamId;
      if (data.contentUrl !== undefined) this.contentUrl = data.contentUrl;
      if (data.submissionTime !== undefined) this.submissionTime = data.submissionTime;
      if (data.status !== undefined) this.status = data.status;
      if (data.actualDuration !== undefined) this.actualDuration = data.actualDuration;
      if (data.isLate !== undefined) this.isLate = data.isLate;
      if (data.createdTime !== undefined) this.createdTime = data.createdTime;
      if (data.contributionRate !== undefined) this.contributionRate = data.contributionRate;
      if (data.likeCount !== undefined) this.likeCount = data.likeCount;
      if (data.favoriteCount !== undefined) this.favoriteCount = data.favoriteCount;
    }
  }

  // 获取提交状态文本
  get statusText(): string {
    switch (this.status) {
      case 'submitted': return '已提交';
      case 'grading': return '批改中';
      case 'graded': return '已批改';
      case 'returned': return '已返回';
      default: return '未知状态';
    }
  }

  // 获取状态颜色
  get statusColor(): ResourceColor {
    switch (this.status) {
      case 'submitted': return '#1890FF';
      case 'grading': return '#FAAD14';
      case 'graded': return '#52C41A';
      case 'returned': return '#722ED1';
      default: return '#999999';
    }
  }
}