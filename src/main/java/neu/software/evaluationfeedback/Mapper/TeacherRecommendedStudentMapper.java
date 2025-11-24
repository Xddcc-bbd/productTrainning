package neu.software.evaluationfeedback.Mapper;

import org.apache.ibatis.annotations.*;

@Mapper
public interface TeacherRecommendedStudentMapper {
    
    /**
     * 推荐学生
     */
    @Insert("INSERT INTO teacher_recommended_students (id, teacher_id, student_id, course_id, recommend_reason, recommended_time) " +
            "VALUES (#{id}, #{teacherId}, #{studentId}, #{courseId}, #{recommendReason}, NOW())")
    int insert(@Param("id") String id, 
               @Param("teacherId") String teacherId, 
               @Param("studentId") String studentId, 
               @Param("courseId") String courseId, 
               @Param("recommendReason") String recommendReason);
    
    /**
     * 取消推荐
     */
    @Delete("DELETE FROM teacher_recommended_students WHERE teacher_id = #{teacherId} AND student_id = #{studentId}")
    int delete(@Param("teacherId") String teacherId, @Param("studentId") String studentId);
}
