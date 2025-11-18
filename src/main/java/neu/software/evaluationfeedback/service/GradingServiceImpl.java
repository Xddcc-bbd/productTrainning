package neu.software.evaluationfeedback.service;

import neu.software.evaluationfeedback.dto.*;
import neu.software.evaluationfeedback.entity.*;
import neu.software.evaluationfeedback.mapper.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class GradingServiceImpl implements GradingService {

    private final SubmissionMapper submissionMapper;
    private final GradeMapper gradeMapper;
    private final BatchFeedbackMapper batchFeedbackMapper;
    private final AnnotationMapper annotationMapper;
    private final GradingStandardMapper gradingStandardMapper;
    private final AssignmentMapper assignmentMapper;

    @Autowired
    public GradingServiceImpl(SubmissionMapper submissionMapper, GradeMapper gradeMapper, BatchFeedbackMapper batchFeedbackMapper, AnnotationMapper annotationMapper, GradingStandardMapper gradingStandardMapper, AssignmentMapper assignmentMapper) {
        this.submissionMapper = submissionMapper;
        this.gradeMapper = gradeMapper;
        this.batchFeedbackMapper = batchFeedbackMapper;
        this.annotationMapper = annotationMapper;
        this.gradingStandardMapper = gradingStandardMapper;
        this.assignmentMapper = assignmentMapper;
    }

    private void updateScoreForSubmission(Integer submissionId, BigDecimal score) {
        Grade grade = gradeMapper.findBySubmissionId(submissionId);
        if (grade == null) {
            // 创建新评分记录
            grade = new Grade();
            grade.setSubmissionId(submissionId);
            grade.setFinalScore(score);
            grade.setGradingTime(new Date());
            gradeMapper.insert(grade);
        } else {
            grade.setFinalScore(score);
            grade.setGradingTime(new Date());
            gradeMapper.update(grade);
        }
    }
    @Override
    public List<SubmissionDetailDTO> getSubmissionsForGrading(Integer assignmentId) {
        // 1. 查询所有提交和学生信息
        List<SubmissionStudentDTO> submissions = submissionMapper.findSubmissionsWithStudentByAssignmentId(assignmentId);

        // 2. 遍历列表，为每个提交查询对应的评分 (N+1查询，但逻辑清晰)
        //    (如果性能要求高，可以在SQL层面优化，但MyBatis注解实现复杂)
        return submissions.stream()
                .map(submission -> {
                    // 3. 查询该提交是否已有评分
                    Grade grade = gradeMapper.findBySubmissionId(submission.getSubmissionId());
                    // 4. 组装成 DTO
                    return new SubmissionDetailDTO(submission, grade);
                })
                .collect(Collectors.toList());
    }

    @Override
    @Transactional // 保证操作的原子性
    public Grade saveOrUpdateGrade(GradeRequestDTO gradeRequest) {
        // 1. 检查是否已存在评分
        Grade existingGrade = gradeMapper.findBySubmissionId(gradeRequest.getSubmissionId());

        Date now = new Date();

        if (existingGrade != null) {
            // 2. 更新
            existingGrade.setTeacherId(gradeRequest.getTeacherId());
            existingGrade.setFinalScore(gradeRequest.getFinalScore());
            existingGrade.setTextComment(gradeRequest.getTextComment());
            existingGrade.setVoiceCommentUrl(gradeRequest.getVoiceCommentUrl());
            existingGrade.setIsTeacherRecommended(gradeRequest.getIsTeacherRecommended());
            existingGrade.setAiScore(gradeRequest.getAiScore()); // 允许教师修改AI评分
            existingGrade.setAiTextComment(gradeRequest.getAiTextComment()); // 允许教师修改AI评语
            existingGrade.setGradingTime(now); // 更新批改时间

            gradeMapper.update(existingGrade);
            return existingGrade;
        } else {
            // 3. 新增
            Grade newGrade = new Grade();
            newGrade.setSubmissionId(gradeRequest.getSubmissionId());
            newGrade.setTeacherId(gradeRequest.getTeacherId());
            newGrade.setFinalScore(gradeRequest.getFinalScore());
            newGrade.setTextComment(gradeRequest.getTextComment());
            newGrade.setVoiceCommentUrl(gradeRequest.getVoiceCommentUrl());
            newGrade.setIsTeacherRecommended(gradeRequest.getIsTeacherRecommended());
            newGrade.setAiScore(gradeRequest.getAiScore());
            newGrade.setAiTextComment(gradeRequest.getAiTextComment());
            // 假设教师评分 score 字段也等于 finalScore，或根据你的逻辑设置
            newGrade.setScore(gradeRequest.getFinalScore());
            newGrade.setGradingTime(now);
            newGrade.setCreatedTime(now);

            gradeMapper.insert(newGrade);
            return newGrade;
        }
    }

    @Override
    public List<BatchFeedback> getBatchFeedbacks(Integer assignmentId) {
        return batchFeedbackMapper.findByAssignmentId(assignmentId);
    }

    @Override
    public BatchFeedback addBatchFeedback(BatchFeedback feedback) {
        feedback.setCreatedTime(new Date());
        // 可以在这里设置 feedback的 courseId (如果前端没传)
        // feedback.setCourseId(...);
        batchFeedbackMapper.insert(feedback);
        return feedback;
    }

    @Override
    public List<AssignmentDTO> getAssignments(Integer assignmentId, String status) {
        List<SubmissionStudentDTO> submissions = submissionMapper.findSubmissionsWithStudentByAssignmentId(assignmentId);

        return submissions.stream().map(submission -> {
            AssignmentDTO dto = new AssignmentDTO();
            dto.setSubmissionId(submission.getSubmissionId());
            dto.setAssignmentId(submission.getAssignmentId());
            dto.setStudentId(submission.getStudentId());
            dto.setStudentName(submission.getStudentName());
            dto.setTitle("作业标题"); // 需要从assignments表获取
            dto.setSubmitTime(submission.getSubmissionTime());
            dto.setStatus(mapStatus(submission.getStatus()));
            dto.setWorkUrl(submission.getContentUrl());

            // 获取评分信息
            Grade grade = gradeMapper.findBySubmissionId(submission.getSubmissionId());
            if (grade != null) {
                dto.setScore(grade.getFinalScore());
                dto.setIsRecommended(grade.getIsTeacherRecommended());
            }

            // 设置满分
            dto.setMaxScore(new BigDecimal("100.00"));

            // 获取批注
            List<Annotation> annotations = annotationMapper.findBySubmissionId(submission.getSubmissionId());
            // 转换为AnnotationDTO列表...

            return dto;
        }).collect(Collectors.toList());
    }

    private String mapStatus(String dbStatus) {
        switch (dbStatus) {
            case "submitted": return "SUBMITTED";
            case "grading": return "GRADING";
            case "graded": return "GRADED";
            case "returned": return "RETURNED";
            default: return "SUBMITTED";
        }
    }

    @Override
    public GradingStandard getGradingStandard(Integer assignmentId) {
        GradingStandard standard = gradingStandardMapper.findByAssignmentId(assignmentId);
        if (standard != null) {
            List<GradingItem> items = gradingStandardMapper.findItemsByStandardId(standard.getStandardId());
            standard.setItems(items);
        }
        return standard;
    }

    @Override
    @Transactional
    public GradingStandard saveGradingStandard(GradingStandard standard) {
        Date now = new Date();
        standard.setUpdateTime(now);

        if (standard.getStandardId() == null) {
            standard.setCreateTime(now);
            gradingStandardMapper.insert(standard);
        } else {
            gradingStandardMapper.update(standard);
            // 删除原有items
            gradingStandardMapper.deleteItemsByStandardId(standard.getStandardId());
        }

        // 保存items
        for (GradingItem item : standard.getItems()) {
            item.setStandardId(standard.getStandardId());
            if (item.getItemId() == null) {
                gradingStandardMapper.insertItem(item);
            } else {
                gradingStandardMapper.updateItem(item);
            }
        }

        return standard;
    }

    @Override
    public List<Annotation> getAnnotations(Integer submissionId) {
        return annotationMapper.findBySubmissionId(submissionId);
    }

    @Override
    public Annotation addAnnotation(Annotation annotation) {
        annotation.setCreateTime(new Date());
        annotationMapper.insert(annotation);
        return annotation;
    }

    @Override
    @Transactional
    public boolean batchProcess(BatchOperationRequest request) {
        return false;
    }

    private void updateCommentForSubmission(Integer submissionId, String batchComment) {
    }

    private void addCommonIssues(Integer submissionId, List<String> commonIssues) {
    }

    @Override
    public AIGradingResult getAIGrading(Integer submissionId) {
        // 模拟AI评分逻辑
        AIGradingResult result = new AIGradingResult();
        result.setScore(new BigDecimal("85.00"));
        result.setComment("这是一个AI生成的评语，代码结构良好，功能完整。");
        result.setSuggestions(Arrays.asList("建议优化代码注释", "可以增加错误处理机制"));
        return result;
    }

    @Override
    public boolean markAsRecommended(Integer submissionId, Boolean isRecommended) {
        Grade grade = gradeMapper.findBySubmissionId(submissionId);
        if (grade != null) {
            grade.setIsTeacherRecommended(isRecommended);
            gradeMapper.update(grade);
            return true;
        }
        return false;
    }
    @Override
    public Assignment getAssignmentById(Integer assignmentId) {
        return assignmentMapper.findById(assignmentId);
    }

    @Override
    public List<Assignment> getAssignmentsByTeacher(String teacherId) {
        return assignmentMapper.findByTeacherId(teacherId);
    }

    @Override
    public Assignment createAssignment(Assignment assignment) {
        assignment.setCreatedTime(new Date());
        assignmentMapper.insert(assignment);
        return assignment;
    }

    @Override
    public Assignment updateAssignment(Assignment assignment) {
        assignmentMapper.update(assignment);
        return assignment;
    }

    @Override
    public boolean deleteAssignment(Integer assignmentId) {
        try {
            assignmentMapper.delete(assignmentId);
            return true;
        } catch (Exception e) {
            return false;
        }

}}