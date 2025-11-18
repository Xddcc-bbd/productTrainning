// BatchOperationRequest.java
package neu.software.evaluationfeedback.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.util.List;

@Data
public class BatchOperationRequest {
    private String operationType; // SCORE, COMMENT, ANNOTATION
    private List<Integer> submissionIds;
    private BigDecimal batchScore;
    private String batchComment;
    private List<String> commonIssues;
}