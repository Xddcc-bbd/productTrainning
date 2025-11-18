// AssignmentMapper.java
package neu.software.evaluationfeedback.mapper;

import neu.software.evaluationfeedback.entity.Assignment;
import org.apache.ibatis.annotations.*;

import java.util.List;

@Mapper
public interface AssignmentMapper {

    /**
     * 根据ID查询作业
     */
    @Select("SELECT * FROM assignments WHERE assignment_id = #{assignmentId}")
    Assignment findById(Integer assignmentId);

    /**
     * 根据课程ID查询所有作业
     */
    @Select("SELECT * FROM assignments WHERE course_id = #{courseId} ORDER BY created_time DESC")
    List<Assignment> findByCourseId(Integer courseId);

    /**
     * 查询教师的所有作业
     */
    @Select("SELECT a.* FROM assignments a " +
            "JOIN courses c ON a.course_id = c.course_id " +
            "WHERE c.teacher_id = #{teacherId} " +
            "ORDER BY a.created_time DESC")
    List<Assignment> findByTeacherId(String teacherId);

    /**
     * 插入新作业
     */
    @Insert("INSERT INTO assignments (course_id, assignment_name, assignment_type, description, " +
            "full_score, grading_criteria, start_time, end_time, expected_duration, created_time) " +
            "VALUES (#{courseId}, #{assignmentName}, #{assignmentType}, #{description}, " +
            "#{fullScore}, #{gradingCriteria}, #{startTime}, #{endTime}, #{expectedDuration}, #{createdTime})")
    @Options(useGeneratedKeys = true, keyProperty = "assignmentId")
    int insert(Assignment assignment);

    /**
     * 更新作业
     */
    @Update("UPDATE assignments SET " +
            "assignment_name = #{assignmentName}, " +
            "assignment_type = #{assignmentType}, " +
            "description = #{description}, " +
            "full_score = #{fullScore}, " +
            "grading_criteria = #{gradingCriteria}, " +
            "start_time = #{startTime}, " +
            "end_time = #{endTime}, " +
            "expected_duration = #{expectedDuration} " +
            "WHERE assignment_id = #{assignmentId}")
    int update(Assignment assignment);

    /**
     * 删除作业
     */
    @Delete("DELETE FROM assignments WHERE assignment_id = #{assignmentId}")
    int delete(Integer assignmentId);
}