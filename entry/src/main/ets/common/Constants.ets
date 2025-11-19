// entry/src/main/ets/common/Constants.ets

interface GeneratedObjectLiteralInterface_4 {
  TEXT: string;
  VOICE: string;
  AI: string;
}

interface GeneratedObjectLiteralInterface_1 {
  NOT_STARTED: string;
  IN_PROGRESS: string;
  ENDED: string;
  GRADING: string;
  GRADED: string;
}

interface GeneratedObjectLiteralInterface_2 {
  SUBMITTED: string;
  GRADING: string;
  GRADED: string;
  RETURNED: string;
}

interface GeneratedObjectLiteralInterface_3 {
  TEACHER: string;
  AI: string;
  FINAL: string;
}

interface GeneratedObjectLiteralInterface_5 {
  PRIMARY: string;
  SUCCESS: string;
  WARNING: string;
  ERROR: string;
  INFO: string;
  BACKGROUND: string;
  WHITE: string;
  BORDER: string;
}

interface GeneratedObjectLiteralInterface_6 {
  PAGE_SIZE: number;
  MAX_SCORE: number;
  AI_SCORE_THRESHOLD: number;
}

interface GeneratedObjectLiteralInterface_7 {
  TEACHER_ID: string;
  COURSE_LIST: string;
  RECENT_ASSIGNMENTS: string;
}

export class Constants {
  // API接口地址
  static readonly BASE_URL: string = 'http://127.0.0.1:8081';

  // 作业状态
  static readonly ASSIGNMENT_STATUS: GeneratedObjectLiteralInterface_1 = {
    NOT_STARTED: 'not_started',
    IN_PROGRESS: 'in_progress',
    ENDED: 'ended',
    GRADING: 'grading',
    GRADED: 'graded'
  };

  // 提交状态
  static readonly SUBMISSION_STATUS: GeneratedObjectLiteralInterface_2 = {
    SUBMITTED: 'submitted',
    GRADING: 'grading',
    GRADED: 'graded',
    RETURNED: 'returned'
  };

  // 评分类型
  static readonly GRADING_TYPE: GeneratedObjectLiteralInterface_3 = {
    TEACHER: 'teacher',
    AI: 'ai',
    FINAL: 'final'
  };

  // 反馈类型
  static readonly FEEDBACK_TYPE: GeneratedObjectLiteralInterface_4 = {
    TEXT: 'text',
    VOICE: 'voice',
    AI: 'ai'
  };

  // 颜色常量
  static readonly COLORS: GeneratedObjectLiteralInterface_5 = {
    PRIMARY: '#1890FF',
    SUCCESS: '#52C41A',
    WARNING: '#FAAD14',
    ERROR: '#FF4D4F',
    INFO: '#1890FF',
    BACKGROUND: '#F5F5F5',
    WHITE: '#FFFFFF',
    BORDER: '#D9D9D9'
  };

  // 默认配置
  static readonly DEFAULT_CONFIG: GeneratedObjectLiteralInterface_6 = {
    PAGE_SIZE: 20,
    MAX_SCORE: 100,
    AI_SCORE_THRESHOLD: 80
  };

  // 本地存储键值
  static readonly STORAGE_KEYS: GeneratedObjectLiteralInterface_7 = {
    TEACHER_ID: 'teacher_id',
    COURSE_LIST: 'course_list',
    RECENT_ASSIGNMENTS: 'recent_assignments'
  };
}