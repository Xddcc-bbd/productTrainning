// entry/src/main/ets/common/ApiConfig.ets

/**
 * API路径配置
 * 对应后端 GradingController 的接口路径
 */
export class ApiConfig {
  // 基础路径
  static readonly BASE_PATH = '/api/v1/grading';
  
  // 作业相关
  static readonly ASSIGNMENTS = `${ApiConfig.BASE_PATH}/assignments`;
  static readonly ASSIGNMENT_BY_ID = (assignmentId: number) => `${ApiConfig.BASE_PATH}/assignment/${assignmentId}`;
  static readonly TEACHER_ASSIGNMENTS = (teacherId: string) => `${ApiConfig.BASE_PATH}/teacher/${teacherId}/assignments`;
  static readonly CREATE_ASSIGNMENT = `${ApiConfig.BASE_PATH}/assignment`;
  static readonly UPDATE_ASSIGNMENT = (assignmentId: number) => `${ApiConfig.BASE_PATH}/assignment/${assignmentId}`;
  static readonly DELETE_ASSIGNMENT = (assignmentId: number) => `${ApiConfig.BASE_PATH}/assignment/${assignmentId}`;
  
  // 提交相关
  static readonly SUBMISSIONS = (assignmentId: number) => `${ApiConfig.BASE_PATH}/assignment/${assignmentId}/submissions`;
  static readonly SUBMISSION_ANNOTATIONS = (submissionId: number) => `${ApiConfig.BASE_PATH}/submission/${submissionId}/annotations`;
  static readonly MARK_RECOMMEND = (submissionId: number) => `${ApiConfig.BASE_PATH}/submission/${submissionId}/recommend`;
  
  // 评分相关
  static readonly SUBMIT_GRADE = `${ApiConfig.BASE_PATH}/grade`;
  static readonly AI_GRADING = (submissionId: number) => `${ApiConfig.BASE_PATH}/submission/${submissionId}/ai-grading`;
  
  // 批量反馈相关
  static readonly BATCH_FEEDBACKS = (assignmentId: number) => `${ApiConfig.BASE_PATH}/assignment/${assignmentId}/batch-feedbacks`;
  static readonly ADD_BATCH_FEEDBACK = `${ApiConfig.BASE_PATH}/batch-feedback`;
  static readonly BATCH_PROCESS = `${ApiConfig.BASE_PATH}/batch-process`;
  
  // 批注相关
  static readonly ADD_ANNOTATION = `${ApiConfig.BASE_PATH}/annotation`;
  
  // 评分标准相关
  static readonly GRADING_STANDARD = (assignmentId: number) => `${ApiConfig.BASE_PATH}/assignment/${assignmentId}/grading-standard`;
  static readonly SAVE_GRADING_STANDARD = `${ApiConfig.BASE_PATH}/grading-standard`;
}
