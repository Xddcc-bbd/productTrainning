package neu.software.evaluationfeedback.dto;

import lombok.Data;
import java.math.BigDecimal;

/**
 * 学生统计信息DTO
 */
@Data
public class StudentStatsDTO {
    private BigDecimal totalScore;
    private Integer ranking;
    private Integer completedTasks;
    private Integer pendingTasks;
    private BigDecimal averageScore;
}
