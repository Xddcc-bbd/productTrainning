import { HttpClient } from "./HttpClient";
import {
  Assignment,
  GradingStandard,
  Annotation,
  BatchOperation,
  BatchOperationType
} from '../models/GradingModels';

// === Public API Interfaces (Contracts) ===

/**
 * AI评分结果接口
 */
export interface AIGradingResult {
  score: number;
  comment: string;
  suggestions: string[];
}

/**
 * 批量操作的公共接口，用于解决跨模块结构化类型问题
 */
export interface IBatchOperation {
  type: BatchOperationType;
  assignmentIds: string[];
  value: string | number;
  commonIssues: string[];
}

// === Internal API Request Interfaces ===

/**
 * 提交评分的请求体
 */
interface GradeSubmissionRequest {
  submissionId: number;
  teacherId: string;
  finalScore: number;
  textComment: string;
}

/**
 * 批量处理的请求体
 */
interface BatchProcessRequest {
  operationType: string;
  submissionIds: number[];
  batchScore?: number;
  batchComment?: string;
  commonIssues: string[];
}

/**
 * 作业评分服务
 */
export class GradingService {
  private static instance: GradingService;
  // 假设 HttpClient 在同一个 utils 目录下
  private httpClient: HttpClient = HttpClient.getInstance();

  static getInstance(): GradingService {
    if (!GradingService.instance) {
      GradingService.instance = new GradingService();
    }
    return GradingService.instance;
  }

  // 获取作业列表
  async getAssignments(taskId: string, status?: string): Promise<Assignment[]> {
    const params: Record<string, string> = { 'taskId': taskId };
    if (status) {
      params['status'] = status;
    }
    // 假设 /assignments 接口返回 Assignment[]
    // 实际项目中应替换为实际的 API 调用
    return this.httpClient.get<Assignment[]>('/assignments', params);
  }

  // 获取评分标准
  async getGradingStandard(standardId: string): Promise<GradingStandard> {
    // 假设 /grading-standard 接口返回 GradingStandard
    return this.httpClient.get<GradingStandard>(`/grading-standard/${standardId}`);
  }

  // 保存评分标准
  async saveGradingStandard(standard: GradingStandard): Promise<boolean> {
    // 假设 /grading-standard 接口用于保存
    return this.httpClient.post<boolean>('/grading-standard', standard);
  }

  // 获取AI评分
  async getAIGrading(assignmentId: string, standardId: string): Promise<AIGradingResult> {
    // 假设 /ai-grading 接口返回 AIGradingResult
    return this.httpClient.get<AIGradingResult>(`/submission/${assignmentId}/ai-grading?standardId=${standardId}`);
  }

  // 添加批注
  async addAnnotation(annotation: Annotation): Promise<boolean> {
    // 假设 /annotation 接口用于添加批注
    return this.httpClient.post<boolean>('/annotation', annotation);
  }

  // 获取批注
  async getAnnotations(submissionId: number): Promise<Annotation[]> {
    // 假设 /annotations 接口返回 Annotation[]
    return this.httpClient.get<Annotation[]>(`/submission/${submissionId}/annotations`);
  }

  // 提交评分
  async submitGrading(assignmentId: string, score: number, comment: string): Promise<boolean> {
    const gradeRequest: GradeSubmissionRequest = {
      submissionId: parseInt(assignmentId),
      teacherId: 'teacher_zhao', // 示例教师ID
      finalScore: score,
      textComment: comment
    };
    return this.httpClient.post<boolean>('/grade', gradeRequest);
  }

  // 标记为推荐
  async markAsRecommended(assignmentId: string, isRecommended: boolean): Promise<boolean> {
    const body: Record<string, Object> = {}; // PUT请求可能需要空 body
    return this.httpClient.put<boolean>(`/submission/${assignmentId}/recommend?isRecommended=${isRecommended}`, body);
  }

  // 批量处理 - 使用 IBatchOperation 接口作为参数类型
  async batchProcess(operation: IBatchOperation): Promise<boolean> {
    // 将模型数据转换为 API 请求结构
    const batchRequest: BatchProcessRequest = {
      operationType: operation.type,
      // 将 string[] 转换为 number[]
      submissionIds: operation.assignmentIds.map((id: string) => parseInt(id)),
      // 根据操作类型设置分数或评语
      batchScore: operation.type === BatchOperationType.SCORE ? (operation.value as number) : undefined,
      batchComment: operation.type === BatchOperationType.COMMENT ? (operation.value as string) : undefined,
      commonIssues: operation.commonIssues
    };
    return this.httpClient.post<boolean>('/batch-process', batchRequest);
  }
}