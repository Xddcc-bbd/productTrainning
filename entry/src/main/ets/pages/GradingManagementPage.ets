// entry/src/main/ets/pages/GradingManagementPage.ets

import { Assignment } from '../model/Assignment';
import { Submission } from '../model/Submission';
import { Grade } from '../model/Grade';
import { assignmentService } from '../service/AssignmentService';
import { gradingService } from '../service/GradingService';
import { studentService } from '../service/StudentService';
import { DateUtils } from '../common/DateUtils';
import router from '@ohos.router';

@Component
struct SubmissionItem {
  @Prop submission: Submission;
  @Prop grade: Grade;
  @Link selectedSubmissionIds: string[];
  @State private isChecked: boolean = false;

  aboutToAppear() {
    this.isChecked = this.selectedSubmissionIds.includes(this.submission.submissionId);
  }

  build() {
    Row({ space: 8 }) {
      // 选择框（左侧，小尺寸）
      Checkbox()
        .select(this.isChecked)
        .onChange((value: boolean) => {
          this.isChecked = value;
          console.log(`Checkbox 变化: ${this.submission.studentName}, 新状态: ${value}`);
          
          if (value) {
            // 选中：添加到列表
            if (!this.selectedSubmissionIds.includes(this.submission.submissionId)) {
              this.selectedSubmissionIds.push(this.submission.submissionId);
              console.log(`添加到选中列表: ${this.submission.submissionId}`);
              console.log(`当前选中数量: ${this.selectedSubmissionIds.length}`);
            }
          } else {
            // 取消选中：从列表移除
            const index = this.selectedSubmissionIds.indexOf(this.submission.submissionId);
            if (index > -1) {
              this.selectedSubmissionIds.splice(index, 1);
              console.log(`从选中列表移除: ${this.submission.submissionId}`);
              console.log(`当前选中数量: ${this.selectedSubmissionIds.length}`);
            }
          }
        })
        .width(20)
        .height(20)
      
      // 学生信息卡片
      Row({ space: 10 }) {
        // 学生头像
        Stack() {
          Text(this.submission.studentName.charAt(0))
            .fontSize(14)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Medium)
        }
        .width(38)
        .height(38)
        .borderRadius(19)
        .backgroundColor('#1890FF')
        .alignContent(Alignment.Center)
        
        // 学生信息（显示姓名和学号）
        Column({ space: 2 }) {
          Text(this.submission.studentName)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
          
          Text('学号: ' + this.submission.studentId)
            .fontSize(11)
            .fontColor('#999999')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        
        // 状态和分数
        Column({ space: 4 }) {
          Text(this.submission.statusText)
            .fontSize(10)
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .borderRadius(8)
            .backgroundColor(this.submission.statusColor)
            .fontColor('#FFFFFF')
          
          if (this.grade.displayScore > 0) {
            Row({ space: 1 }) {
              Text(this.grade.displayScore.toString())
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FF6B35')
              Text('分')
                .fontSize(10)
                .fontColor('#999999')
            }
            .alignItems(VerticalAlign.Bottom)
          } else {
            Text('待评分')
              .fontSize(11)
              .fontColor('#FAAD14')
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .border({ width: 1, color: '#FAAD14', radius: 4 })
          }
        }
        .alignItems(HorizontalAlign.Center)
      }
      .layoutWeight(1)
      .padding(10)
      .backgroundColor('#FFFFFF')
      .borderRadius(8)
      .shadow({ radius: 4, color: '#08000000', offsetX: 0, offsetY: 2 })
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        console.log('👆 点击学生作业:');
        console.log('  学生姓名:', this.submission.studentName);
        console.log('  学号:', this.submission.studentId);
        console.log('  提交ID:', this.submission.submissionId);
        console.log('  作业ID:', this.submission.assignmentId);
        
        if (!this.submission.submissionId) {
          console.error('❌ 错误：submissionId为空，无法跳转');
          return;
        }
        
        router.pushUrl({
          url: 'pages/DetailedGradingPage',
          params: {
            submissionId: this.submission.submissionId,
            studentName: this.submission.studentName,
            assignmentId: this.submission.assignmentId
          }
        }).then(() => {
          console.log('✅ 跳转成功，传递参数:', {
            submissionId: this.submission.submissionId,
            studentName: this.submission.studentName
          });
        }).catch((err: Error) => {
          console.error('❌ 跳转失败:', err);
        });
      })
    }
    .width('100%')
    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
    .alignItems(VerticalAlign.Center)
  }
}

