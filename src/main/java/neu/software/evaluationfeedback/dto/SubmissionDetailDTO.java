package neu.software.evaluationfeedback.dto;

import neu.software.evaluationfeedback.entity.Grade;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * API返回给前端的“待批改作业”详情
 * 包含提交信息、学生信息和已有的评分信息
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class SubmissionDetailDTO {

    // 提交和学生信息
    private SubmissionStudentDTO submissionInfo;

    // 对应的评分信息 (可能为 null，如果还没批改)
    private Grade gradeInfo;
}