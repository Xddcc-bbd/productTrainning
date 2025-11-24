package neu.software.evaluationfeedback.Mapper;

import neu.software.evaluationfeedback.Entity.BatchFeedback;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;

@Mapper
public interface BatchFeedbackMapper {

    /**
     * 根据作业ID查询所有批量反馈模板
     * (功能点 3.2)
     */
    @Select("SELECT * FROM batch_feedbacks WHERE assignment_id = #{assignmentId} ORDER BY used_count DESC")
    List<BatchFeedback> findByAssignmentId(String assignmentId);

    /**
     * 插入新的批量反馈
     */
    @Insert("INSERT INTO batch_feedbacks (feedback_id, course_id, assignment_id, feedback_type, content, created_by, created_time) " +
            "VALUES (#{feedbackId}, #{courseId}, #{assignmentId}, #{feedbackType}, #{content}, #{createdBy}, #{createdTime})")
    int insert(BatchFeedback feedback);

    /**
     * 更新使用次数 (示例，业务逻辑中调用)
     */
    @Update("UPDATE batch_feedbacks SET used_count = used_count + 1 WHERE feedback_id = #{feedbackId}")
    int incrementUsedCount(String feedbackId);

    /**
     * 删除批量反馈模板
     */
    @org.apache.ibatis.annotations.Delete("DELETE FROM batch_feedbacks WHERE feedback_id = #{feedbackId}")
    int delete(String feedbackId);
}