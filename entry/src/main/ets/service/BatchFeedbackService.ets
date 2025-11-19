// entry/src/main/ets/service/BatchFeedbackService.ets

import { BatchFeedback } from '../model/BatchFeedback';
import { HttpService } from '../common/HttpService';
import { ApiConfig } from '../common/ApiConfig';

// 批量操作请求
interface BatchOperationRequest {
  assignmentId: number;
  submissionIds: number[];
  operation: string; // 'apply_feedback', 'set_status', etc.
  feedbackId?: number;
  status?: string;
}

export class BatchFeedbackService {
  private http = HttpService.getInstance();

  /**
   * 获取批量反馈模板列表
   * 对应后端: GET /api/v1/grading/assignment/{assignmentId}/batch-feedbacks
   */
  async getBatchFeedbacks(assignmentId: number): Promise<BatchFeedback[]> {
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
  async updateBatchFeedback(feedbackId: number, feedback: BatchFeedback): Promise<BatchFeedback> {
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
   */
  async deleteBatchFeedback(feedbackId: number): Promise<boolean> {
    try {
      console.log('删除批处理反馈:', feedbackId);
      return true;
    } catch (error) {
      console.error('删除批处理反馈失败:', error);
      return false;
    }
  }

  /**
   * 获取常用反馈列表
   */
  async getCommonFeedbacks(courseId: number): Promise<BatchFeedback[]> {
    try {
      const mockData1 = new BatchFeedback({
        "feedbackId": 1,
        "courseId": courseId,
        "assignmentId": 1,
        "feedbackType": 'common_issue',
        "content": '变量命名不规范，建议使用有意义的英文命名',
        "usedCount": 15,
        "createdBy": 'T001',
        "createdTime": '2024-01-10 09:00:00'
      } as Record<string, Object>);

      const mockData2 = new BatchFeedback({
        "feedbackId": 2,
        "courseId": courseId,
        "assignmentId": 1,
        "feedbackType": 'suggestion',
        "content": '算法复杂度较高，可以考虑优化时间复杂度',
        "usedCount": 12,
        "createdBy": 'T001',
        "createdTime": '2024-01-11 14:30:00'
      } as Record<string, Object>);

      const mockData3 = new BatchFeedback({
        "feedbackId": 3,
        "courseId": courseId,
        "assignmentId": 1,
        "feedbackType": 'praise',
        "content": '代码结构清晰，模块划分合理',
        "usedCount": 8,
        "createdBy": 'T001',
        "createdTime": '2024-01-12 16:45:00'
      } as Record<string, Object>);

      return [mockData1, mockData2, mockData3];
    } catch (error) {
      console.error('获取常用反馈列表失败:', error);
      return [];
    }
  }

  /**
   * 批量应用反馈到多个提交
   * 对应后端: POST /api/v1/grading/batch-process
   */
  async applyBatchFeedback(
    assignmentId: number,
    submissionIds: number[],
    feedbackId: number
  ): Promise<boolean> {
    try {
      const request: BatchOperationRequest = {
        assignmentId,
        submissionIds,
        operation: 'apply_feedback',
        feedbackId
      };
      
      await this.http.post<void>(ApiConfig.BATCH_PROCESS, request);
      return true;
    } catch (error) {
      console.error('批量应用反馈失败:', error);
      return false;
    }
  }

  /**
   * 批量设置提交状态
   */
  async batchSetStatus(
    assignmentId: number,
    submissionIds: number[],
    status: string
  ): Promise<boolean> {
    try {
      const request: BatchOperationRequest = {
        assignmentId,
        submissionIds,
        operation: 'set_status',
        status
      };
      
      await this.http.post<void>(ApiConfig.BATCH_PROCESS, request);
      return true;
    } catch (error) {
      console.error('批量设置状态失败:', error);
      return false;
    }
  }
}

export const batchFeedbackService = new BatchFeedbackService();