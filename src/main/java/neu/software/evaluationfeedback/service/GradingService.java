package neu.software.evaluationfeedback.service;

import neu.software.evaluationfeedback.dto.GradeRequestDTO;
import neu.software.evaluationfeedback.dto.SubmissionDetailDTO;
import neu.software.evaluationfeedback.entity.BatchFeedback;
import neu.software.evaluationfeedback.entity.Grade;

import java.util.List;
public interface GradingService {
    /**
     * 获取待批改的作业列表详情
     * @param assignmentId 作业ID
     * @return 列表，包含提交、学生和已有评分信息
     */
    List<SubmissionDetailDTO> getSubmissionsForGrading(Integer assignmentId);

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
    List<BatchFeedback> getBatchFeedbacks(Integer assignmentId);

    /**
     * 添加新的批量反馈模板
     * @param feedback 模板对象
     * @return 添加后的模板对象
     */
    BatchFeedback addBatchFeedback(BatchFeedback feedback);
}
