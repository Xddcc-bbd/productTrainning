package neu.software.evaluationfeedback.entity;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.math.BigDecimal;
import java.util.Date;

/**
 * 对应 grades 表（作业批改表）
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Grade {
    private String gradeId;
    private String submissionId;
    private String teacherId;
    private BigDecimal score;
    private BigDecimal aiScore;
    private BigDecimal finalScore;
    private String textComment;
    private String aiTextComment;
    private String voiceCommentUrl;
    private Boolean isTeacherRecommended;
    private Date gradingTime;
    private Date createdTime;
}