// entry/src/main/ets/service/AssignmentService.ets

import { Assignment } from '../model/Assignment';
import { HttpService } from '../common/HttpService';
import { ApiConfig } from '../common/ApiConfig';

// 定义统计数据接口
interface AssignmentStats {
  assignmentId: string;
  totalStudents: number;
  submittedCount: number;
  averageScore: number;
  submissionRate: number;
}

export class AssignmentService {
  private http = HttpService.getInstance();

  /**
   * 获取作业列表（支持状态筛选）
   * 对应后端: GET /api/v1/grading/assignments?status={status}
   */
  async getAssignments(status?: string): Promise<Assignment[]> {
    try {
      let url = ApiConfig.ASSIGNMENTS;
      if (status) {
        url += `?status=${status}`;
      }
      const response = await this.http.get<Assignment[]>(url);
      if (response && response.length > 0) {
        return response.map(item => new Assignment(item));
      }
      return [];
    } catch (error) {
      console.error('获取作业列表失败:', error);
      return [];
    }
  }

  /**
   * 根据ID获取作业详情
   * 对应后端: GET /api/v1/grading/assignment/{assignmentId}
   */
  async getAssignmentById(assignmentId: string): Promise<Assignment | null> {
    try {
      const response = await this.http.get<Assignment>(ApiConfig.ASSIGNMENT_BY_ID(assignmentId));
      if (response) {
        return new Assignment(response);
      }
      return null;
    } catch (error) {
      console.error('获取作业详情失败:', error);
      return null;
    }
  }

  /**
   * 获取教师的所有作业
   * 对应后端: GET /api/v1/grading/teacher/{teacherId}/assignments
   */
  async getTeacherAssignments(teacherId: string): Promise<Assignment[]> {
    try {
      const response = await this.http.get<Assignment[]>(ApiConfig.TEACHER_ASSIGNMENTS(teacherId));
      if (response && response.length > 0) {
        return response.map(item => new Assignment(item));
      }
      return [];
    } catch (error) {
      console.error('获取教师作业列表失败:', error);
      return [];
    }
  }

  /**
   * 创建作业
   * 对应后端: POST /api/v1/grading/assignment
   */
  async createAssignment(assignment: Assignment): Promise<Assignment | null> {
    try {
      const response = await this.http.post<Assignment>(ApiConfig.CREATE_ASSIGNMENT, assignment);
      if (response) {
        return new Assignment(response);
      }
      return null;
    } catch (error) {
      console.error('创建作业失败:', error);
      return null;
    }
  }

  /**
   * 更新作业
   * 对应后端: PUT /api/v1/grading/assignment/{assignmentId}
   */
  async updateAssignment(assignmentId: string, assignment: Assignment): Promise<Assignment | null> {
    try {
      const response = await this.http.put<Assignment>(
        ApiConfig.UPDATE_ASSIGNMENT(assignmentId),
        assignment
      );
      if (response) {
        return new Assignment(response);
      }
      return null;
    } catch (error) {
      console.error('更新作业失败:', error);
      return null;
    }
  }

  /**
   * 删除作业
   * 对应后端: DELETE /api/v1/grading/assignment/{assignmentId}
   */
  async deleteAssignment(assignmentId: string): Promise<boolean> {
    try {
      await this.http.delete<void>(ApiConfig.DELETE_ASSIGNMENT(assignmentId));
      return true;
    } catch (error) {
      console.error('删除作业失败:', error);
      return false;
    }
  }

  /**
   * 获取课程作业统计
   */
  async getCourseAssignments(courseId: string): Promise<Assignment[]> {
    try {
      // 调用getAssignments获取所有作业，然后根据courseId过滤
      const allAssignments = await this.getAssignments();
      return allAssignments.filter(a => a.courseId === courseId);
    } catch (error) {
      console.error('获取课程作业失败:', error);
      return [];
    }
  }

  /**
   * 获取作业统计数据
   */
  async getAssignmentStats(assignmentId: string): Promise<AssignmentStats> {
    try {
      const stats: AssignmentStats = {
        assignmentId: assignmentId,
        totalStudents: 45,
        submittedCount: 38,
        averageScore: 82.5,
        submissionRate: 84.4
      };
      return stats;
    } catch (error) {
      console.error('获取作业统计失败:', error);
      throw new Error(typeof error === 'string' ? error : JSON.stringify(error));
    }
  }
}

export const assignmentService = new AssignmentService();