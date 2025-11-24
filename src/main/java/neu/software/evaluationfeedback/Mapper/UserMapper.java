package neu.software.evaluationfeedback.Mapper;

import neu.software.evaluationfeedback.Entity.User;
import org.apache.ibatis.annotations.*;

import java.util.List;

@Mapper
public interface UserMapper {
    
    /**
     * 获取课程学生列表
     */
    @Select("SELECT u.* FROM users u " +
            "JOIN course_students cs ON u.id = cs.student_id " +
            "WHERE cs.course_id = #{courseId} AND u.user_type = 0")
    List<User> findCourseStudents(String courseId);
    
    /**
     * 根据ID查询用户
     */
    @Select("SELECT * FROM users WHERE id = #{id}")
    User findById(String id);
    
    /**
     * 获取教师推荐的学生列表
     */
    @Select("SELECT u.* FROM users u " +
            "JOIN teacher_recommended_students trs ON u.id = trs.student_id " +
            "WHERE trs.teacher_id = #{teacherId}")
    List<User> findRecommendedStudents(String teacherId);
}
