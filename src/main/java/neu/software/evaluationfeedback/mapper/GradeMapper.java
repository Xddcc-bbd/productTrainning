package neu.software.evaluationfeedback.mapper;

import neu.software.evaluationfeedback.entity.Grade;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Options;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

@Mapper
public interface GradeMapper {

    /**
     * 根据 submission_id 查询评分
     */
    @Select("SELECT * FROM grades WHERE submission_id = #{submissionId} LIMIT 1")
    Grade findBySubmissionId(Integer submissionId);

    /**
     * 插入一条新的评分记录
     */
    @Insert("INSERT INTO grades (submission_id, teacher_id, score, ai_score, final_score, " +
            "text_comment, ai_text_comment, voice_comment_url, is_teacher_recommended, " +
            "grading_time, created_time) " +
            "VALUES (#{submissionId}, #{teacherId}, #{score}, #{aiScore}, #{finalScore}, " +
            "#{textComment}, #{aiTextComment}, #{voiceCommentUrl}, #{isTeacherRecommended}, " +
            "#{gradingTime}, #{createdTime})")
    @Options(useGeneratedKeys = true, keyProperty = "gradeId")
    int insert(Grade grade);

    /**
     * 更新一条评分记录 (根据 grade_id)
     */
    @Update("UPDATE grades SET " +
            "teacher_id = #{teacherId}, " +
            "score = #{score}, " +
            "ai_score = #{aiScore}, " +
            "final_score = #{finalScore}, " +
            "text_comment = #{textComment}, " +
            "ai_text_comment = #{aiTextComment}, " +
            "voice_comment_url = #{voiceCommentUrl}, " +
            "is_teacher_recommended = #{isTeacherRecommended}, " +
            "grading_time = #{gradingTime} " +
            "WHERE grade_id = #{gradeId}")
    int update(Grade grade);
}