@Entry
@Component
struct GradingManagementPage {
  @State assignments: Assignment[] = [];
  @State selectedAssignment: Assignment = new Assignment();
  @State submissions: Submission[] = [];
  @State grades: Grade[] = [];
  @State isLoading: boolean = false;
  @State errorMessage: string = '';
  @State connectionStatus: string = '未连接';
  @State autoLoad: boolean = true; // 启用自动加载以显示后端数据
  @State selectedSubmissionIds: string[] = []; // 选中的作业列表
  
  aboutToAppear() {
    console.log('🚀 GradingManagementPage 页面加载');
    // Preview模式下不自动加载，需要手动点击刷新
    // 真机运行时可以自动加载
    if (this.autoLoad) {
      console.log('自动加载已启用，开始连接后端...');
      this.testBackendConnection();
    } else {
      console.log('自动加载已禁用，请点击刷新按钮');
      this.connectionStatus = '点击“刷新”按钮连接后端';
    }
  }
  
  // 测试后端连接
  async testBackendConnection() {
    try {
      this.isLoading = true;
      this.connectionStatus = '正在连接后端...';
      console.log('开始测试后端连接...');
      console.log('请求URL: http://127.0.0.1:8081/api/v1/grading/assignment/assign_01');
      
      // 测试获取作业详情
      const testAssignment = await assignmentService.getAssignmentById('assign_01');
      
      if (testAssignment) {
        this.connectionStatus = `✅ 后端连接成功`;
        console.log('✅ 后端连接成功！');
        console.log('获取到作业ID:', testAssignment.assignmentId);
        console.log('作业名称:', testAssignment.assignmentName);
        console.log('课程ID:', testAssignment.courseId);
        console.log('开始时间:', DateUtils.formatISODate(testAssignment.startTime));
        console.log('截止时间:', DateUtils.formatISODate(testAssignment.endTime));
        
        // 连接成功后加载数据
        this.loadAssignments();
      } else {
        this.connectionStatus = '⚠️ 后端返回空数据';
        this.errorMessage = '后端连接正常，但没有返回作业数据。\n请检查：数据库中是否有 assignment_id=assign_01 的记录';
        console.warn('⚠️ 后端返回了null或undefined');
        console.warn('可能原因：');
        console.warn('1. 数据库中没有 assignment_id=assign_01 的记录');
        console.warn('2. 后端SQL查询失败');
        console.warn('3. 后端Mapper配置问题');
      }
    } catch (error) {
      this.connectionStatus = '❌ 后端连接失败';
      this.errorMessage = `无法连接到后端服务器\n错误: ${error}`;
      console.error('❌ 后端连接失败!');
      console.error('错误详情:', error);
      console.error('\n请检查：');
      console.error('1. 后端服务是否启动？运行: mvn spring-boot:run');
      console.error('2. 后端是否在 http://127.0.0.1:8081 运行？');
      console.error('3. 网络权限是否配置？(module.json5)');
      console.error('4. CORS是否配置正确？(WebConfig.java)');
    } finally {
      this.isLoading = false;
    }
  }
  
