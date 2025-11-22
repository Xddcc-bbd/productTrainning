package neu.software.evaluationfeedback.mapper;

import neu.software.evaluationfeedback.dto.SubmissionStudentDTO;
import neu.software.evaluationfeedback.entity.Submission;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface SubmissionMapper {

    /**
     * 根据作业ID，查询所有提交，并关联学生姓名
     * (功能点 3.1 的数据基础)
     */
    @Select("SELECT * FROM submissions WHERE assignment_id = #{assignmentId} ORDER BY submission_time DESC")
    List<Submission> findSubmissionsWithStudentByAssignmentId(String assignmentId);
}