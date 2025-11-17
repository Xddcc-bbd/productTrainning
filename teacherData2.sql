/*
SQLyog Ultimate v8.71 
MySQL - 8.0.13 : Database - teacherdata
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`teacherdata` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */;

USE `teacherdata`;

/*Table structure for table `ai_assist_records` */

DROP TABLE IF EXISTS `ai_assist_records`;

CREATE TABLE `ai_assist_records` (
  `record_id` int(11) NOT NULL AUTO_INCREMENT,
  `assignment_id` int(11) NOT NULL,
  `question_type` varchar(100) DEFAULT NULL COMMENT '问题类型',
  `standard_answer_template` text COMMENT '标准解答模板',
  `used_count` int(11) DEFAULT '0' COMMENT '使用次数',
  `generated_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`record_id`),
  KEY `assignment_id` (`assignment_id`),
  CONSTRAINT `ai_assist_records_ibfk_1` FOREIGN KEY (`assignment_id`) REFERENCES `assignments` (`assignment_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='AI辅助记录表';

/*Data for the table `ai_assist_records` */

insert  into `ai_assist_records`(`record_id`,`assignment_id`,`question_type`,`standard_answer_template`,`used_count`,`generated_time`) values (1,1,'界面布局问题','建议使用ArkUI的弹性布局，确保在不同设备上正常显示...',12,'2025-11-12 21:05:23'),(2,1,'数据绑定','使用@State装饰器管理状态，实现数据与UI的自动同步...',8,'2025-11-12 21:05:23'),(3,2,'组件复用','将重复使用的UI元素抽取为自定义组件，提高代码复用性...',5,'2025-11-12 21:05:23'),(4,1,'组件生命周期','了解ArkUI组件的生命周期方法，在aboutToAppear中初始化数据...',15,'2024-09-02 10:30:00'),(5,1,'状态管理','使用@State, @Prop, @Link装饰器管理组件状态，实现数据驱动UI...',22,'2024-09-03 14:20:00'),(6,2,'布局技巧','使用Flex布局、Grid布局实现复杂界面，注意响应式设计...',18,'2024-09-12 09:45:00'),(7,3,'数据库设计范式','遵循第三范式设计表结构，合理建立索引提升查询性能...',12,'2024-09-22 16:30:00'),(8,4,'数据加密存储','使用Preferences或RDB的加密功能保护敏感数据...',8,'2024-10-02 11:15:00'),(9,5,'HTTP请求处理','使用@ohos.net.http模块发起网络请求，处理异步回调...',14,'2024-10-17 13:40:00'),(10,6,'需求分析方法','使用用户故事、用例图等方法梳理需求，编写清晰的需求文档...',9,'2024-09-16 10:50:00'),(11,7,'原型设计工具','推荐使用Figma、墨刀等工具设计高保真原型...',11,'2024-09-21 15:25:00'),(12,8,'CSS布局技巧','使用Flexbox和Grid实现响应式布局，注意浏览器兼容性...',16,'2024-10-06 14:10:00'),(13,9,'SQL索引优化','分析慢查询日志，为频繁查询的字段建立合适的索引...',7,'2024-10-12 09:30:00'),(14,10,'模型评估方法','使用准确率、精确率、召回率等指标评估分类模型性能...',5,'2024-10-16 16:45:00');

/*Table structure for table `annotations` */

DROP TABLE IF EXISTS `annotations`;

CREATE TABLE `annotations` (
  `annotation_id` int(11) NOT NULL AUTO_INCREMENT,
  `submission_id` int(11) NOT NULL,
  `annotation_type` varchar(20) DEFAULT 'TEXT',
  `content` text,
  `audio_url` text,
  `position` json DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`annotation_id`),
  KEY `submission_id` (`submission_id`),
  CONSTRAINT `annotations_ibfk_1` FOREIGN KEY (`submission_id`) REFERENCES `submissions` (`submission_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `annotations` */

insert  into `annotations`(`annotation_id`,`submission_id`,`annotation_type`,`content`,`audio_url`,`position`,`create_time`) values (1,1,'TEXT','界面布局很合理，色彩搭配协调',NULL,'{\"x\": 120, \"y\": 80}','2024-09-08 15:30:00'),(2,1,'TEXT','建议增加错误处理机制',NULL,'{\"x\": 200, \"y\": 150}','2024-09-08 16:45:00'),(3,2,'TEXT','代码结构清晰，但注释可以更详细',NULL,'{\"x\": 180, \"y\": 90}','2024-09-09 11:20:00'),(4,3,'TEXT','功能实现完整，用户体验良好',NULL,'{\"x\": 150, \"y\": 120}','2024-09-07 17:30:00'),(5,3,'VOICE','语音批注：组件复用做得很好','audio/202409071730.mp3','{\"x\": 220, \"y\": 180}','2024-09-07 17:30:00'),(6,4,'TEXT','响应式设计考虑不够全面',NULL,'{\"x\": 130, \"y\": 200}','2024-09-10 21:45:00'),(7,5,'AI','AI分析：代码复杂度较高，建议重构',NULL,'{\"x\": 250, \"y\": 100}','2024-09-11 09:30:00'),(8,6,'TEXT','交互流程设计很人性化',NULL,'{\"x\": 170, \"y\": 160}','2024-09-09 12:15:00'),(9,7,'TEXT','动画效果流畅，视觉体验优秀',NULL,'{\"x\": 190, \"y\": 140}','2024-09-08 16:20:00'),(10,8,'TEXT','数据库设计符合规范',NULL,'{\"x\": 210, \"y\": 170}','2024-09-18 14:10:00');

/*Table structure for table `assignments` */

DROP TABLE IF EXISTS `assignments`;

CREATE TABLE `assignments` (
  `assignment_id` int(11) NOT NULL AUTO_INCREMENT,
  `course_id` int(11) NOT NULL,
  `assignment_name` varchar(200) NOT NULL COMMENT '任务名称',
  `assignment_type` varchar(50) DEFAULT NULL COMMENT '任务类型',
  `description` text COMMENT '任务描述',
  `full_score` decimal(5,2) DEFAULT '100.00' COMMENT '满分',
  `grading_criteria` json DEFAULT NULL COMMENT '评分标准（JSON格式）',
  `start_time` datetime DEFAULT NULL COMMENT '开始时间',
  `end_time` datetime DEFAULT NULL COMMENT '截止时间',
  `expected_duration` int(11) DEFAULT NULL COMMENT '预计完成时长（分钟）',
  `created_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`assignment_id`),
  KEY `idx_assignments_course` (`course_id`),
  CONSTRAINT `assignments_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='任务表';

/*Data for the table `assignments` */

insert  into `assignments`(`assignment_id`,`course_id`,`assignment_name`,`assignment_type`,`description`,`full_score`,`grading_criteria`,`start_time`,`end_time`,`expected_duration`,`created_time`) values (1,1,'第一个鸿蒙Hello World应用','积木任务','创建第一个鸿蒙应用，实现基础界面','100.00',NULL,'2024-09-01 00:00:00','2024-09-10 23:59:59',120,'2024-08-28 16:20:00'),(2,1,'教学管理系统界面设计','积木任务','设计教学管理系统的用户界面','100.00',NULL,'2024-09-11 00:00:00','2024-09-20 23:59:59',180,'2024-09-05 09:15:00'),(3,1,'数据库设计与实现','团队任务','设计并实现教学管理系统的数据库','100.00',NULL,'2024-09-21 00:00:00','2024-09-30 23:59:59',240,'2024-09-15 14:40:00'),(4,1,'鸿蒙数据持久化开发','积木任务','实现本地数据存储功能','100.00',NULL,'2024-10-01 00:00:00','2024-10-15 23:59:59',180,'2024-09-25 10:30:00'),(5,1,'网络请求与API调用','团队任务','实现与后端API的数据交互','100.00',NULL,'2024-10-16 00:00:00','2024-10-30 23:59:59',240,'2024-10-10 15:20:00'),(6,2,'需求分析文档编写','个人任务','完成软件需求规格说明书','100.00',NULL,'2024-09-15 00:00:00','2024-09-25 23:59:59',120,'2024-09-10 11:00:00'),(7,3,'移动端UI设计','积木任务','设计移动应用界面原型','100.00',NULL,'2024-09-20 00:00:00','2024-09-30 23:59:59',150,'2024-09-15 16:45:00'),(8,4,'HTML5+CSS3网页制作','个人任务','制作响应式网页','100.00',NULL,'2024-10-05 00:00:00','2024-10-20 23:59:59',200,'2024-09-30 13:10:00'),(9,5,'SQL查询优化实践','团队任务','优化复杂SQL查询性能','100.00',NULL,'2024-10-10 00:00:00','2024-10-25 23:59:59',180,'2024-10-05 09:30:00'),(10,6,'机器学习模型实现','个人任务','实现基础分类算法','100.00',NULL,'2024-10-15 00:00:00','2024-10-31 23:59:59',300,'2024-10-08 14:25:00');

/*Table structure for table `batch_feedbacks` */

DROP TABLE IF EXISTS `batch_feedbacks`;

CREATE TABLE `batch_feedbacks` (
  `feedback_id` int(11) NOT NULL AUTO_INCREMENT,
  `course_id` int(11) NOT NULL,
  `assignment_id` int(11) NOT NULL,
  `feedback_type` varchar(50) DEFAULT NULL COMMENT '反馈类型',
  `content` text NOT NULL COMMENT '反馈内容',
  `used_count` int(11) DEFAULT '0' COMMENT '使用次数',
  `created_by` varchar(50) NOT NULL COMMENT '创建教师ID',
  `created_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`feedback_id`),
  KEY `course_id` (`course_id`),
  KEY `assignment_id` (`assignment_id`),
  CONSTRAINT `batch_feedbacks_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  CONSTRAINT `batch_feedbacks_ibfk_2` FOREIGN KEY (`assignment_id`) REFERENCES `assignments` (`assignment_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='批量反馈表';

