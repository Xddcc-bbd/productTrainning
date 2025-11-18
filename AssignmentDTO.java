// AssignmentDTO.java
package neu.software.evaluationfeedback.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.util.Date;
import java.util.List;

@Data
public class AssignmentDTO {
    private Integer submissionId;
    private Integer assignmentId;
    private String studentId;
    private String studentName;
    private String title;
    private Date submitTime;
    private String status; // SUBMITTED, GRADING, GRADED, RETURNED
    private BigDecimal score;
    private BigDecimal maxScore;
    private String workUrl;
    private Boolean isRecommended;
    private Integer gradingStandardId;

    // 扩展字段
    private List<AnnotationDTO> annotations;
    private GradingStandardDTO gradingStandard;
}