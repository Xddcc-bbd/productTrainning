package neu.software.evaluationfeedback.Service;

import neu.software.evaluationfeedback.DTO.*;
import neu.software.evaluationfeedback.Entity.*;
import neu.software.evaluationfeedback.Mapper.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.*;
import java.util.stream.Collectors;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.core.type.TypeReference;

@Service
public class GradingServiceImpl implements GradingService {

    private final SubmissionMapper submissionMapper;
    private final GradeMapper gradeMapper;
    private final BatchFeedbackMapper batchFeedbackMapper;
    private final AnnotationMapper annotationMapper;
    private final AssignmentMapper assignmentMapper;
    private final UserMapper userMapper;
    private final ObjectMapper objectMapper;

    @Autowired
    public GradingServiceImpl(SubmissionMapper submissionMapper, GradeMapper gradeMapper, BatchFeedbackMapper batchFeedbackMapper, AnnotationMapper annotationMapper, AssignmentMapper assignmentMapper, UserMapper userMapper, ObjectMapper objectMapper) {
        this.submissionMapper = submissionMapper;
        this.gradeMapper = gradeMapper;
        this.batchFeedbackMapper = batchFeedbackMapper;
        this.annotationMapper = annotationMapper;
        this.assignmentMapper = assignmentMapper;
        this.userMapper = userMapper;
        this.objectMapper = objectMapper;
    }


    @Override
    public List<SubmissionDetailDTO> getSubmissionsForGrading(String assignmentId) {
        try {
            // 1. 查询所有提交和学生信息
            List<Submission> submissions = submissionMapper.findSubmissionsWithStudentByAssignmentId(assignmentId);
            
            if (submissions == null || submissions.isEmpty()) {
                return new java.util.ArrayList<>();
            }

            // 2. 遍历列表，为每个提交查询对应的评分
            return submissions.stream()
                    .map(submission -> {
                        try {
                            // 创建DTO并设置学生名（暂时使用student_id）
                            SubmissionStudentDTO dto = new SubmissionStudentDTO();
                            dto.setSubmissionId(submission.getSubmissionId());
                            dto.setAssignmentId(submission.getAssignmentId());
                            dto.setStudentId(submission.getStudentId());
                            dto.setTeamId(submission.getTeamId());
                            dto.setContentUrl(submission.getContentUrl());
                            dto.setSubmissionTime(submission.getSubmissionTime());
                            dto.setStatus(submission.getStatus());
                            dto.setActualDuration(submission.getActualDuration());
                            dto.setIsLate(submission.getIsLate());
                            dto.setCreatedTime(submission.getCreatedTime());
                            dto.setScore(submission.getScore());
                            dto.setStudentName(submission.getStudentId()); // 暂时使用student_id

                            // 3. 查询该提交是否已有评分
                            Grade grade = gradeMapper.findBySubmissionId(submission.getSubmissionId());

                            // ⭐ 关键修改：从 grades 表获取评分
                            if (grade != null && grade.getFinalScore() != null) {
                                dto.setScore(grade.getFinalScore());
                                //System.out.println("✅ 找到评分: submission=" + submission.getSubmissionId() + ", score=" + grade.getFinalScore());
                            } else {
                                dto.setScore(null);  // 未评分则设为null
                                //System.out.println("⚠️ 未找到评分: submission=" + submission.getSubmissionId());
                            }
                            // 4. 组装成 DTO
                            return new SubmissionDetailDTO(dto, grade);
                        } catch (Exception e) {
                            e.printStackTrace();
                            SubmissionStudentDTO dto = new SubmissionStudentDTO();
                            dto.setSubmissionId(submission.getSubmissionId());
                            dto.setStudentName(submission.getStudentId());
                            return new SubmissionDetailDTO(dto, null);
                        }
                    })
                    .collect(Collectors.toList());
        } catch (Exception e) {
            e.printStackTrace();
            return new java.util.ArrayList<>();
        }
    }

