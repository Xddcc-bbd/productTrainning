package neu.software.evaluationfeedback.service;

import neu.software.evaluationfeedback.dto.StudentRecommendationDTO;
import neu.software.evaluationfeedback.dto.StudentStatsDTO;
import neu.software.evaluationfeedback.entity.User;

import java.util.List;

public interface StudentRecommendationService {
    
    /**
     * 获取课程学生列表
     */
    List<User> getCourseStudents(String courseId);
    
    /**
     * 推荐优秀学生
     */
    boolean recommendStudent(StudentRecommendationDTO dto);
    
    /**
     * 取消推荐学生
     */
    boolean cancelRecommendation(String teacherId, String studentId);
    
    /**
     * 获取教师推荐的学生列表
     */
    List<User> getRecommendedStudents(String teacherId);
    
    /**
     * 获取学生统计信息
     */
    StudentStatsDTO getStudentStats(String studentId);
}
