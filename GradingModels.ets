/**
 * 评分标准模型
 */
export class GradingStandard {
  id: string = '';
  taskId: string = ''; // 作业任务ID
  name: string = ''; // 评分标准名称
  totalScore: number = 100; // 总分
  items: GradingItem[] = []; // 评分项列表
  createTime: string = '';
  updateTime: string = '';
}

/**
 * 评分项
 */
export class GradingItem {
  id: string = '';
  name: string = ''; // 评分项名称
  description: string = ''; // 评分项描述
  score: number = 0; // 该项分数
  weight: number = 0; // 权重（0-1）
}

/**
 * 作业模型
 */
export class Assignment {
  id: string = '';
  taskId: string = ''; // 任务ID
  studentId: string = ''; // 学生ID
  studentName: string = ''; // 学生姓名
  title: string = ''; // 作业标题
  submitTime: string = ''; // 提交时间
  status: AssignmentStatus = AssignmentStatus.SUBMITTED; // 作业状态
  score: number = 0; // 得分
  maxScore: number = 100; // 满分
  workUrl: string = ''; // 积木作品URL
  isRecommended: boolean = false; // 是否教师推荐
  gradingStandardId: string = ''; // 评分标准ID
}

/**
 * 作业状态
 */
export enum AssignmentStatus {
  SUBMITTED = 'submitted', // 已提交
  GRADING = 'grading', // 批改中
  GRADED = 'graded', // 已批改
  RETURNED = 'returned' // 已退回
}
/**
 * 批注位置接口
 */
export interface AnnotationPosition {
  x: number;
  y: number;
}

/**
 * 批注模型
 */
export class Annotation {
  id: string = '';
  assignmentId: string = ''; // 作业ID
  type: AnnotationType = AnnotationType.TEXT; // 批注类型
  content: string = ''; // 批注内容
  audioUrl: string = ''; // 语音文件URL（如果是语音批注）
  position?: AnnotationPosition; // 批注位置（在作品上的坐标）
  createTime: string = '';
}

/**
 * 批注类型
 */
export enum AnnotationType {
  TEXT = 'text', // 文字批注
  VOICE = 'voice', // 语音批注
  AI = 'ai' // AI生成
}

/**
 * 评语模型
 */
export class Comment {
  id: string = '';
  assignmentId: string = ''; // 作业ID
  content: string = ''; // 评语内容
  type: CommentType = CommentType.MANUAL; // 评语类型
  score: number = 0; // AI评分（如果是AI评语）
  createTime: string = '';
}

/**
 * 评语类型
 */
export enum CommentType {
  MANUAL = 'manual', // 手动评语
  AI = 'ai', // AI生成
  BATCH = 'batch' // 批量评语
}

/**
 * 批量操作配置
 */
export class BatchOperation {
  type: BatchOperationType = BatchOperationType.SCORE; // 操作类型
  assignmentIds: string[] = []; // 作业ID列表
  value: string | number = ''; // 操作值（分数或评语）
  commonIssues: string[] = []; // 共性问题列表
}

/**
 * 批量操作类型
 */
export enum BatchOperationType {
  SCORE = 'score', // 批量打分
  COMMENT = 'comment', // 批量评语
  ANNOTATION = 'annotation' // 批量标注
}

