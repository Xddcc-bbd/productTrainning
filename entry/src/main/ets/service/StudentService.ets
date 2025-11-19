// entry/src/main/ets/service/StudentService.ets

import { Student } from '../model/Student';

// 定义学生统计接口
interface StudentStats {
  studentId: string;
  totalScore: number;
  ranking: number;
  completedTasks: number;
  pendingTasks: number;
  averageScore: number;
}

export class StudentService {
  /**
   * 获取学生列表
   */
  async getStudents(courseId: number): Promise<Student[]> {
    try {
      // 【修复】消除“未使用变量”警告
      console.log('Getting students for course:', courseId);
      return this.getMockStudents();
    } catch (error) {
      console.error('获取学生列表失败:', error);
      return this.getMockStudents();
    }
  }

  /**
   * 获取学生详情
   */
  async getStudentById(studentId: string): Promise<Student> {
    try {
      const students = this.getMockStudents();
      const student = students.find(item => item.studentId === studentId);
      return student || new Student();
    } catch (error) {
      console.error('获取学生详情失败:', error);
      return new Student();
    }
  }

  /**
   * 推荐学生
   */
  async recommendStudent(teacherId: string, studentId: string, reason: string): Promise<boolean> {
    try {
      console.log('推荐学生:', teacherId, studentId, reason);
      return true;
    } catch (error) {
      console.error('推荐学生失败:', error);
      return false;
    }
  }

  /**
   * 取消推荐学生
   */
  async cancelRecommendStudent(teacherId: string, studentId: string): Promise<boolean> {
    try {
      console.log('取消推荐学生:', teacherId, studentId);
      return true;
    } catch (error) {
      console.error('取消推荐学生失败:', error);
      return false;
    }
  }

  /**
   * 获取推荐学生列表
   */
  async getRecommendedStudents(teacherId: string): Promise<Student[]> {
    try {
      // 【修复】消除“未使用变量”警告
      console.log('Getting recommended students for teacher:', teacherId);
      const students = this.getMockStudents();
      return students.filter(student => student.isRecommended);
    } catch (error) {
      console.error('获取推荐学生列表失败:', error);
      return [];
    }
  }

  /**
   * 获取学生成绩统计
   */
  async getStudentStats(studentId: string): Promise<StudentStats> {
    try {
      const stats: StudentStats = {
        studentId: studentId,
        totalScore: 95,
        ranking: 1,
        completedTasks: 8,
        pendingTasks: 2,
        averageScore: 90.5
      };
      return stats;
    } catch (error) {
      console.error('获取学生统计失败:', error);
      throw new Error(typeof error === 'string' ? error : JSON.stringify(error));
    }
  }

  // 模拟数据
  private getMockStudents(): Student[] {
    return [
      // 使用 as Record<string, Object>
      new Student({
        "studentId": 'S001',
        "realName": '张三',
        "className": '计算机1班',
        "major": '计算机科学与技术',
        "totalScore": 95,
        "ranking": 1,
        "completedTasks": 8,
        "pendingTasks": 2,
        "isRecommended": true,
        "recommendationReason": '代码质量高，学习态度认真'
      } as Record<string, Object>),
      new Student({
        "studentId": 'S002',
        "realName": '李四',
        "className": '计算机1班',
        "major": '计算机科学与技术',
        "totalScore": 92,
        "ranking": 2,
        "completedTasks": 7,
        "pendingTasks": 3,
        "isRecommended": false
      } as Record<string, Object>)
    ];
  }
}

export const studentService = new StudentService();