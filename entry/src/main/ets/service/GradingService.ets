// entry/src/main/ets/service/GradingService.ets

import { Grade } from '../model/Grade';
import { Submission } from '../model/Submission';
import { HttpService } from '../common/HttpService';
import { ApiConfig } from '../common/ApiConfig';

// 定义后端返回的数据结构
interface SubmissionDetailDTO {
  submission: Submission;
  grade?: Grade;
  studentName: string;
}

interface GradeRequestDTO {
  submissionId: number;
  teacherId: string;
  score: number;
  textComment: string;
  voiceCommentUrl?: string;
  isTeacherRecommended: boolean;
}

interface AIGradingResult {
  aiScore: number;
  aiTextComment: string;
  suggestions: string[];
}

// 定义评分统计接口
interface GradingStats {
  totalSubmissions: number;
  gradedCount: number;
  avgScore: number;
  teacherRecommendedCount: number;
}

export class GradingService {
  private http = HttpService.getInstance();

  /**
   * 获取作业提交列表
   * 对应后端: GET /api/v1/grading/assignment/{assignmentId}/submissions
   */
  async getSubmissions(assignmentId: number): Promise<Submission[]> {
    try {
      const response = await this.http.get<SubmissionDetailDTO[]>(
        ApiConfig.SUBMISSIONS(assignmentId)
      );
      if (response && response.length > 0) {
        return response.map(item => new Submission(item.submission));
      }
      return [];
    } catch (error) {
      console.error('获取提交列表失败:', error);
      return [];
    }
  }

  /**
   * 提交/更新评分
   * 对应后端: POST /api/v1/grading/grade
   */
  async submitGrade(grade: Grade): Promise<Grade | null> {
    try {
      const gradeRequest: GradeRequestDTO = {
        submissionId: grade.submissionId,
        teacherId: grade.teacherId,
        score: grade.score,
        textComment: grade.textComment,
        voiceCommentUrl: grade.voiceCommentUrl,
        isTeacherRecommended: grade.isTeacherRecommended
      };
      
      const response = await this.http.post<Grade>(ApiConfig.SUBMIT_GRADE, gradeRequest);
      if (response) {
        return new Grade(response);
      }
      return null;
    } catch (error) {
      console.error('提交评分失败:', error);
      return null;
    }
  }

  /**
   * 更新评分（后端使用同一个接口）
   */
  async updateGrade(gradeId: number, grade: Grade): Promise<Grade | null> {
    return this.submitGrade(grade);
  }

  /**
   * 获取AI评分
   * 对应后端: GET /api/v1/grading/submission/{submissionId}/ai-grading
   */
  async getAIGrading(submissionId: number): Promise<AIGradingResult | null> {
    try {
      const response = await this.http.get<AIGradingResult>(
        ApiConfig.AI_GRADING(submissionId)
      );
      return response;
    } catch (error) {
      console.error('获取AI评分失败:', error);
      return null;
    }
  }

  /**
   * 获取评分详情
   */
  async getGradeDetail(submissionId: number): Promise<Grade> {
    try {
      const grade = new Grade({
        "gradeId": 1,
        "submissionId": submissionId,
        "teacherId": 'T001',
        "score": 95,
        "aiScore": 92,
        "finalScore": 95,
        "textComment": '代码逻辑清晰，实现完整',
        "aiTextComment": '语法正确，结构合理',
        "voiceCommentUrl": 'https://example.com/voice1',
        "isTeacherRecommended": true,
        "gradingTime": '2024-01-16 14:30:00',
        "createdTime": '2024-01-16 14:30:00'
      } as Record<string, Object>);

      return grade;
    } catch (error) {
      console.error('获取评分详情失败:', error);
      return new Grade();
    }
  }

  /**
   * 获取评分统计数据
   */
  async getGradingStats(assignmentId: number): Promise<GradingStats> {
    try {
      const stats: GradingStats = {
        totalSubmissions: 45,
        gradedCount: 38,
        avgScore: 82.5,
        teacherRecommendedCount: 5
      };
      return stats;
    } catch (error) {
      console.error('获取评分统计失败:', error);
      throw new Error(typeof error === 'string' ? error : JSON.stringify(error));
    }
  }

  /**
   * 标记为教师推荐
   * 对应后端: PUT /api/v1/grading/submission/{submissionId}/recommend
   */
  async markAsRecommended(submissionId: number): Promise<boolean> {
    try {
      await this.http.put<void>(
        ApiConfig.MARK_RECOMMEND(submissionId),
        { isRecommended: true }
      );
      return true;
    } catch (error) {
      console.error('标记推荐失败:', error);
      return false;
    }
  }

  /**
   * 取消教师推荐
   */
  async unmarkAsRecommended(submissionId: number): Promise<boolean> {
    try {
      await this.http.put<void>(
        ApiConfig.MARK_RECOMMEND(submissionId),
        { isRecommended: false }
      );
      return true;
    } catch (error) {
      console.error('取消推荐失败:', error);
      return false;
    }
  }
}

export const gradingService = new GradingService();