// Annotation.java
package neu.software.evaluationfeedback.entity;

import lombok.Data;
import java.util.Date;

@Data
public class Annotation {
    private Integer annotationId;
    private Integer submissionId;
    private String annotationType; // TEXT, VOICE, AI
    private String content;
    private String audioUrl;
    private String position; // JSON格式存储坐标 {x: 100, y: 200}
    private Date createTime;
}