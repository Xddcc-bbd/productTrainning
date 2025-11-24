// entry/src/main/ets/service/GradingService.ets

import { Grade } from '../model/Grade';
import { Submission } from '../model/Submission';
import { HttpService } from '../common/HttpService';
import { ApiConfig } from '../common/ApiConfig';

// 定义后端返回的数据结构
interface SubmissionDetailDTO {
  submissionInfo: Submission;  // 后端字段是submissionInfo
  gradeInfo?: Grade;           // 后端字段是gradeInfo
}

interface GradeRequestDTO {
  submissionId: string;
  teacherId: string;
  finalScore: number;
  textComment: string;
  voiceCommentUrl?: string;
  isTeacherRecommended: boolean;
  aiScore?: number;
  aiTextComment?: string;
}

interface AIGradingResult {
  aiScore: number;
  aiTextComment: string;
  suggestions: string[];
}

// 空请求体接口（用于PUT请求）
interface EmptyRequest {
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
  async getSubmissions(assignmentId: string): Promise<Submission[]> {
    try {
      console.log(`📦 请求提交列表: ${assignmentId}`);
      const response = await this.http.get<SubmissionDetailDTO[]>(
        ApiConfig.SUBMISSIONS(assignmentId)
      );

      // console.log(`📦 后端返回原始数据:`, JSON.stringify(response));

      if (response && response.length > 0) {
        console.log(`📊 处理 ${response.length} 个提交记录...`);

        const submissions = response.map((item: SubmissionDetailDTO, index: number): Submission => {
          // 使用类型安全的属性访问方式
          const submissionInfo = item.submissionInfo;
          const gradeInfo = item.gradeInfo;

          const sub = new Submission();
          sub.submissionId = submissionInfo.submissionId || '';
          sub.assignmentId = submissionInfo.assignmentId || '';
          sub.studentId = submissionInfo.studentId || '';
          sub.studentName = submissionInfo.studentName || '';
          sub.teamId = submissionInfo.teamId || '';
          sub.contentUrl = submissionInfo.contentUrl || '';
          sub.contributionRate = submissionInfo.contributionRate || 1.0;
          sub.submissionTime = submissionInfo.submissionTime || '';
          sub.status = submissionInfo.status || 'submitted';
          sub.actualDuration = submissionInfo.actualDuration || 0;
          // 后端返回的isLate是boolean，转换为number
          sub.isLate = submissionInfo.isLate ? 1 : 0;
          sub.likeCount = submissionInfo.likeCount || 0;
          sub.favoriteCount = submissionInfo.favoriteCount || 0;
          sub.createdTime = submissionInfo.createdTime || '';

          // 从gradeInfo中获取分数（如果已评分）
          sub.score = gradeInfo?.finalScore ?? gradeInfo?.score ?? undefined;

          return sub;
        });

        return submissions;
      }
      console.log('⚠️ 后端返回空数据');
      return [];
    } catch (error) {
      console.error('❌ 获取提交列表失败:', error);
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
        finalScore: grade.finalScore,
        textComment: grade.textComment,
        voiceCommentUrl: grade.voiceCommentUrl,
        isTeacherRecommended: grade.isTeacherRecommended === 1,
        aiScore: grade.aiScore,
        aiTextComment: grade.aiTextComment
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
  async updateGrade(gradeId: string, grade: Grade): Promise<Grade | null> {
    return this.submitGrade(grade);
  }

  /**
   * 获取AI评分
   * 对应后端: GET /api/v1/grading/submission/{submissionId}/aigrading
   */
  async getAIGrading(submissionId: string): Promise<AIGradingResult | null> {
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
  async getGradeDetail(submissionId: string): Promise<Grade> {
    try {
      console.log(`🔍 获取评分详情: ${submissionId}`);
      // 创建一个默认的Grade对象，实际逻辑依赖submissions列表
      const grade = new Grade({
        "submissionId": submissionId,
        "score": 0,
        "aiScore": 0,
        "finalScore": 0,
        "textComment": '',
        "aiTextComment": '',
        "isTeacherRecommended": 0
      } as Record<string, Object>);

      return grade;
    } catch (error) {
      console.error('❌ 获取评分详情失败:', error);
      return new Grade();
    }
  }

  /**
   * 获取评分统计数据
   */
  async getGradingStats(assignmentId: string): Promise<GradingStats> {
    try {
      // 这个功能应该由前端基于submissions数据计算
      const stats: GradingStats = {
        totalSubmissions: 0,
        gradedCount: 0,
        avgScore: 0,
        teacherRecommendedCount: 0
      };
      return stats;
    } catch (error) {
      console.error('❌ 获取评分统计失败:', error);
      throw new Error(typeof error === 'string' ? error : JSON.stringify(error));
    }
  }

  /**
   * 标记为教师推荐
   * 对应后端: PUT /api/v1/grading/submission/{submissionId}/recommend?isRecommended=true/false
   */
  async markAsRecommended(submissionId: string, isRecommended: boolean): Promise<boolean> {
    try {
      console.log(`🎯 更新推荐状态: ${submissionId} -> ${isRecommended}`);

      // PUT请求体为空，参数在URL中
      const emptyRequest: EmptyRequest = {};

      // 注意：ApiConfig.MARK_RECOMMEND 方法需要正确拼接 query 参数
      const response = await this.http.put<boolean>(
        ApiConfig.MARK_RECOMMEND(submissionId, isRecommended),
        emptyRequest
      );

      console.log(`✅ 推荐状态更新API响应:`, response);
      // 如果后端返回的是 boolean 值，直接返回；如果是 null/void 但没报错，也视为成功
      return response !== undefined ? response : true;
    } catch (error) {
      console.error('❌ 标记推荐失败:', error);
      return false;
    }
  }
}

// ⭐ 关键修复：导出实例化对象，解决 "no exported member" 报错
export const gradingService = new GradingService();