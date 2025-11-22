// GradingStandard.java
package neu.software.evaluationfeedback.entity;

import lombok.Data;
import java.math.BigDecimal;
import java.util.Date;
import java.util.List;

@Data
public class GradingStandard {
    private Integer standardId;
    private String assignmentId;
    private String name;
    private BigDecimal totalScore;
    private List<GradingItem> items;
    private Date createTime;
    private Date updateTime;
}