// entry/src/main/ets/common/ApiConfig.ets

/**
 * API路径配置
 * 对应后端 GradingController 和 StudentRecommendationController 的接口路径
 */
export class ApiConfig {
  // 基础路径
  static readonly BASE_PATH = '/api/v1/grading';
  static readonly STUDENT_BASE_PATH = '/api/v1/students';
  
  // ========== 作业相关 ==========
  static readonly ASSIGNMENTS = `${ApiConfig.BASE_PATH}/assignments`;
  static readonly ASSIGNMENT_BY_ID = (assignmentId: string) => `${ApiConfig.BASE_PATH}/assignment/${assignmentId}`;
  static readonly TEACHER_ASSIGNMENTS = (teacherId: string) => `${ApiConfig.BASE_PATH}/teacher/${teacherId}/assignments`;
  static readonly CREATE_ASSIGNMENT = `${ApiConfig.BASE_PATH}/assignment`;
  static readonly UPDATE_ASSIGNMENT = (assignmentId: string) => `${ApiConfig.BASE_PATH}/assignment/${assignmentId}`;
  static readonly DELETE_ASSIGNMENT = (assignmentId: string) => `${ApiConfig.BASE_PATH}/assignment/${assignmentId}`;
  
  // ========== 提交相关 ==========
  static readonly SUBMISSIONS = (assignmentId: string) => `${ApiConfig.BASE_PATH}/assignment/${assignmentId}/submissions`;
  static readonly SUBMISSION_ANNOTATIONS = (submissionId: string) => `${ApiConfig.BASE_PATH}/submission/${submissionId}/annotations`;
  static readonly MARK_RECOMMEND = (submissionId: string, isRecommended: boolean) => 
    `${ApiConfig.BASE_PATH}/submission/${submissionId}/recommend?isRecommended=${isRecommended}`;
  
  // ========== 评分相关 ==========
  static readonly SUBMIT_GRADE = `${ApiConfig.BASE_PATH}/grade`;
  static readonly AI_GRADING = (submissionId: string) => `${ApiConfig.BASE_PATH}/submission/${submissionId}/ai-grading`;
  
  // ========== 批量反馈相关 ==========
  static readonly BATCH_FEEDBACKS = (assignmentId: string) => `${ApiConfig.BASE_PATH}/assignment/${assignmentId}/batch-feedbacks`;
  static readonly ADD_BATCH_FEEDBACK = `${ApiConfig.BASE_PATH}/batch-feedback`;
  static readonly APPLY_BATCH_FEEDBACK = `${ApiConfig.BASE_PATH}/batch-feedback/apply`;
  static readonly DELETE_BATCH_FEEDBACK = (feedbackId: string) => `${ApiConfig.BASE_PATH}/batch-feedback/${feedbackId}`;
  static readonly BATCH_PROCESS = `${ApiConfig.BASE_PATH}/batch-process`;
  
  // ========== 批注相关 ==========
  static readonly ADD_ANNOTATION = `${ApiConfig.BASE_PATH}/annotation`;
  static readonly DELETE_ANNOTATION = (annotationId: string) => `${ApiConfig.BASE_PATH}/annotation/${annotationId}`;
  
  // ========== 评分标准相关 ==========
  static readonly GRADING_STANDARD = (assignmentId: string) => `${ApiConfig.BASE_PATH}/assignment/${assignmentId}/grading-standard`;
  static readonly SAVE_GRADING_STANDARD = `${ApiConfig.BASE_PATH}/grading-standard`;
  
  // ========== 学生推荐相关 ==========
  static readonly COURSE_STUDENTS = (courseId: string) => `${ApiConfig.STUDENT_BASE_PATH}/course/${courseId}`;
  static readonly RECOMMEND_STUDENT = `${ApiConfig.STUDENT_BASE_PATH}/recommend`;
  static readonly CANCEL_RECOMMEND_STUDENT = (teacherId: string, studentId: string) => 
    `${ApiConfig.STUDENT_BASE_PATH}/recommend/${teacherId}/${studentId}`;
  static readonly RECOMMENDED_STUDENTS = (teacherId: string) => `${ApiConfig.STUDENT_BASE_PATH}/recommended/${teacherId}`;
  static readonly STUDENT_STATS = (studentId: string) => `${ApiConfig.STUDENT_BASE_PATH}/${studentId}/stats`;
}
