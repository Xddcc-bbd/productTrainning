// AIGradingResult.java
package neu.software.evaluationfeedback.DTO;

import lombok.Data;
import java.math.BigDecimal;
import java.util.List;

@Data
public class AIGradingResult {
    private BigDecimal score;
    private String comment;
    private List<String> suggestions;
}