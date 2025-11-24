package neu.software.evaluationfeedback.Service;

import neu.software.evaluationfeedback.DTO.StudentRecommendationDTO;
import neu.software.evaluationfeedback.DTO.StudentStatsDTO;
import neu.software.evaluationfeedback.Entity.User;
import neu.software.evaluationfeedback.Mapper.GradeMapper;
import neu.software.evaluationfeedback.Mapper.SubmissionMapper;
import neu.software.evaluationfeedback.Mapper.TeacherRecommendedStudentMapper;
import neu.software.evaluationfeedback.Mapper.UserMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@Service
public class StudentRecommendationServiceImpl implements StudentRecommendationService {
    
    private final UserMapper userMapper;
    private final TeacherRecommendedStudentMapper recommendMapper;
    private final SubmissionMapper submissionMapper;
    private final GradeMapper gradeMapper;
    
    @Autowired
    public StudentRecommendationServiceImpl(UserMapper userMapper, 
                                            TeacherRecommendedStudentMapper recommendMapper,
                                            SubmissionMapper submissionMapper,
                                            GradeMapper gradeMapper) {
        this.userMapper = userMapper;
        this.recommendMapper = recommendMapper;
        this.submissionMapper = submissionMapper;
        this.gradeMapper = gradeMapper;
    }
    
    @Override
    public List<User> getCourseStudents(String courseId) {
        return userMapper.findCourseStudents(courseId);
    }
    
    @Override
    public boolean recommendStudent(StudentRecommendationDTO dto) {
        String id = UUID.randomUUID().toString();
        int rows = recommendMapper.insert(id, dto.getTeacherId(), dto.getStudentId(), 
                                         dto.getCourseId(), dto.getRecommendReason());
        return rows > 0;
    }
    
    @Override
    public boolean cancelRecommendation(String teacherId, String studentId) {
        int rows = recommendMapper.delete(teacherId, studentId);
        return rows > 0;
    }
    
    @Override
    public List<User> getRecommendedStudents(String teacherId) {
        return userMapper.findRecommendedStudents(teacherId);
    }
    
    @Override
    public StudentStatsDTO getStudentStats(String studentId) {
        StudentStatsDTO stats = new StudentStatsDTO();
        // TODO: 实现统计逻辑
        stats.setTotalScore(BigDecimal.ZERO);
        stats.setRanking(0);
        stats.setCompletedTasks(0);
        stats.setPendingTasks(0);
        stats.setAverageScore(BigDecimal.ZERO);
        return stats;
    }
}
