package neu.software.evaluationfeedback.entity;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.util.Date;

/**
 * 对应 submissions 表（任务提交表）
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Submission {
    private Integer submissionId;
    private Integer assignmentId;
    private String studentId;
    private Integer teamId;
    private String contentUrl;
    private Date submissionTime;
    private String status;
    private Integer actualDuration;
    private Boolean isLate;
    private Date createdTime;
}