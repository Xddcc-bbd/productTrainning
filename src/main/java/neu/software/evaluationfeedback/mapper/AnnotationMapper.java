// AnnotationMapper.java
package neu.software.evaluationfeedback.mapper;

import neu.software.evaluationfeedback.entity.Annotation;
import org.apache.ibatis.annotations.*;

import java.util.List;

@Mapper
public interface AnnotationMapper {

    @Select("SELECT * FROM annotations WHERE submission_id = #{submissionId} ORDER BY create_time DESC")
    List<Annotation> findBySubmissionId(String submissionId);

    @Insert("INSERT INTO annotations (annotation_id, submission_id, annotation_type, content, audio_url, position, create_time) " +
            "VALUES (#{annotationId}, #{submissionId}, #{annotationType}, #{content}, #{audioUrl}, #{position}, #{createTime})")
    int insert(Annotation annotation);

    @Delete("DELETE FROM annotations WHERE annotation_id = #{annotationId}")
    int delete(String annotationId);
}