    @Override
    @Transactional // 保证操作的原子性
    public Grade saveOrUpdateGrade(GradeRequestDTO gradeRequest) {
        // 打印日志,帮助排查问题
        System.out.println("收到评分请求 - submissionId: " + gradeRequest.getSubmissionId() + ", teacherId: [" + gradeRequest.getTeacherId() + "], 长度: " + (gradeRequest.getTeacherId() != null ? gradeRequest.getTeacherId().length() : "null"));
        
        // 验证teacherId是否存在
        if (gradeRequest.getTeacherId() != null) {
            User teacher = userMapper.findById(gradeRequest.getTeacherId());
            if (teacher == null) {
                System.err.println("错误: 在users表中找不到teacherId=[" + gradeRequest.getTeacherId() + "]");
                throw new IllegalArgumentException("教师ID不存在: " + gradeRequest.getTeacherId());
            } else {
                System.out.println("找到教师: " + teacher.getRealName());
            }
        }
        
        // 1. 检查是否已存在评分
        Grade existingGrade = gradeMapper.findBySubmissionId(gradeRequest.getSubmissionId());

        Date now = new Date();

        if (existingGrade != null) {
            // 2. 更新
            // 只有当传入了新的teacherId时才更新,否则保持原值
            if (gradeRequest.getTeacherId() != null) {
                existingGrade.setTeacherId(gradeRequest.getTeacherId());
            }
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
            newGrade.setGradeId(java.util.UUID.randomUUID().toString());
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
    public List<BatchFeedback> getBatchFeedbacks(String assignmentId) {
        return batchFeedbackMapper.findByAssignmentId(assignmentId);
    }

    @Override
    public BatchFeedback addBatchFeedback(BatchFeedback feedback) {
        feedback.setCreatedTime(new Date());
        feedback.setFeedbackId(java.util.UUID.randomUUID().toString());
        // 可以在这里设置 feedback的 courseId (如果前端没传)
        // feedback.setCourseId(...);
        batchFeedbackMapper.insert(feedback);
        return feedback;
    }

    @Override
    public List<AssignmentDTO> getAssignments(String assignmentId, String status) {
        List<Submission> submissions = submissionMapper.findSubmissionsWithStudentByAssignmentId(assignmentId);

        return submissions.stream().map(submission -> {
            AssignmentDTO dto = new AssignmentDTO();
            dto.setSubmissionId(submission.getSubmissionId());
            dto.setAssignmentId(submission.getAssignmentId());
            dto.setStudentId(submission.getStudentId());
            
            // 从users表查询学生真实姓名
            User student = userMapper.findById(submission.getStudentId());
            if (student != null) {
                dto.setStudentName(student.getRealName() != null ? student.getRealName() : submission.getStudentId());
            } else {
                dto.setStudentName(submission.getStudentId());
            }
            
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

            return dto;
        }).collect(Collectors.toList());
    }

    private String mapStatus(String dbStatus) {
        if (dbStatus == null) return "SUBMITTED";
        return switch (dbStatus) {
            case "submitted" -> "SUBMITTED";
            case "grading" -> "GRADING";
            case "graded" -> "GRADED";
            case "returned" -> "RETURNED";
            case "late" -> "LATE";
            default -> "SUBMITTED";
        };
    }

    @Override
    public GradingStandard getGradingStandard(String assignmentId) {
        Assignment assignment = assignmentMapper.findById(assignmentId);

        GradingStandard standard = new GradingStandard();
        standard.setAssignmentId(assignmentId);

        if (assignment == null) {
            // 如果作业不存在，返回默认的空评分标准
            standard.setName("评分标准");
            standard.setTotalScore(new BigDecimal("100.00"));
            standard.setItems(new java.util.ArrayList<>());
            return standard;
        }

        standard.setName("评分标准");
        standard.setTotalScore(assignment.getFullScore());
        java.util.List<GradingItem> items = new java.util.ArrayList<>();

        try {
            ObjectMapper mapper = new ObjectMapper();
            java.util.List<java.util.Map<String,Object>> arr = mapper.readValue(
                    assignment.getGradingCriteria(),
                    new TypeReference<java.util.List<java.util.Map<String,Object>>>(){}
            );
            for (java.util.Map<String,Object> m : arr) {
                GradingItem item = new GradingItem();
                item.setName((String) m.get("name"));
                Object sc = m.get("score");
                if (sc != null) item.setScore(new BigDecimal(sc.toString()));
                items.add(item);
            }
        } catch (Exception e) {
            // 解析错误时返回空列表
            System.err.println("解析评分标准失败: " + e.getMessage());
        }

        standard.setItems(items);
        return standard;
    }

    @Override
    @Transactional
    public GradingStandard saveGradingStandard(GradingStandard standard) {
        try {
            Assignment assignment = assignmentMapper.findById(standard.getAssignmentId());
            if (assignment != null) {
                // 直接将items转换为简化的JSON数组格式
                ObjectMapper mapper = new ObjectMapper();
                List<Map<String, Object>> simpleItems = new ArrayList<>();

                for (GradingItem item : standard.getItems()) {
                    Map<String, Object> simpleItem = new HashMap<>();
                    simpleItem.put("name", item.getName());
                    simpleItem.put("score", item.getScore());
                    simpleItems.add(simpleItem);
                }

                String jsonStr = mapper.writeValueAsString(simpleItems);

                // 更新作业的grading_criteria字段
                assignment.setGradingCriteria(jsonStr);
                assignment.setFullScore(standard.getTotalScore());
                assignmentMapper.update(assignment);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return standard;
    }

    @Override
    public List<Annotation> getAnnotations(String submissionId) {
        return annotationMapper.findBySubmissionId(submissionId);
    }

    @Override
    public Annotation addAnnotation(Annotation annotation) {
        annotation.setCreateTime(new Date());
        annotation.setAnnotationId(java.util.UUID.randomUUID().toString());
        annotationMapper.insert(annotation);
        return annotation;
    }

    @Override
    @Transactional
    public boolean batchProcess(BatchOperationRequest request) {
        return false;
    }



    @Override
    public AIGradingResult getAIGrading(String submissionId) {
        // 模拟AI评分逻辑
        AIGradingResult result = new AIGradingResult();
        result.setScore(new BigDecimal("85.00"));
        result.setComment("这是一个AI生成的评语，代码结构良好，功能完整。");
        result.setSuggestions(Arrays.asList("建议优化代码注释", "可以增加错误处理机制"));
        return result;
    }

    @Override
    public boolean markAsRecommended(String submissionId, Boolean isRecommended) {
        Grade grade = gradeMapper.findBySubmissionId(submissionId);
        if (grade != null) {
            grade.setIsTeacherRecommended(isRecommended);
            gradeMapper.update(grade);
            return true;
        }
        return false;
    }
    @Override
    public Assignment getAssignmentById(String assignmentId) {
        return assignmentMapper.findById(assignmentId);
    }

    @Override
    public List<Assignment> getAssignmentsByTeacher(String teacherId) {
        return assignmentMapper.findByTeacherId(teacherId);
    }

    @Override
    public Assignment createAssignment(Assignment assignment) {
        assignment.setCreatedTime(new Date());
        assignment.setAssignmentId(java.util.UUID.randomUUID().toString());
        assignmentMapper.insert(assignment);
        return assignment;
    }

    @Override
    public Assignment updateAssignment(Assignment assignment) {
        assignmentMapper.update(assignment);
        return assignment;
    }

    @Override
    public boolean deleteAssignment(String assignmentId) {
        try {
            assignmentMapper.delete(assignmentId);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    @Override
    public boolean applyBatchFeedback(BatchOperationRequest request) {
        try {
            // 应用批量反馈到多个提交
            if (request.getSubmissionIds() != null && request.getFeedbackId() != null) {
                // TODO: 实现将反馈内容添加到指定提交的逻辑
                return true;
            }
            return false;
        } catch (Exception e) {
            return false;
        }
    }

    @Override
    public boolean deleteBatchFeedback(String feedbackId) {
        try {
            batchFeedbackMapper.delete(feedbackId);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    @Override
    public boolean deleteAnnotation(String annotationId) {
        try {
            annotationMapper.delete(annotationId);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
    @Override
    public List<Map<String, Object>> getGradingCriteriaList(String assignmentId) {
        Assignment assignment = assignmentMapper.findById(assignmentId);
        if (assignment == null || assignment.getGradingCriteria() == null) {
            return new ArrayList<>();
        }

        try {
            ObjectMapper mapper = new ObjectMapper();
            return mapper.readValue(
                    assignment.getGradingCriteria(),
                    new TypeReference<List<Map<String, Object>>>(){}
            );
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    @Override
    @Transactional
    public boolean saveGradingCriteriaList(String assignmentId, List<Map<String, Object>> criteria) {
        try {
            ObjectMapper mapper = new ObjectMapper();
            String json = mapper.writeValueAsString(criteria);

            Assignment assignment = assignmentMapper.findById(assignmentId);
            if (assignment != null) {
                assignment.setGradingCriteria(json);

                // 计算总分
                BigDecimal totalScore = criteria.stream()
                        .map(m -> {
                            Object scoreObj = m.get("score");
                            if (scoreObj instanceof Number) {
                                return new BigDecimal(scoreObj.toString());
                            }
                            return BigDecimal.ZERO;
                        })
                        .reduce(BigDecimal.ZERO, BigDecimal::add);

                assignment.setFullScore(totalScore);
                assignmentMapper.update(assignment);

               return true;
            }
            return false;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}