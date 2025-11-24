package neu.software.evaluationfeedback.entity;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.math.BigDecimal;
import java.util.Date;

/**
 * 对应 submissions 表（任务提交表）
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Submission {
    private String submissionId;
    private String assignmentId;
    private String studentId;
    private String teamId;  // 修改为String类型以匹配数据库varchar
    private String contentUrl;
    private BigDecimal contributionRate;
    private Date submissionTime;
    private String status;
    private Integer actualDuration;
    private Boolean isLate;
    private Integer likeCount;
    private Integer favoriteCount;
    private Date createdTime;
    private BigDecimal score; // 成绩
}