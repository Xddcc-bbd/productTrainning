// AnnotationMapper.java
package neu.software.evaluationfeedback.mapper;

import neu.software.evaluationfeedback.entity.Annotation;
import org.apache.ibatis.annotations.*;

import java.util.List;

@Mapper
public interface AnnotationMapper {

    @Select("SELECT * FROM annotations WHERE submission_id = #{submissionId} ORDER BY create_time DESC")
    List<Annotation> findBySubmissionId(Integer submissionId);

    @Insert("INSERT INTO annotations (submission_id, annotation_type, content, audio_url, position, create_time) " +
            "VALUES (#{submissionId}, #{annotationType}, #{content}, #{audioUrl}, #{position}, #{createTime})")
    @Options(useGeneratedKeys = true, keyProperty = "annotationId")
    int insert(Annotation annotation);

    @Delete("DELETE FROM annotations WHERE annotation_id = #{annotationId}")
    int delete(Integer annotationId);
}