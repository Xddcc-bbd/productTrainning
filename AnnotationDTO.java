// AnnotationDTO.java
package neu.software.evaluationfeedback.dto;

import lombok.Data;
import java.util.Date;

@Data
public class AnnotationDTO {
    private Integer annotationId;
    private Integer submissionId;
    private String annotationType; // TEXT, VOICE, AI
    private String content;
    private String audioUrl;
    private String position; // JSON格式存储坐标
    private Date createTime;

    // 扩展字段，用于前端显示
    private String studentName;
    private String assignmentName;
}