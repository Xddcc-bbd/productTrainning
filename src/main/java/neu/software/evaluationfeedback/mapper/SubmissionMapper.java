package neu.software.evaluationfeedback.mapper;

import neu.software.evaluationfeedback.dto.SubmissionStudentDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Result;
import org.apache.ibatis.annotations.Results;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface SubmissionMapper {

    /**
     * 根据作业ID，查询所有提交，并关联学生姓名
     * (功能点 3.1 的数据基础)
     */
    @Select("SELECT s.*, st.student_name " +
            "FROM submissions s " +
            "JOIN students st ON s.student_id = st.student_id " +
            "WHERE s.assignment_id = #{assignmentId} " +
            "ORDER BY s.submission_time DESC") // 按提交时间排序
    @Results({
            @Result(property = "submissionId", column = "submission_id"),
            @Result(property = "assignmentId", column = "assignment_id"),
            @Result(property = "studentId", column = "student_id"),
            @Result(property = "teamId", column = "team_id"),
            @Result(property = "contentUrl", column = "content_url"),
            @Result(property = "submissionTime", column = "submission_time"),
            @Result(property = "status", column = "status"),
            @Result(property = "actualDuration", column = "actual_duration"),
            @Result(property = "isLate", column = "is_late"),
            @Result(property = "createdTime", column = "created_time"),
            @Result(property = "studentName", column = "student_name") // 关联的字段
    })
    List<SubmissionStudentDTO> findSubmissionsWithStudentByAssignmentId(Integer assignmentId);
}