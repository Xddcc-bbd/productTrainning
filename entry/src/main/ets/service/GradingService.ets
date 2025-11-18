// entry/src/main/ets/service/GradingService.ets

import { HttpService } from '../common/HttpService';
import { Assignment } from '../model/Assignment';
import { Submission } from '../model/Submission';
import { Grade } from '../model/Grade';
import { BatchFeedback } from '../model/BatchFeedback';

// 定义AI评分结果接口
interface AIGradingResult {
  score: number;
  comment: string;
  suggestions: string[];
}

// 【修复关键点 1】Interface 不支持索引签名，改用 Type 定义 Record
type BatchProcessOptions = Record<string, Object>;

export class GradingService {
  private httpService: HttpService = HttpService.getInstance();

  /**
   * 获取作业列表
   */
  async getAssignments(teacherId: string): Promise<Assignment[]> {
    try {
      return this.getMockAssignments();
    } catch (error) {
      console.error('获取作业列表失败:', error);
      return this.getMockAssignments();
    }
  }

  /**
   * 获取作业详情
   */
  async getAssignmentById(assignmentId: number): Promise<Assignment> {
    try {
      const assignments = this.getMockAssignments();
      const assignment = assignments.find(item => item.assignmentId === assignmentId);
      return assignment || new Assignment();
    } catch (error) {
      console.error('获取作业详情失败:', error);
      return new Assignment();
    }
  }

  /**
   * 获取提交列表
   */
  async getSubmissions(assignmentId: number): Promise<Submission[]> {
    try {
      return this.getMockSubmissions();
    } catch (error) {
      console.error('获取提交列表失败:', error);
      return this.getMockSubmissions();
    }
  }

  /**
   * 保存评分
   */
  async saveGrade(gradeData: Grade): Promise<Grade> {
    try {
      console.log('保存评分:', gradeData);
      return new Grade(gradeData);
    } catch (error) {
      console.error('保存评分失败:', error);
      throw new Error(typeof error === 'string' ? error : JSON.stringify(error));
    }
  }

  /**
   * 更新评分
   */
  async updateGrade(gradeId: number, gradeData: Grade): Promise<Grade> {
    try {
      console.log('更新评分:', gradeId, gradeData);
      return new Grade(gradeData);
    } catch (error) {
      console.error('更新评分失败:', error);
      throw new Error(typeof error === 'string' ? error : JSON.stringify(error));
    }
  }

  /**
   * 获取批量反馈模板
   */
  async getBatchFeedbacks(assignmentId: number): Promise<BatchFeedback[]> {
    try {
      return this.getMockBatchFeedbacks();
    } catch (error) {
      console.error('获取批量反馈失败:', error);
      return this.getMockBatchFeedbacks();
    }
  }

  /**
   * 创建批量反馈模板
   */
  async createBatchFeedback(feedback: BatchFeedback): Promise<BatchFeedback> {
    try {
      console.log('创建批量反馈:', feedback);
      return new BatchFeedback(feedback);
    } catch (error) {
      console.error('创建批量反馈失败:', error);
      throw new Error(typeof error === 'string' ? error : JSON.stringify(error));
    }
  }

  /**
   * 标记为教师推荐
   */
  async markAsRecommended(submissionId: number, isRecommended: boolean): Promise<boolean> {
    try {
      console.log('标记推荐:', submissionId, isRecommended);
      return true;
    } catch (error) {
      console.error('标记推荐失败:', error);
      return false;
    }
  }

  /**
   * 获取AI评分
   */
  async getAIGrading(submissionId: number): Promise<AIGradingResult> {
    try {
      const result: AIGradingResult = {
        score: 85,
        comment: '这是一个AI生成的评语，代码结构良好，功能完整。',
        suggestions: ['建议优化代码注释', '可以增加错误处理机制']
      };
      return result;
    } catch (error) {
      console.error('获取AI评分失败:', error);
      throw new Error(typeof error === 'string' ? error : JSON.stringify(error));
    }
  }

  /**
   * 批量处理
   */
  // 使用定义好的 type
  async batchProcess(operationData: BatchProcessOptions): Promise<boolean> {
    try {
      console.log('批量处理:', operationData);
      return true;
    } catch (error) {
      console.error('批量处理失败:', error);
      return false;
    }
  }

  // 模拟数据方法
  private getMockAssignments(): Assignment[] {
    return [
      // 【修复关键点 2】全部使用 as Record<string, Object>
      new Assignment({
        assignmentId: 1,
        assignmentName: '积木编程任务1',
        courseId: 101,
        courseName: 'Java程序设计',
        studentCount: 45,
        submittedCount: 38,
        startTime: '2024-01-01',
        endTime: '2024-01-15',
        status: 'in_progress'
      } as Record<string, Object>),
      new Assignment({
        assignmentId: 2,
        assignmentName: '数据结构实验',
        courseId: 102,
        courseName: '数据结构',
        studentCount: 50,
        submittedCount: 45,
        startTime: '2024-01-10',
        endTime: '2024-01-25',
        status: 'in_progress'
      } as Record<string, Object>)
    ];
  }

  private getMockSubmissions(): Submission[] {
    return [
      new Submission({
        submissionId: 1,
        assignmentId: 1,
        studentId: 'S001',
        studentName: '张三',
        submissionTime: '2024-01-10 14:30:00',
        contentUrl: '',
        status: 'submitted',
        actualDuration: 120,
        isLate: false
      } as Record<string, Object>),
      new Submission({
        submissionId: 2,
        assignmentId: 1,
        studentId: 'S002',
        studentName: '李四',
        submissionTime: '2024-01-11 09:15:00',
        contentUrl: '',
        status: 'submitted',
        actualDuration: 95,
        isLate: false
      } as Record<string, Object>)
    ];
  }

  private getMockBatchFeedbacks(): BatchFeedback[] {
    return [
      new BatchFeedback({
        feedbackId: 1,
        courseId: 101,
        assignmentId: 1,
        feedbackType: 'common_issue',
        content: '请注意代码缩进和命名规范，变量名应具有描述性。',
        usedCount: 15,
        createdBy: 'T001',
        createdTime: '2024-01-01 10:00:00'
      } as Record<string, Object>),
      new BatchFeedback({
        feedbackId: 2,
        courseId: 101,
        assignmentId: 1,
        feedbackType: 'suggestion',
        content: '算法逻辑可以进一步优化，考虑时间复杂度和空间复杂度。',
        usedCount: 8,
        createdBy: 'T001',
        createdTime: '2024-01-02 14:30:00'
      } as Record<string, Object>)
    ];
  }
}

export const gradingService = new GradingService();