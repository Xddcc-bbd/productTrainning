package neu.software.evaluationfeedback;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("neu.software.evaluationfeedback.mapper") // 扫描MyBatis Mapper接口
public class EvaluationFeedbackApplication {

    public static void main(String[] args) {
        SpringApplication.run(EvaluationFeedbackApplication.class, args);
    }

}