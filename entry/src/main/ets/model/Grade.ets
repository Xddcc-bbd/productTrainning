// entry/src/main/ets/model/Grade.ets

export class Grade {
  gradeId: number = 0;
  submissionId: number = 0;
  teacherId: string = '';
  score: number = 0;
  aiScore: number = 0;
  finalScore: number = 0;
  textComment: string = '';
  aiTextComment: string = '';
  voiceCommentUrl: string = '';
  isTeacherRecommended: boolean = false;
  gradingTime: string = '';
  createdTime: string = '';

  constructor(data?: Partial<Grade>) {
    if (data) {
      // 手动赋值代替 Object.assign
      if (data.gradeId !== undefined) this.gradeId = data.gradeId;
      if (data.submissionId !== undefined) this.submissionId = data.submissionId;
      if (data.teacherId !== undefined) this.teacherId = data.teacherId;
      if (data.score !== undefined) this.score = data.score;
      if (data.aiScore !== undefined) this.aiScore = data.aiScore;
      if (data.finalScore !== undefined) this.finalScore = data.finalScore;
      if (data.textComment !== undefined) this.textComment = data.textComment;
      if (data.aiTextComment !== undefined) this.aiTextComment = data.aiTextComment;
      if (data.voiceCommentUrl !== undefined) this.voiceCommentUrl = data.voiceCommentUrl;
      if (data.isTeacherRecommended !== undefined) this.isTeacherRecommended = data.isTeacherRecommended;
      if (data.gradingTime !== undefined) this.gradingTime = data.gradingTime;
      if (data.createdTime !== undefined) this.createdTime = data.createdTime;
    }
  }

  // 获取最终得分（优先使用教师评分）
  get displayScore(): number {
    return this.finalScore || this.score || this.aiScore;
  }

  // 检查是否有AI评分
  get hasAIScore(): boolean {
    return this.aiScore > 0;
  }

  // 检查是否有语音评语
  get hasVoiceComment(): boolean {
    return !!this.voiceCommentUrl;
  }
}