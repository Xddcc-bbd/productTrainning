package neu.software.evaluationfeedback.dto;

import neu.software.evaluationfeedback.entity.Submission;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 继承 Submission，并额外添加学生姓名
 */
@Data
@EqualsAndHashCode(callSuper = true)
public class SubmissionStudentDTO extends Submission {
    private String studentName;
}