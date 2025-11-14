package neu.software.evaluationfeedback.service;

import neu.software.evaluationfeedback.dto.GradeRequestDTO;
import neu.software.evaluationfeedback.dto.SubmissionDetailDTO;
import neu.software.evaluationfeedback.dto.SubmissionStudentDTO;
import neu.software.evaluationfeedback.mapper.BatchFeedbackMapper;
import neu.software.evaluationfeedback.mapper.GradeMapper;
import neu.software.evaluationfeedback.mapper.SubmissionMapper;
import neu.software.evaluationfeedback.entity.BatchFeedback;
import neu.software.evaluationfeedback.entity.Grade;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class GradingServiceImpl implements GradingService {

    private final SubmissionMapper submissionMapper;
    private final GradeMapper gradeMapper;
    private final BatchFeedbackMapper batchFeedbackMapper;

    @Autowired
    public GradingServiceImpl(SubmissionMapper submissionMapper, GradeMapper gradeMapper, BatchFeedbackMapper batchFeedbackMapper) {
        this.submissionMapper = submissionMapper;
        this.gradeMapper = gradeMapper;
        this.batchFeedbackMapper = batchFeedbackMapper;
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
}