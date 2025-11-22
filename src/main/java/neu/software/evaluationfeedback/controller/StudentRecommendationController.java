package neu.software.evaluationfeedback.controller;

import neu.software.evaluationfeedback.dto.StudentRecommendationDTO;
import neu.software.evaluationfeedback.dto.StudentStatsDTO;
import neu.software.evaluationfeedback.entity.User;
import neu.software.evaluationfeedback.service.StudentRecommendationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 学生推荐控制器
 */
@RestController
@RequestMapping("/api/v1/students")
public class StudentRecommendationController {

    private final StudentRecommendationService studentRecommendationService;

    @Autowired
    public StudentRecommendationController(StudentRecommendationService studentRecommendationService) {
        this.studentRecommendationService = studentRecommendationService;
    }

    /**
     * 获取课程学生列表
     */
    @GetMapping("/course/{courseId}")
    public ResponseEntity<List<User>> getCourseStudents(@PathVariable String courseId) {
        List<User> students = studentRecommendationService.getCourseStudents(courseId);
        return ResponseEntity.ok(students);
    }

    /**
     * 推荐优秀学生
     */
    @PostMapping("/recommend")
    public ResponseEntity<Boolean> recommendStudent(@RequestBody StudentRecommendationDTO dto) {
        boolean success = studentRecommendationService.recommendStudent(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(success);
    }

    /**
     * 取消推荐学生
     */
    @DeleteMapping("/recommend/{teacherId}/{studentId}")
    public ResponseEntity<Boolean> cancelRecommendation(
            @PathVariable String teacherId,
            @PathVariable String studentId) {
        boolean success = studentRecommendationService.cancelRecommendation(teacherId, studentId);
        return ResponseEntity.ok(success);
    }

    /**
     * 获取教师推荐的学生列表
     */
    @GetMapping("/recommended/{teacherId}")
    public ResponseEntity<List<User>> getRecommendedStudents(@PathVariable String teacherId) {
        List<User> students = studentRecommendationService.getRecommendedStudents(teacherId);
        return ResponseEntity.ok(students);
    }

    /**
     * 获取学生统计信息
     */
    @GetMapping("/{studentId}/stats")
    public ResponseEntity<StudentStatsDTO> getStudentStats(@PathVariable String studentId) {
        StudentStatsDTO stats = studentRecommendationService.getStudentStats(studentId);
        return ResponseEntity.ok(stats);
    }
}
