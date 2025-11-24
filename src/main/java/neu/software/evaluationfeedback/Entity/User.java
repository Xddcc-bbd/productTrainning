package neu.software.evaluationfeedback.Entity;

import lombok.Data;
import java.util.Date;

/**
 * 用户实体
 */
@Data
public class User {
    private String id;
    private String tenantId;
    private String account;
    private String password;
    private Integer userType; // 0:学生, 1:教师, 2:HR
    private Integer status; // 0:禁用, 1:启用
    private String realName;
    private String avatar;
    private Integer gender;
    private String email;
    private String phone;
    private String className;
    private String major;
    private Integer ranking;
    private Integer enrollmentYear;
    private String title;
    private String department;
    private String hrPosition;
    private Date lastLoginTime;
}
