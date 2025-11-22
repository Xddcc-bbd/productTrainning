package neu.software.evaluationfeedback.dto;

import lombok.Data;

/**
 * 学生推荐DTO
 */
@Data
public class StudentRecommendationDTO {
    private String teacherId;
    private String studentId;
    private String courseId;
    private String recommendReason;
}