/*Data for the table `batch_feedbacks` */

insert  into `batch_feedbacks`(`feedback_id`,`course_id`,`assignment_id`,`feedback_type`,`content`,`used_count`,`created_by`,`created_time`) values (1,1,1,'common_issue','部分同学在界面布局时没有考虑不同屏幕尺寸的适配问题',5,'teacher_zhao','2025-11-12 21:05:23'),(2,1,1,'common_issue','代码注释不够详细，建议增加必要的文档说明',3,'teacher_zhao','2025-11-12 21:05:23'),(3,1,2,'template','优秀作业的标准：界面美观、交互流畅、代码规范',8,'teacher_zhao','2025-11-12 21:05:23'),(4,1,1,'common_issue','部分同学在事件处理时没有考虑异常情况，建议增加try-catch',6,'teacher_zhao','2024-09-03 14:30:00'),(5,1,2,'template','优秀UI设计的标准：一致性、可用性、美观性、响应式',12,'teacher_zhao','2024-09-13 10:15:00'),(6,1,3,'common_issue','数据库表设计时外键约束使用不当，导致数据不一致',4,'teacher_zhao','2024-09-23 16:20:00'),(7,2,6,'common_issue','需求描述不够具体，缺乏可衡量的验收标准',8,'teacher_li','2024-09-18 11:40:00'),(8,3,7,'template','优秀原型设计应包含：交互流程、视觉风格、组件规范',9,'teacher_wang','2024-09-25 15:30:00'),(9,4,8,'common_issue','CSS代码冗余较多，建议使用预处理器和组件化思想',7,'teacher_chen','2024-10-08 13:25:00'),(10,5,9,'common_issue','复杂查询没有使用EXPLAIN分析执行计划，性能有待优化',5,'teacher_lin','2024-10-15 10:50:00'),(11,6,10,'template','机器学习项目流程：数据清洗、特征工程、模型训练、评估优化',6,'teacher_zhang','2024-10-18 14:15:00'),(12,1,4,'common_issue','数据加密密钥管理不当，存在安全风险',3,'teacher_zhao','2024-10-05 09:20:00'),(13,1,5,'common_issue','网络请求超时和重试机制不完善，影响用户体验',5,'teacher_zhao','2024-10-20 16:45:00');

