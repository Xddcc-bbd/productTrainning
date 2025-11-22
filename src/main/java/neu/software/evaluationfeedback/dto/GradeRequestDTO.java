package neu.software.evaluationfeedback.dto;

import lombok.Data;
import java.math.BigDecimal;

/**
 * 教师提交评分时使用的数据传输对象
 */
@Data
public class GradeRequestDTO {
    private String submissionId; // 必需，关联到具体的提交
    private String teacherId;     // 必需，谁批改的
    private BigDecimal finalScore; // 最终得分
    private String textComment;    // 文字评语
    private String voiceCommentUrl; // 语音评语URL
    private Boolean isTeacherRecommended; // 是否推荐

    // AI分数和评语通常是后端生成或传入的，这里假设在保存时也可能更新
    private BigDecimal aiScore;
    private String aiTextComment;
}