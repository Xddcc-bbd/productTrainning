// entry/src/main/ets/model/Student.ets

export class Student {
  studentId: string = '';
  realName: string = '';
  className: string = '';
  major: string = '';
  rank: number = 0;
  enrollmentYear: number = 0;
  email: string = '';
  phone: string = '';
  avatar: string = '';
  totalScore: number = 0;
  ranking: number = 0;
  completedTasks: number = 0;
  pendingTasks: number = 0;
  isRecommended: boolean = false;
  recommendationReason?: string;

  constructor(data?: Partial<Student>) {
    if (data) {
      // 手动赋值代替 Object.assign
      if (data.studentId !== undefined) this.studentId = data.studentId;
      if (data.realName !== undefined) this.realName = data.realName;
      if (data.className !== undefined) this.className = data.className;
      if (data.major !== undefined) this.major = data.major;
      if (data.rank !== undefined) this.rank = data.rank;
      if (data.enrollmentYear !== undefined) this.enrollmentYear = data.enrollmentYear;
      if (data.email !== undefined) this.email = data.email;
      if (data.phone !== undefined) this.phone = data.phone;
      if (data.avatar !== undefined) this.avatar = data.avatar;
      if (data.totalScore !== undefined) this.totalScore = data.totalScore;
      if (data.ranking !== undefined) this.ranking = data.ranking;
      if (data.completedTasks !== undefined) this.completedTasks = data.completedTasks;
      if (data.pendingTasks !== undefined) this.pendingTasks = data.pendingTasks;
      if (data.isRecommended !== undefined) this.isRecommended = data.isRecommended;
      if (data.recommendationReason !== undefined) this.recommendationReason = data.recommendationReason;
    }
  }

  // 获取完成率
  get completionRate(): number {
    const total = this.completedTasks + this.pendingTasks;
    if (total === 0) return 0;
    return Math.round((this.completedTasks / total) * 100);
  }

  // 获取成绩等级
  get gradeLevel(): string {
    if (this.totalScore >= 90) return '优秀';
    if (this.totalScore >= 80) return '良好';
    if (this.totalScore >= 70) return '中等';
    if (this.totalScore >= 60) return '及格';
    return '不及格';
  }
}