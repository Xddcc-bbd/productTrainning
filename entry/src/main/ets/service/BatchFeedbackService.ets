// entry/src/main/ets/service/BatchFeedbackService.ets

import { BatchFeedback } from '../model/BatchFeedback';
import { HttpService } from '../common/HttpService';
import { ApiConfig } from '../common/ApiConfig';

// 批量操作请求
interface BatchOperationRequest {
  operationType: string; // SCORE, COMMENT, ANNOTATION
  submissionIds: string[];
  batchScore?: number;
  batchComment?: string;
  commonIssues?: string[];
}

export class BatchFeedbackService {
  private http = HttpService.getInstance();

  /**
   * 获取批量反馈模板列表
   * 对应后端: GET /api/v1/grading/assignment/{assignmentId}/batchfeedbacks
   */
  async getBatchFeedbacks(assignmentId: string): Promise<BatchFeedback[]> {
    try {
      const response = await this.http.get<BatchFeedback[]>(
        ApiConfig.BATCH_FEEDBACKS(assignmentId)
      );
      if (response && response.length > 0) {
        return response.map(item => new BatchFeedback(item));
      }
      return [];
    } catch (error) {
      console.error('获取批量反馈列表失败:', error);
      return [];
    }
  }

  /**
   * 添加批量反馈模板
   * 对应后端: POST /api/v1/grading/batch-feedback
   */
  async addBatchFeedback(feedback: BatchFeedback): Promise<BatchFeedback | null> {
    try {
      const response = await this.http.post<BatchFeedback>(
        ApiConfig.ADD_BATCH_FEEDBACK,
        feedback
      );
      if (response) {
        return new BatchFeedback(response);
      }
      return null;
    } catch (error) {
      console.error('添加批量反馈失败:', error);
      return null;
    }
  }

  /**
   * 更新批处理反馈
   */
  async updateBatchFeedback(feedbackId: string, feedback: BatchFeedback): Promise<BatchFeedback> {
    try {
      console.log('更新批处理反馈:', feedbackId, feedback);
      return new BatchFeedback(feedback);
    } catch (error) {
      console.error('更新批处理反馈失败:', error);
      throw new Error(typeof error === 'string' ? error : JSON.stringify(error));
    }
  }

  /**
   * 删除批处理反馈
   * 对应后端: DELETE /api/v1/grading/batch-feedback/{feedbackId}
   */
  async deleteBatchFeedback(feedbackId: string): Promise<boolean> {
    try {
      console.log('🗑️ 删除批处理反馈:', feedbackId);
      await this.http.delete<boolean>(
        ApiConfig.DELETE_BATCH_FEEDBACK(feedbackId)
      );
      console.log('✅ 删除成功');
      return true;
    } catch (error) {
      console.error('❌ 删除批处理反馈失败:', error);
      return false;
    }
  }

  /**
   * 获取常用反馈列表
   */
  async getCommonFeedbacks(assignmentId: string): Promise<BatchFeedback[]> {
    try {
      // 调用后端获取批量反馈
      return await this.getBatchFeedbacks(assignmentId);
    } catch (error) {
      console.error('获取常用反馈列表失败:', error);
      return [];
    }
  }

  /**
   * 批量处理
   * 对应后端: POST /api/v1/grading/batchprocess
   */
  async applyBatchFeedback(
    submissionIds: string[],
    batchScore?: number,
    batchComment?: string
  ): Promise<boolean> {
    try {
      const request: BatchOperationRequest = {
        operationType: batchScore ? 'SCORE' : 'COMMENT',
        submissionIds,
        batchScore,
        batchComment
      };
      
      await this.http.post<void>(ApiConfig.BATCH_PROCESS, request);
      return true;
    } catch (error) {
      console.error('批量处理失败:', error);
      return false;
    }
  }
}

export const batchFeedbackService = new BatchFeedbackService();