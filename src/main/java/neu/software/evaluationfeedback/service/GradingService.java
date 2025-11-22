package neu.software.evaluationfeedback.service;

import neu.software.evaluationfeedback.dto.*;
import neu.software.evaluationfeedback.entity.*;

import java.util.List;
public interface GradingService {
    /**
     * 获取待批改的作业列表详情
     * @param assignmentId 作业ID
     * @return 列表，包含提交、学生和已有评分信息
     */
    List<SubmissionDetailDTO> getSubmissionsForGrading(String assignmentId);

    /**
     * 保存或更新评分
     * @param gradeRequest 评分请求
     * @return 保存后的 Grade 对象
     */
    Grade saveOrUpdateGrade(GradeRequestDTO gradeRequest);

    /**
     * 获取作业的批量反馈模板
     * @param assignmentId 作业ID
     * @return 模板列表
     */
    List<BatchFeedback> getBatchFeedbacks(String assignmentId);

    /**
     * 添加新的批量反馈模板
     * @param feedback 模板对象
     * @return 添加后的模板对象
     */
    BatchFeedback addBatchFeedback(BatchFeedback feedback);

    List<AssignmentDTO> getAssignments(String assignmentId, String status);
    GradingStandard getGradingStandard(String assignmentId);
    GradingStandard saveGradingStandard(GradingStandard standard);
    List<Annotation> getAnnotations(String submissionId);
    Annotation addAnnotation(Annotation annotation);
    boolean batchProcess(BatchOperationRequest request);
    AIGradingResult getAIGrading(String submissionId);
    boolean markAsRecommended(String submissionId, Boolean isRecommended);
    // 在GradingService.java中添加
    /**
     * 获取作业基本信息
     */
    Assignment getAssignmentById(String assignmentId);

    /**
     * 获取教师的所有作业列表
     */
    List<Assignment> getAssignmentsByTeacher(String teacherId);

    /**
     * 创建新作业
     */
    Assignment createAssignment(Assignment assignment);

    /**
     * 更新作业
     */
    Assignment updateAssignment(Assignment assignment);

    /**
     * 删除作业
     */
    boolean deleteAssignment(String assignmentId);

    /**
     * 应用批量反馈到多个作业
     */
    boolean applyBatchFeedback(BatchOperationRequest request);

    /**
     * 删除批量反馈模板
     */
    boolean deleteBatchFeedback(String feedbackId);

    /**
     * 删除批注
     */
    boolean deleteAnnotation(String annotationId);
}
