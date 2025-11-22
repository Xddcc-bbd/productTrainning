package neu.software.evaluationfeedback.entity;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.util.Date;

/**
 * 对应 batch_feedbacks 表（批量反馈表）
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class BatchFeedback {
    private String feedbackId;
    private String courseId;
    private String assignmentId;
    private String feedbackType;
    private String content;
    private Integer usedCount;
    private String createdBy; // 教师ID
    private Date createdTime;
}