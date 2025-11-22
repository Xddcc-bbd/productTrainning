// entry/src/main/ets/service/StudentService.ets

import { Student } from '../model/Student';
import { HttpService } from '../common/HttpService';
import { ApiConfig } from '../common/ApiConfig';

// 后端返回的学生数据结构
interface StudentResponse {
  id: string;
  realName: string;
  className: string;
  major: string;
  ranking: number;
  enrollmentYear: number;
  email: string;
  phone: string;
  avatar: string;
}

// 学生统计接口
interface StudentStats {
  studentId: string;
  totalScore: number;
  ranking: number;
  completedTasks: number;
  pendingTasks: number;
  averageScore: number;
}

// 推荐请求DTO
interface RecommendRequestDTO {
  teacherId: string;
  studentId: string;
  courseId?: string;
  recommendReason: string;
}

export class StudentService {
  private http = HttpService.getInstance();

  /**
   * 获取学生列表
   * 对应后端: GET /api/v1/students/course/{courseId}
   */
  async getStudents(courseId: string): Promise<Student[]> {
    try {
      console.log(`🔍 请求课程 ${courseId} 的学生列表...`);
      
      const response = await this.http.get<StudentResponse[]>(
        ApiConfig.COURSE_STUDENTS(courseId)
      );
      
      if (response && response.length > 0) {
        console.log(`✅ 成功获取 ${response.length} 个学生`);
        
        return response.map(item => {
          const studentData = {
            "studentId": item.id,
            "realName": item.realName,
            "className": item.className || '',
            "major": item.major || '',
            "ranking": item.ranking || 0,
            "enrollmentYear": item.enrollmentYear || 0,
            "email": item.email || '',
            "phone": item.phone || '',
            "avatar": item.avatar || '',
            "totalScore": 0,
            "completedTasks": 0,
            "pendingTasks": 0,
            "isRecommended": false
          } as Record<string, Object>;
          return new Student(studentData);
        });
      }
      return [];
    } catch (error) {
      console.error('❌ 获取学生列表失败:', error);
      return [];
    }
  }

  /**
   * 获取学生详情
   */
  async getStudentById(studentId: string): Promise<Student> {
    try {
      console.log(`🔍 请求学生 ${studentId} 的详情...`);
      // 后端没有单独的获取学生详情接口，可以从列表中筛选
      return new Student();
    } catch (error) {
      console.error('❌ 获取学生详情失败:', error);
      return new Student();
    }
  }

  /**
   * 推荐学生
   * 对应后端: POST /api/v1/students/recommend
   */
  async recommendStudent(teacherId: string, studentId: string, reason: string): Promise<boolean> {
    try {
      console.log(`🔍 推荐学生: ${studentId}, 理由: ${reason}`);
      
      const request: RecommendRequestDTO = {
        teacherId: teacherId,
        studentId: studentId,
        recommendReason: reason
      };
      
      await this.http.post<boolean>(
        ApiConfig.RECOMMEND_STUDENT,
        request
      );
      
      console.log(`✅ 推荐学生成功`);
      return true;
    } catch (error) {
      console.error('❌ 推荐学生失败:', error);
      return false;
    }
  }

  /**
   * 取消推荐学生
   * 对应后端: DELETE /api/v1/students/recommend/{teacherId}/{studentId}
   */
  async cancelRecommendStudent(teacherId: string, studentId: string): Promise<boolean> {
    try {
      console.log(`🔍 取消推荐学生: ${studentId}`);
      
      await this.http.delete<boolean>(
        ApiConfig.CANCEL_RECOMMEND_STUDENT(teacherId, studentId)
      );
      
      console.log(`✅ 取消推荐成功`);
      return true;
    } catch (error) {
      console.error('❌ 取消推荐学生失败:', error);
      return false;
    }
  }

  /**
   * 获取推荐学生列表
   * 对应后端: GET /api/v1/students/recommended/{teacherId}
   */
  async getRecommendedStudents(teacherId: string): Promise<Student[]> {
    try {
      console.log(`🔍 请求教师 ${teacherId} 的推荐学生列表...`);
      
      const response = await this.http.get<StudentResponse[]>(
        ApiConfig.RECOMMENDED_STUDENTS(teacherId)
      );
      
      if (response && response.length > 0) {
        console.log(`✅ 成功获取 ${response.length} 个推荐学生`);
        
        return response.map(item => {
          const studentData = {
            "studentId": item.id,
            "realName": item.realName,
            "className": item.className || '',
            "major": item.major || '',
            "ranking": item.ranking || 0,
            "enrollmentYear": item.enrollmentYear || 0,
            "email": item.email || '',
            "phone": item.phone || '',
            "avatar": item.avatar || '',
            "isRecommended": true
          } as Record<string, Object>;
          return new Student(studentData);
        });
      }
      return [];
    } catch (error) {
      console.error('❌ 获取推荐学生列表失败:', error);
      return [];
    }
  }

  /**
   * 获取学生成绩统计
   * 对应后端: GET /api/v1/students/{studentId}/stats
   */
  async getStudentStats(studentId: string): Promise<StudentStats> {
    try {
      console.log(`🔍 请求学生 ${studentId} 的统计信息...`);
      
      const response = await this.http.get<StudentStats>(
        ApiConfig.STUDENT_STATS(studentId)
      );
      
      if (response) {
        console.log(`✅ 成功获取学生统计信息`);
        return response;
      }
      
      throw new Error('无法获取学生统计信息');
    } catch (error) {
      console.error('❌ 获取学生统计失败:', error);
      throw new Error(typeof error === 'string' ? error : JSON.stringify(error));
    }
  }
}

export const studentService = new StudentService();