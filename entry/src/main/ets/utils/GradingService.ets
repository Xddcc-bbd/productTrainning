
import { Assignment, AssignmentStatus, Annotation, AnnotationType, Comment, CommentType, GradingStandard, BatchOperation, GradingItem } from '../models/GradingModels';

/**
 * AI评分结果接口
 */
export interface AIGradingResult {
  score: number;
  comment: string;
}

/**
 * 评分服务类 - 处理作业批改相关业务逻辑
 */
export class GradingService {
  private static instance: GradingService;
  
  private constructor() {}
  
  static getInstance(): GradingService {
    if (!GradingService.instance) {
      GradingService.instance = new GradingService();
    }
    return GradingService.instance;
  }
  /**
   * 获取作业列表
   */
  async getAssignments(taskId: string): Promise<Assignment[]> {
    // 模拟数据，实际应该从API获取
    const assignment1 = new Assignment();
    assignment1.id = '1';
    assignment1.taskId = taskId;
    assignment1.studentId = 's1';
    assignment1.studentName = '张三';
    assignment1.title = '积木搭建作品1';
    assignment1.submitTime = '2024-01-15 10:30:00';
    assignment1.status = AssignmentStatus.SUBMITTED;
    assignment1.score = 0;
    assignment1.maxScore = 100;
    assignment1.workUrl = '';
    assignment1.isRecommended = false;
    assignment1.gradingStandardId = 'std1';

    const assignment2 = new Assignment();
    assignment2.id = '2';
    assignment2.taskId = taskId;
    assignment2.studentId = 's2';
    assignment2.studentName = '李四';
    assignment2.title = '积木搭建作品2';
    assignment2.submitTime = '2024-01-15 11:20:00';
    assignment2.status = AssignmentStatus.GRADING;
    assignment2.score = 85;
    assignment2.maxScore = 100;
    assignment2.workUrl = '';
    assignment2.isRecommended = false;
    assignment2.gradingStandardId = 'std1';

    const assignment3 = new Assignment();
    assignment3.id = '3';
    assignment3.taskId = taskId;
    assignment3.studentId = 's3';
    assignment3.studentName = '王五';
    assignment3.title = '积木搭建作品3';
    assignment3.submitTime = '2024-01-14 09:15:00';
    assignment3.status = AssignmentStatus.GRADED;
    assignment3.score = 92;
    assignment3.maxScore = 100;
    assignment3.workUrl = '';
    assignment3.isRecommended = true;
    assignment3.gradingStandardId = 'std1';

    return [assignment1, assignment2, assignment3];
  }
  /**
   * 获取评分标准
   */
  async getGradingStandard(standardId: string): Promise<GradingStandard | null> {
    // 模拟数据
    if (standardId === 'std1') {
      const standard = new GradingStandard();
      standard.id = 'std1';
      standard.taskId = 'task1';
      standard.name = '积木作品评分标准';
      standard.totalScore = 100;
      
      const item1 = new GradingItem();
      item1.id = 'item1';
      item1.name = '创意性';
      item1.description = '作品的创新程度和独特性';
      item1.score = 30;
      item1.weight = 0.3;
      
      const item2 = new GradingItem();
      item2.id = 'item2';
      item2.name = '完成度';
      item2.description = '作品的完成程度和质量';
      item2.score = 40;
      item2.weight = 0.4;
      
      const item3 = new GradingItem();
      item3.id = 'item3';
      item3.name = '美观度';
      item3.description = '作品的外观和视觉效果';
      item3.score = 30;
      item3.weight = 0.3;
      
      standard.items = [item1, item2, item3];
      standard.createTime = '2024-01-01 00:00:00';
      standard.updateTime = '2024-01-01 00:00:00';
      
      return standard;
    }
    return null;
  }

  /**
   * 保存评分标准
   */
  async saveGradingStandard(standard: GradingStandard): Promise<boolean> {
    // 实际应该调用API保存
    console.log('保存评分标准:', JSON.stringify(standard));
    return true;
  }

  /**
   * 提交评分
   */
  async submitGrading(assignmentId: string, score: number, comment: string): Promise<boolean> {
    // 实际应该调用API提交
    console.log('提交评分:', assignmentId, score, comment);
    return true;
  }

  /**
   * 添加批注
   */
  async addAnnotation(annotation: Annotation): Promise<boolean> {
    // 实际应该调用API保存
    console.log('添加批注:', JSON.stringify(annotation));
    return true;
  }

  /**
   * 获取AI评分和评语
   */
  async getAIGrading(assignmentId: string, standardId: string): Promise<AIGradingResult> {
    // 模拟AI评分，实际应该调用AI API
    return {
      score: Math.floor(Math.random() * 20) + 80,
      comment: '这是一个优秀的作品，展现了良好的创意和完成度。建议在细节处理上可以更加精细。'
    };
  }

  /**
   * 标记为教师推荐
   */
  async markAsRecommended(assignmentId: string, isRecommended: boolean): Promise<boolean> {
    // 实际应该调用API
    console.log('标记教师推荐:', assignmentId, isRecommended);
    return true;
  }

  /**
   * 批量处理
   */
  async batchProcess(operation: BatchOperation): Promise<boolean> {
    // 实际应该调用API
    console.log('批量处理:', JSON.stringify(operation));
    return true;
  }
}

