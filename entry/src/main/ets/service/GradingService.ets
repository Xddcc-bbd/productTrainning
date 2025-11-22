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

interface RecommendRequest {
  isRecommended: boolean;
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
      
      console.log(`📦 后端返回原始数据:`, JSON.stringify(response));
      
      if (response && response.length > 0) {
        console.log(`📊 处理 ${response.length} 个提交记录...`);
        
        const submissions = response.map((item, index) => {
          console.log(`  [原始数据 ${index}]:`, JSON.stringify(item));
          
          // 后端返回的是 submissionInfo 和 gradeInfo
          // studentName 在 submissionInfo 里面
          const sub = new Submission();
          sub.submissionId = item.submissionInfo.submissionId || '';
          sub.assignmentId = item.submissionInfo.assignmentId || '';
          sub.studentId = item.submissionInfo.studentId || '';
          sub.studentName = item.submissionInfo.studentName || '';  // 从studentInfo里获取
          sub.teamId = item.submissionInfo.teamId || '';
          sub.contentUrl = item.submissionInfo.contentUrl || '';
          sub.contributionRate = item.submissionInfo.contributionRate || 1.0;
          sub.submissionTime = item.submissionInfo.submissionTime || '';
          sub.status = item.submissionInfo.status || 'submitted';
          sub.actualDuration = item.submissionInfo.actualDuration || 0;
          sub.isLate = item.submissionInfo.isLate || 0;
          sub.likeCount = item.submissionInfo.likeCount || 0;
          sub.favoriteCount = item.submissionInfo.favoriteCount || 0;
          sub.createdTime = item.submissionInfo.createdTime || '';
          
          console.log(`  [处理后 ${index}]: ID=${sub.submissionId}, 学生=${sub.studentName}, 学号=${sub.studentId}`);
          return sub;
        });
        
        console.log(`✅ 最终返回 ${submissions.length} 个 Submission 对象`);
        submissions.forEach((sub, idx) => {
          console.log(`  [${idx}] ID=${sub.submissionId}, 学生=${sub.studentName}, 学号=${sub.studentId}`);
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
   * 注意：后端没有单独的获取评分详情接口，需要通过submissions接口获取
   */
  async getGradeDetail(submissionId: string): Promise<Grade> {
    try {
      console.log(`🔍 获取评分详情: ${submissionId}`);
      
      // 从后端获取数据（需要先知道assignmentId）
      // 这里使用一个简化的方法：返回空的Grade对象，由页面从 submissions 数据中获取
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
   * 注意：后端没有这个接口，前端从 submissions 数据中计算
   */
  async getGradingStats(assignmentId: string): Promise<GradingStats> {
    try {
      console.log(`📊 计算评分统计: ${assignmentId}`);
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
   * 对应后端: PUT /api/v1/grading/submission/{submissionId}/recommend?isRecommended=true
   */
  async markAsRecommended(submissionId: string): Promise<boolean> {
    try {
      const emptyRequest: EmptyRequest = {};
      await this.http.put<boolean>(
        ApiConfig.MARK_RECOMMEND(submissionId, true),
        emptyRequest
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
  async unmarkAsRecommended(submissionId: string): Promise<boolean> {
    try {
      const emptyRequest: EmptyRequest = {};
      await this.http.put<boolean>(
        ApiConfig.MARK_RECOMMEND(submissionId, false),
        emptyRequest
      );
      return true;
    } catch (error) {
      console.error('取消推荐失败:', error);
      return false;
    }
  }
}

export const gradingService = new GradingService();