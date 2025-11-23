package neu.software.evaluationfeedback.controller;

import neu.software.evaluationfeedback.dto.*;
import neu.software.evaluationfeedback.entity.*;
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
            @PathVariable String assignmentId) {
        try {
            List<SubmissionDetailDTO> submissions = gradingService.getSubmissionsForGrading(assignmentId);
            return ResponseEntity.ok(submissions);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
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
        try {
            Grade savedGrade = gradingService.saveOrUpdateGrade(gradeRequest);
            return ResponseEntity.status(HttpStatus.CREATED).body(savedGrade);
        } catch (IllegalArgumentException e) {
            // 记录错误信息
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * 功能点 3.2: 获取批量反馈模板
     * @param assignmentId 作业ID
     * @return 批量反馈模板列表
     */
    @GetMapping("/assignment/{assignmentId}/batch-feedbacks")
    public ResponseEntity<List<BatchFeedback>> getBatchFeedbacks(@PathVariable String assignmentId) {
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

    /**
     * 功能点 3.2: 应用批量反馈到多个作业
     * @param request 包含 feedbackId 和 submissionIds
     * @return 是否成功
     */
    @PostMapping("/batch-feedback/apply")
    public ResponseEntity<Boolean> applyBatchFeedback(@RequestBody BatchOperationRequest request) {
        boolean success = gradingService.applyBatchFeedback(request);
        return ResponseEntity.ok(success);
    }

    /**
     * 功能点 3.2: 删除批量反馈模板
     * @param feedbackId 反馈ID
     * @return 是否成功
     */
    @DeleteMapping("/batch-feedback/{feedbackId}")
    public ResponseEntity<Boolean> deleteBatchFeedback(@PathVariable String feedbackId) {
        boolean success = gradingService.deleteBatchFeedback(feedbackId);
        return ResponseEntity.ok(success);
    }
    /**
     * 获取作业列表（支持状态筛选）
     */
    @GetMapping("/assignments")
    public ResponseEntity<List<AssignmentDTO>> getAssignments(
            @RequestParam String assignmentId,
            @RequestParam(required = false) String status) {
        List<AssignmentDTO> assignments = gradingService.getAssignments(assignmentId, status);
        return ResponseEntity.ok(assignments);
    }

    /**
     * 批量操作接口
     */
    @PostMapping("/batch-process")
    public ResponseEntity<Boolean> batchProcess(@RequestBody BatchOperationRequest request) {
        boolean success = gradingService.batchProcess(request);
        return ResponseEntity.ok(success);
    }

    /**
     * 获取批注列表
     */
    @GetMapping("/submission/{submissionId}/annotations")
    public ResponseEntity<List<Annotation>> getAnnotations(@PathVariable String submissionId) {
        List<Annotation> annotations = gradingService.getAnnotations(submissionId);
        return ResponseEntity.ok(annotations);
    }

    /**
     * 添加批注
     */
    @PostMapping("/annotation")
    public ResponseEntity<Annotation> addAnnotation(@RequestBody Annotation annotation) {
        Annotation saved = gradingService.addAnnotation(annotation);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    /**
     * 删除批注
     */
    @DeleteMapping("/annotation/{annotationId}")
    public ResponseEntity<Boolean> deleteAnnotation(@PathVariable String annotationId) {
        boolean success = gradingService.deleteAnnotation(annotationId);
        return ResponseEntity.ok(success);
    }

    /**
     * 获取评分标准
     */
    @GetMapping("/assignment/{assignmentId}/grading-standard")
    public ResponseEntity<GradingStandard> getGradingStandard(@PathVariable String assignmentId) {
        GradingStandard standard = gradingService.getGradingStandard(assignmentId);
        return ResponseEntity.ok(standard);
    }

    /**
     * 保存评分标准
     */
    @PostMapping("/grading-standard")
    public ResponseEntity<GradingStandard> saveGradingStandard(@RequestBody GradingStandard standard) {
        GradingStandard saved = gradingService.saveGradingStandard(standard);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    /**
     * AI评分
     */
    @GetMapping("/submission/{submissionId}/ai-grading")
    public ResponseEntity<AIGradingResult> getAIGrading(@PathVariable String submissionId) {
        AIGradingResult result = gradingService.getAIGrading(submissionId);
        return ResponseEntity.ok(result);
    }

    /**
     * 标记为教师推荐
     */
    @PutMapping("/submission/{submissionId}/recommend")
    public ResponseEntity<Boolean> markAsRecommended(
            @PathVariable String submissionId,
            @RequestParam Boolean isRecommended) {
        boolean success = gradingService.markAsRecommended(submissionId, isRecommended);
        return ResponseEntity.ok(success);
    }
    /**
     * 获取作业基本信息
     */
    @GetMapping("/assignment/{assignmentId}")
    public ResponseEntity<Assignment> getAssignment(@PathVariable String assignmentId) {
        Assignment assignment = gradingService.getAssignmentById(assignmentId);
        return ResponseEntity.ok(assignment);
    }

    /**
     * 获取教师的所有作业
     */
    @GetMapping("/teacher/{teacherId}/assignments")
    public ResponseEntity<List<Assignment>> getTeacherAssignments(@PathVariable String teacherId) {
        List<Assignment> assignments = gradingService.getAssignmentsByTeacher(teacherId);
        return ResponseEntity.ok(assignments);
    }

    /**
     * 创建新作业
     */
    @PostMapping("/assignment")
    public ResponseEntity<Assignment> createAssignment(@RequestBody Assignment assignment) {
        Assignment created = gradingService.createAssignment(assignment);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    /**
     * 更新作业
     */
    @PutMapping("/assignment/{assignmentId}")
    public ResponseEntity<Assignment> updateAssignment(
            @PathVariable String assignmentId,
            @RequestBody Assignment assignment) {
        assignment.setAssignmentId(assignmentId);
        Assignment updated = gradingService.updateAssignment(assignment);
        return ResponseEntity.ok(updated);
    }

    /**
     * 删除作业
     */
    @DeleteMapping("/assignment/{assignmentId}")
    public ResponseEntity<Boolean> deleteAssignment(@PathVariable String assignmentId) {
        boolean success = gradingService.deleteAssignment(assignmentId);
        return ResponseEntity.ok(success);
    }
}