/*Table structure for table `course_students` */

DROP TABLE IF EXISTS `course_students`;

CREATE TABLE `course_students` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `course_id` int(11) NOT NULL,
  `student_id` varchar(50) NOT NULL,
  `enrollment_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_course_student` (`course_id`,`student_id`),
  KEY `student_id` (`student_id`),
  CONSTRAINT `course_students_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  CONSTRAINT `course_students_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='选课关系表';

/*Data for the table `course_students` */

insert  into `course_students`(`id`,`course_id`,`student_id`,`enrollment_time`) values (1,1,'20230001','2024-08-20 09:00:00'),(2,1,'20230002','2024-08-20 10:15:00'),(3,1,'20230003','2024-08-21 08:30:00'),(4,1,'20230004','2024-08-21 11:45:00'),(5,1,'20230005','2024-08-22 14:20:00'),(6,1,'20230006','2024-08-22 16:35:00'),(7,1,'20230007','2024-08-23 13:10:00'),(8,1,'20230008','2024-08-23 15:25:00');

/*Table structure for table `courses` */

DROP TABLE IF EXISTS `courses`;

CREATE TABLE `courses` (
  `course_id` int(11) NOT NULL AUTO_INCREMENT,
  `course_name` varchar(100) NOT NULL COMMENT '课程名称',
  `teacher_id` varchar(50) NOT NULL COMMENT '教师ID',
  `academic_year` varchar(20) DEFAULT NULL COMMENT '学年学期',
  `student_count` int(11) DEFAULT '0' COMMENT '学生总数',
  `created_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`course_id`),
  KEY `idx_courses_teacher` (`teacher_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='课程表';

/*Data for the table `courses` */

insert  into `courses`(`course_id`,`course_name`,`teacher_id`,`academic_year`,`student_count`,`created_time`) values (1,'鸿蒙应用开发实训','teacher_zhao','2024-秋',30,'2024-08-15 09:00:00'),(2,'软件工程实践','teacher_wu','2024-秋',25,'2024-08-20 10:30:00'),(3,'移动应用开发','teacher_mao','2024-秋',28,'2024-08-25 14:15:00'),(4,'Web前端开发技术','teacher_li','2024-秋',35,'2024-09-01 08:45:00'),(5,'数据库原理与应用','teacher_wang','2024-秋',40,'2024-09-05 13:20:00'),(6,'人工智能基础','teacher_chen','2024-秋',28,'2024-09-10 10:00:00'),(7,'软件测试与质量保证','teacher_lin','2024-秋',32,'2024-09-15 15:30:00'),(8,'云计算与大数据','teacher_zhang','2024-秋',26,'2024-09-20 11:45:00');

/*Table structure for table `grades` */

DROP TABLE IF EXISTS `grades`;

CREATE TABLE `grades` (
  `grade_id` int(11) NOT NULL AUTO_INCREMENT,
  `submission_id` int(11) NOT NULL,
  `teacher_id` varchar(50) NOT NULL COMMENT '批改教师ID',
  `score` decimal(5,2) DEFAULT NULL COMMENT '得分',
  `ai_score` decimal(5,2) DEFAULT NULL COMMENT 'AI预批改得分',
  `final_score` decimal(5,2) DEFAULT NULL COMMENT '最终得分',
  `text_comment` text COMMENT '文字评语',
  `ai_text_comment` text COMMENT 'AI生成评语',
  `voice_comment_url` text COMMENT '语音评语存储URL',
  `is_teacher_recommended` tinyint(1) DEFAULT '0' COMMENT '是否教师推荐',
  `grading_time` datetime DEFAULT NULL COMMENT '批改时间',
  `created_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`grade_id`),
  KEY `idx_grades_submission` (`submission_id`),
  CONSTRAINT `grades_ibfk_1` FOREIGN KEY (`submission_id`) REFERENCES `submissions` (`submission_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='作业批改表';

/*Data for the table `grades` */

insert  into `grades`(`grade_id`,`submission_id`,`teacher_id`,`score`,`ai_score`,`final_score`,`text_comment`,`ai_text_comment`,`voice_comment_url`,`is_teacher_recommended`,`grading_time`,`created_time`) values (1,1,'teacher_zhao','90.00','88.00','90.00','界面设计很美观，功能完整','代码结构清晰，建议增加错误处理',NULL,1,'2024-09-09 10:00:00','2025-11-12 21:05:23'),(2,2,'teacher_zhao','85.00','82.00','85.00','功能实现良好，但界面可以优化','基础功能完整，用户体验有待提升',NULL,0,'2024-09-09 11:00:00','2025-11-12 21:05:23'),(3,3,'teacher_zhao','92.00','90.00','92.00','优秀！代码规范，功能完善','实现效果很好，建议补充文档',NULL,1,'2024-09-09 14:00:00','2025-11-12 21:05:23'),(4,4,'teacher_zhao','78.00','75.00','78.00','基本功能完成，但有改进空间','功能实现基本达标，可优化性能',NULL,0,'2024-09-11 09:00:00','2025-11-12 21:05:23'),(5,5,'teacher_zhao','70.00','68.00','70.00','逾期提交，扣分处理','功能完整但提交超时',NULL,0,'2024-09-12 10:00:00','2025-11-12 21:05:23'),(6,6,'teacher_zhao','82.00','80.00','82.00','完成质量不错，继续努力','代码质量良好，功能完整',NULL,0,'2024-09-10 15:00:00','2025-11-12 21:05:23'),(7,7,'teacher_zhao','88.00','85.00','88.00','设计有创意，实现完整','界面交互体验良好',NULL,0,'2024-09-09 16:00:00','2025-11-12 21:05:23');

/*Table structure for table `grading_items` */

DROP TABLE IF EXISTS `grading_items`;

CREATE TABLE `grading_items` (
  `item_id` int(11) NOT NULL AUTO_INCREMENT,
  `standard_id` int(11) NOT NULL,
  `name` varchar(200) NOT NULL,
  `description` text,
  `score` decimal(5,2) DEFAULT '0.00',
  `weight` decimal(3,2) DEFAULT '0.00',
  PRIMARY KEY (`item_id`),
  KEY `standard_id` (`standard_id`),
  CONSTRAINT `grading_items_ibfk_1` FOREIGN KEY (`standard_id`) REFERENCES `grading_standards` (`standard_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `grading_items` */

insert  into `grading_items`(`item_id`,`standard_id`,`name`,`description`,`score`,`weight`) values (1,1,'界面布局','ArkUI布局合理性，响应式设计','25.00','0.25'),(2,1,'功能实现','核心功能完整性和正确性','35.00','0.35'),(3,1,'代码规范','代码结构、命名规范、注释完整性','20.00','0.20'),(4,1,'用户体验','交互流程、操作便捷性','20.00','0.20'),(5,2,'视觉设计','色彩搭配、图标设计、整体美观度','30.00','0.30'),(6,2,'交互设计','操作流程、反馈机制、用户体验','30.00','0.30'),(7,2,'布局设计','界面布局、信息层级、响应式适配','25.00','0.25'),(8,2,'创新性','设计创意、个性化元素','15.00','0.15'),(9,3,'表结构设计','表结构合理性、范式遵循','30.00','0.30'),(10,3,'关系设计','主外键关系、关联设计','25.00','0.25'),(11,3,'索引设计','索引合理性、查询性能','20.00','0.20'),(12,3,'数据完整性','约束条件、数据验证','25.00','0.25'),(13,4,'数据存储','Preferences/RDB使用合理性','35.00','0.35'),(14,4,'数据安全','加密存储、权限控制','25.00','0.25'),(15,4,'性能优化','数据操作效率、内存管理','25.00','0.25'),(16,4,'错误处理','异常处理、数据恢复','15.00','0.15'),(17,5,'接口调用','HTTP请求正确性、参数处理','30.00','0.30'),(18,5,'数据处理','JSON解析、数据转换','25.00','0.25'),(19,5,'错误处理','网络异常、超时处理','20.00','0.20'),(20,5,'性能优化','请求缓存、并发处理','25.00','0.25');

/*Table structure for table `grading_standards` */

DROP TABLE IF EXISTS `grading_standards`;

CREATE TABLE `grading_standards` (
  `standard_id` int(11) NOT NULL AUTO_INCREMENT,
  `assignment_id` int(11) NOT NULL,
  `name` varchar(200) NOT NULL,
  `total_score` decimal(5,2) DEFAULT '100.00',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`standard_id`),
  KEY `assignment_id` (`assignment_id`),
  CONSTRAINT `grading_standards_ibfk_1` FOREIGN KEY (`assignment_id`) REFERENCES `assignments` (`assignment_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `grading_standards` */

insert  into `grading_standards`(`standard_id`,`assignment_id`,`name`,`total_score`,`create_time`,`update_time`) values (1,1,'鸿蒙应用开发基础评分标准','100.00','2024-08-28 16:30:00','2024-09-01 10:00:00'),(2,2,'UI界面设计评分标准','100.00','2024-09-05 09:30:00','2024-09-11 14:20:00'),(3,3,'数据库设计评分标准','100.00','2024-09-15 15:10:00','2024-09-21 11:45:00'),(4,4,'数据持久化评分标准','100.00','2024-09-25 11:15:00','2024-10-01 16:30:00'),(5,5,'网络请求评分标准','100.00','2024-10-10 15:45:00','2024-10-16 13:20:00');

/*Table structure for table `students` */

DROP TABLE IF EXISTS `students`;

CREATE TABLE `students` (
  `student_id` varchar(50) NOT NULL,
  `student_name` varchar(50) NOT NULL,
  `class_name` varchar(100) DEFAULT NULL,
  `created_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `students` */

insert  into `students`(`student_id`,`student_name`,`class_name`,`created_time`) values ('20230001','张三','软件工程2301','2024-08-15 08:30:00'),('20230002','李四','软件工程2302','2024-08-15 09:45:00'),('20230003','王五','软件工程2303','2024-08-16 10:20:00'),('20230004','赵六','软件工程2304','2024-08-16 14:35:00'),('20230005','钱七','软件工程2302','2024-08-17 11:10:00'),('20230006','孙八','软件工程2303','2024-08-17 16:25:00'),('20230007','周九','软件工程2302','2024-08-18 13:40:00'),('20230008','吴十','软件工程2301','2024-08-18 15:55:00');

/*Table structure for table `submissions` */

DROP TABLE IF EXISTS `submissions`;

CREATE TABLE `submissions` (
  `submission_id` int(11) NOT NULL AUTO_INCREMENT,
  `assignment_id` int(11) NOT NULL,
  `student_id` varchar(50) NOT NULL,
  `team_id` int(11) DEFAULT NULL COMMENT '如果是团队任务，记录所属团队',
  `content_url` text COMMENT '作品内容存储URL或路径',
  `submission_time` datetime DEFAULT NULL COMMENT '提交时间',
  `status` varchar(20) DEFAULT 'submitted' COMMENT '状态：submitted, late, unsubmitted',
  `actual_duration` int(11) DEFAULT NULL COMMENT '实际完成时长（分钟）',
  `is_late` tinyint(1) DEFAULT '0' COMMENT '是否逾期',
  `created_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`submission_id`),
  UNIQUE KEY `uk_assignment_student` (`assignment_id`,`student_id`),
  KEY `idx_submissions_assignment` (`assignment_id`),
  KEY `idx_submissions_student` (`student_id`),
  KEY `idx_submissions_team` (`team_id`),
  CONSTRAINT `submissions_ibfk_1` FOREIGN KEY (`assignment_id`) REFERENCES `assignments` (`assignment_id`) ON DELETE CASCADE,
  CONSTRAINT `submissions_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`) ON DELETE CASCADE,
  CONSTRAINT `submissions_ibfk_3` FOREIGN KEY (`team_id`) REFERENCES `teams` (`team_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='任务提交表';

/*Data for the table `submissions` */

insert  into `submissions`(`submission_id`,`assignment_id`,`student_id`,`team_id`,`content_url`,`submission_time`,`status`,`actual_duration`,`is_late`,`created_time`) values (1,1,'20230001',1,NULL,'2024-09-08 14:30:00','submitted',110,0,'2024-09-08 14:25:00'),(2,1,'20230002',1,NULL,'2024-09-09 10:15:00','submitted',125,0,'2024-09-09 10:10:00'),(3,1,'20230003',1,NULL,'2024-09-07 16:45:00','submitted',105,0,'2024-09-07 16:40:00'),(4,1,'20230004',2,NULL,'2024-09-10 20:30:00','submitted',135,0,'2024-09-10 20:25:00'),(5,1,'20230005',2,NULL,'2024-09-11 09:00:00','late',140,1,'2024-09-11 08:55:00'),(6,1,'20230006',2,NULL,'2024-09-09 11:20:00','submitted',120,0,'2024-09-09 11:15:00'),(7,1,'20230007',3,NULL,'2024-09-08 15:40:00','submitted',115,0,'2024-09-08 15:35:00'),(8,2,'20230001',1,NULL,'2024-09-18 13:25:00','submitted',160,0,'2024-09-18 13:20:00'),(9,2,'20230003',1,NULL,'2024-09-19 10:10:00','submitted',170,0,'2024-09-19 10:05:00'),(10,2,'20230005',2,NULL,'2024-09-17 14:50:00','submitted',155,0,'2024-09-17 14:45:00'),(11,2,'20230007',3,NULL,'2024-09-20 16:30:00','submitted',165,0,'2024-09-20 16:25:00');

/*Table structure for table `team_members` */

DROP TABLE IF EXISTS `team_members`;

CREATE TABLE `team_members` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `team_id` int(11) NOT NULL,
  `student_id` varchar(50) NOT NULL,
  `contribution_rate` decimal(3,2) DEFAULT '0.00' COMMENT '贡献度（0-1之间的小数）',
  `role_in_team` varchar(50) DEFAULT NULL COMMENT '在团队中的角色',
  `joined_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_team_member` (`team_id`,`student_id`),
  KEY `idx_team_members_team` (`team_id`),
  KEY `idx_team_members_student` (`student_id`),
  CONSTRAINT `team_members_ibfk_1` FOREIGN KEY (`team_id`) REFERENCES `teams` (`team_id`) ON DELETE CASCADE,
  CONSTRAINT `team_members_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='团队成员表';

/*Data for the table `team_members` */

insert  into `team_members`(`id`,`team_id`,`student_id`,`contribution_rate`,`role_in_team`,`joined_time`) values (1,1,'20230001','0.35','组长','2024-08-25 09:30:00'),(2,1,'20230002','0.30','开发','2024-08-25 10:45:00'),(3,1,'20230003','0.35','架构','2024-08-26 08:20:00'),(4,2,'20230004','0.40','组长','2024-08-26 11:35:00'),(5,2,'20230005','0.30','开发','2024-08-27 14:10:00'),(6,2,'20230006','0.30','测试','2024-08-27 16:25:00'),(7,3,'20230007','0.50','组长','2024-08-28 13:40:00'),(8,3,'20230008','0.50','开发','2024-08-28 15:55:00');

/*Table structure for table `teams` */

DROP TABLE IF EXISTS `teams`;

CREATE TABLE `teams` (
  `team_id` int(11) NOT NULL AUTO_INCREMENT,
  `team_name` varchar(100) NOT NULL COMMENT '团队名称',
  `course_id` int(11) NOT NULL COMMENT '所属课程',
  `leader_id` varchar(50) DEFAULT NULL COMMENT '团队负责人',
  `current_score` decimal(5,2) DEFAULT '0.00' COMMENT '当前得分',
  `ranking` int(11) DEFAULT NULL COMMENT '排名',
  `created_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`team_id`),
  KEY `course_id` (`course_id`),
  KEY `leader_id` (`leader_id`),
  CONSTRAINT `teams_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  CONSTRAINT `teams_ibfk_2` FOREIGN KEY (`leader_id`) REFERENCES `students` (`student_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='团队表';

/*Data for the table `teams` */

insert  into `teams`(`team_id`,`team_name`,`course_id`,`leader_id`,`current_score`,`ranking`,`created_time`) values (1,'创新之星',1,'20230001','85.50',1,'2024-08-25 09:15:00'),(2,'技术先锋',1,'20230003','78.00',2,'2024-08-26 11:30:00'),(3,'代码艺术家',1,'20230005','72.50',3,'2024-08-27 14:45:00');

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