  async loadAssignments() {
    try {
      this.isLoading = true;
      this.errorMessage = '';
      console.log('开始加载作业列表...');
      console.log('请求URL: http://127.0.0.1:8081/api/v1/grading/teacher/teacher_zhao/assignments');
      
      // 使用教师ID获取作业列表，而不是课程ID
      // 根据数据库，teacher_zhao 有多个作业
      this.assignments = await assignmentService.getTeacherAssignments('teacher_zhao');
      
      console.log(`✅ 成功加载 ${this.assignments.length} 个作业`);
      if (this.assignments.length > 0) {
        this.assignments.forEach((assignment, index) => {
          console.log(`  ${index + 1}. [ID:${assignment.assignmentId}] ${assignment.assignmentName}`);
        });
      }
      
      if (this.assignments.length > 0) {
        this.selectedAssignment = this.assignments[0];
        console.log(`选中第一个作业: ${this.selectedAssignment.assignmentName}`);
        this.loadSubmissions(this.selectedAssignment.assignmentId);
      } else {
        this.errorMessage = '暂无作业数据。\n请确认数据库中有 teacher_id=teacher_zhao 的课程和作业';
        console.warn('⚠️ 未找到作业数据');
      }
    } catch (error) {
      console.error('❌ 加载作业列表失败!');
      console.error('错误详情:', error);
      this.errorMessage = `加载失败: ${error}`;
    } finally {
      this.isLoading = false;
    }
  }
  
  async loadSubmissions(assignmentId: string) {
    try {
      this.isLoading = true;
      console.log(`\n========== 开始加载提交列表 ==========`);
      console.log(`作业ID: ${assignmentId}`);
      console.log(`请求URL: http://127.0.0.1:8081/api/v1/grading/assignment/${assignmentId}/submissions`);
      
      this.submissions = await gradingService.getSubmissions(assignmentId);
      
      console.log(`✅ 成功加载 ${this.submissions.length} 个提交`);
      if (this.submissions.length > 0) {
        this.submissions.forEach((submission, index) => {
          console.log(`  ${index + 1}. [学生:${submission.studentName}] [学号:${submission.studentId}] 状态:${submission.statusText}`);
        });
      } else {
        console.warn(`⚠️ 作业 ${assignmentId} 没有提交记录`);
      }
      
      // 加载评分信息
      if (this.submissions.length > 0) {
        this.loadGrades();
      }
    } catch (error) {
      console.error('❌ 加载提交列表失败!');
      console.error('错误详情:', error);
      this.errorMessage = `加载提交失败: ${error}`;
    } finally {
      this.isLoading = false;
      console.log(`========== 加载提交列表完成 ==========\n`);
    }
  }
  
  async loadGrades() {
    try {
      const gradePromises = this.submissions.map(submission => 
        gradingService.getGradeDetail(submission.submissionId)
      );
      this.grades = await Promise.all(gradePromises);
    } catch (error) {
      console.error('加载评分信息失败:', error);
    }
  }
  
  getGradeBySubmissionId(submissionId: string): Grade {
    const grade = this.grades.find(g => g.submissionId === submissionId);
    return grade || new Grade();
  }
  
