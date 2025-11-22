// Assignment.java (需要创建)
package neu.software.evaluationfeedback.entity;

import lombok.Data;
import java.math.BigDecimal;
import java.util.Date;

@Data
public class Assignment {
    private String assignmentId;
    private String courseId;
    private String assignmentName;
    private Integer assignmentType;
    private String description;
    private BigDecimal fullScore;
    private String gradingCriteria; // JSON格式
    private Date startTime;
    private Date endTime;
    private Integer expectedDuration;
    private Date createdTime;
}