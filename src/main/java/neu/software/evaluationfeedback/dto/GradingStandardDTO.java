// GradingStandardDTO.java
package neu.software.evaluationfeedback.dto;

import lombok.Data;
import neu.software.evaluationfeedback.entity.GradingItem;
import java.math.BigDecimal;
import java.util.Date;
import java.util.List;

@Data
public class GradingStandardDTO {
    private Integer standardId;
    private String assignmentId;
    private String name;
    private BigDecimal totalScore;
    private List<GradingItem> items;
    private Date createTime;
    private Date updateTime;

    // 扩展字段
    private String assignmentName;
    private BigDecimal currentTotal; // 当前各项总分
}