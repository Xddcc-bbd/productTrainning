// GradingItem.java
package neu.software.evaluationfeedback.entity;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class GradingItem {
    private Integer itemId;
    private Integer standardId;
    private String name;
    private String description;
    private BigDecimal score;
    private BigDecimal weight;
}