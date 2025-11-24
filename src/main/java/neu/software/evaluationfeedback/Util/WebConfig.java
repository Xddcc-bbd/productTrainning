package neu.software.evaluationfeedback.Util;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    /**
     * 配置CORS以允许前端应用访问
     */
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**") // 允许 /api/ 路径下的所有请求
                .allowedOrigins("*")   // 允许来自任何源的请求（在生产环境中应指定前端IP）
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS") // 允许的HTTP方法
                .allowedHeaders("*")   // 允许所有请求头
                .allowCredentials(false)
                .maxAge(3600);
    }
}