package neu.software.evaluationfeedback.controller;

import neu.software.evaluationfeedback.dto.GradeRequestDTO;
import neu.software.evaluationfeedback.dto.SubmissionDetailDTO;
import neu.software.evaluationfeedback.entity.BatchFeedback;
import neu.software.evaluationfeedback.entity.Grade;
import neu.software.evaluationfeedback.service.GradingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 评价与反馈 (功能点第三部分)
 */
@RestController
@RequestMapping("/api/v1/grading")
public class GradingController {

    private final GradingService gradingService;

    @Autowired
    public GradingController(GradingService gradingService) {
        this.gradingService = gradingService;
    }

    /**
     * 功能点 3.1: 获取作业批改工具的作业列表
     * 根据作业ID，获取所有提交（包含学生信息和已有评分）
     * @param assignmentId 作业ID
     * @return 提交详情列表
     */
    @GetMapping("/assignment/{assignmentId}/submissions")
    public ResponseEntity<List<SubmissionDetailDTO>> getSubmissionsForGrading(
            @PathVariable Integer assignmentId) {

        List<SubmissionDetailDTO> submissions = gradingService.getSubmissionsForGrading(assignmentId);
        return ResponseEntity.ok(submissions);
    }

    /**
     * 功能点 3.1: 提交/更新评分
     * 教师在线查看作业后，提交评分、评语等
     * @param gradeRequest 评分请求
     * @return 保存后的评分对象
     */
    @PostMapping("/grade")
    public ResponseEntity<Grade> saveOrUpdateGrade(@RequestBody GradeRequestDTO gradeRequest) {
        if (gradeRequest.getSubmissionId() == null || gradeRequest.getTeacherId() == null) {
            return ResponseEntity.badRequest().build(); // 必须有提交ID和教师ID
        }
        Grade savedGrade = gradingService.saveOrUpdateGrade(gradeRequest);
        return ResponseEntity.status(HttpStatus.CREATED).body(savedGrade);
    }

    /**
     * 功能点 3.2: 获取批量反馈模板
     * @param assignmentId 作业ID
     * @return 批量反馈模板列表
     */
    @GetMapping("/assignment/{assignmentId}/batch-feedbacks")
    public ResponseEntity<List<BatchFeedback>> getBatchFeedbacks(@PathVariable Integer assignmentId) {
        List<BatchFeedback> feedbacks = gradingService.getBatchFeedbacks(assignmentId);
        return ResponseEntity.ok(feedbacks);
    }

    /**
     * 功能点 3.2: 添加新的批量反馈模板
     * @param feedback 新的反馈模板
     * @return 创建后的模板对象
     */
    @PostMapping("/batch-feedback")
    public ResponseEntity<BatchFeedback> addBatchFeedback(@RequestBody BatchFeedback feedback) {
        if (feedback.getAssignmentId() == null || feedback.getCreatedBy() == null || feedback.getContent() == null) {
            return ResponseEntity.badRequest().build();
        }
        BatchFeedback createdFeedback = gradingService.addBatchFeedback(feedback);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdFeedback);
    }
}