  build() {
    Column() {
      // 顶部标题栏（简洁版）
      Row() {
        Text('←')
          .fontSize(24)
          .fontColor('#1890FF')
          .onClick(() => {
            router.back();
          })
          .margin({ right: 12 })
        
        Text('📝 作业批改')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        
        Blank()
        
        if (this.isLoading) {
          LoadingProgress()
            .width(20)
            .height(20)
            .color('#1890FF')
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor('#FFFFFF')
      
      // 统计信息卡片（紧凑版）
      Row({ space: 10 }) {
        Column({ space: 2 }) {
          Text(this.submissions.length.toString())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1890FF')
          Text('总提交')
            .fontSize(12)
            .fontColor('#666666')
        }
        .layoutWeight(1)
        .height(70)
        .padding(12)
        .backgroundColor('#E6F7FF')
        .borderRadius(8)
        .justifyContent(FlexAlign.Center)
        
        Column({ space: 2 }) {
          Text(this.grades.filter(g => g.displayScore > 0).length.toString())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#52C41A')
          Text('已评分')
            .fontSize(12)
            .fontColor('#666666')
        }
        .layoutWeight(1)
        .height(70)
        .padding(12)
        .backgroundColor('#F6FFED')
        .borderRadius(8)
        .justifyContent(FlexAlign.Center)
        
        Column({ space: 2 }) {
          Text(this.grades.filter(g => g.isTeacherRecommended).length.toString())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF6B35')
          Text('推荐作品')
            .fontSize(12)
            .fontColor('#666666')
        }
        .layoutWeight(1)
        .height(70)
        .padding(12)
        .backgroundColor('#FFF7E6')
        .borderRadius(8)
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      
      // 左右布局：左侧作业列表，右侧学生作业详情
      Row({ space: 12 }) {
        // 左侧：竖向作业列表（超紧凑版）
        Column() {
          Text('作业')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor('#999999')
            .width('100%')
            .padding({ left: 6, top: 6, bottom: 4 })
          
          List({ space: 4 }) {
            ForEach(this.assignments, (assignment: Assignment, index: number) => {
              ListItem() {
                Column({ space: 1 }) {
                  Text(assignment.assignmentName)
                    .fontSize(11)
                    .fontWeight(this.selectedAssignment.assignmentId === assignment.assignmentId ? FontWeight.Medium : FontWeight.Normal)
                    .fontColor(this.selectedAssignment.assignmentId === assignment.assignmentId ? '#1890FF' : '#333333')
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  
                  Text(`${assignment.assignmentId}`)
                    .fontSize(9)
                    .fontColor('#AAAAAA')
                }
                .width('100%')
                .padding(6)
                .backgroundColor(this.selectedAssignment.assignmentId === assignment.assignmentId ? '#E6F7FF' : '#FFFFFF')
                .borderRadius(4)
                .border({
                  width: this.selectedAssignment.assignmentId === assignment.assignmentId ? 1.5 : 0.5,
                  color: this.selectedAssignment.assignmentId === assignment.assignmentId ? '#1890FF' : '#E0E0E0'
                })
                .onClick(() => {
                  console.log(`👆 点击作业: [ID:${assignment.assignmentId}] ${assignment.assignmentName}`);
                  this.selectedAssignment = assignment;
                  this.loadSubmissions(assignment.assignmentId);
                })
              }
            }, (item: Assignment) => item.assignmentId.toString())
          }
          .layoutWeight(1)
          .divider({ strokeWidth: 0 })
        }
        .width(110)
        .height('100%')
        .backgroundColor('#FAFAFA')
        .borderRadius(6)
        .padding(4)
        
        // 右侧：学生作业列表
        Stack() {
          Column() {
            Row() {
              Text('学生作业列表')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
              
              Blank()
              
              Text(`共 ${this.submissions.length} 人`)
                .fontSize(14)
                .fontColor('#999999')
            }
            .width('100%')
            .padding({ left: 12, right: 12, top: 12, bottom: 8 })
            
            List({ space: 8 }) {
              ForEach(this.submissions, (submission: Submission, index: number) => {
                ListItem() {
                  SubmissionItem({
                    submission: submission,
                    grade: this.getGradeBySubmissionId(submission.submissionId),
                    selectedSubmissionIds: $selectedSubmissionIds
                  })
                }
              }, (item: Submission) => item.submissionId.toString())
            }
            .layoutWeight(1)
            .padding({ left: 12, right: 12 })
            .divider({ strokeWidth: 0 })
          }
          .layoutWeight(1)
          .height('100%')
          
          // 批量处理按钮（右下角浮动）
          if (this.selectedSubmissionIds.length > 0) {
            Row() {
              Button(`批量处理 (${this.selectedSubmissionIds.length})`)
                .type(ButtonType.Capsule)
                .backgroundColor('#1890FF')
                .fontColor('#FFFFFF')
                .fontSize(15)
                .padding({ left: 24, right: 24, top: 12, bottom: 12 })
                .shadow({ radius: 12, color: '#40000000', offsetX: 0, offsetY: 4 })
                .onClick(() => {
                  console.log(`批量处理 ${this.selectedSubmissionIds.length} 份作业`);
                  router.pushUrl({
                    url: 'pages/BatchFeedbackPage',
                    params: {
                      submissionIds: this.selectedSubmissionIds,
                      assignmentId: this.selectedAssignment.assignmentId
                    }
                  }).catch((err: Error) => {
                    console.error('跳转失败:', err);
                  });
                })
            }
            .width('100%')
            .justifyContent(FlexAlign.End)
            .padding({ right: 24, bottom: 24 })
          }
        }
        .layoutWeight(1)
        .height('100%')
        .alignContent(Alignment.BottomEnd)
      }
      .layoutWeight(1)
      .padding({ left: 16, right: 16, top: 12, bottom: 16 })
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}