// BatchOperationRequest.java
package neu.software.evaluationfeedback.DTO;

import lombok.Data;
import java.math.BigDecimal;
import java.util.List;

@Data
public class BatchOperationRequest {
    private String operationType; // SCORE, COMMENT, ANNOTATION
    private List<String> submissionIds; // 修改为String类型
    private BigDecimal batchScore;
    private String batchComment;
    private List<String> commonIssues;
    private String feedbackId; // 添加feedbackId字段
}