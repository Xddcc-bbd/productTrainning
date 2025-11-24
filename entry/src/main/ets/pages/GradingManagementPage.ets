// entry/src/main/ets/pages/GradingManagementPage.ets

import { Assignment } from '../model/Assignment';
import { Submission } from '../model/Submission';
import { Grade } from '../model/Grade';
import { assignmentService } from '../service/AssignmentService';
import { gradingService } from '../service/GradingService';
import { studentService } from '../service/StudentService';
import { HttpService } from '../common/HttpService';
import { DateUtils } from '../common/DateUtils';
import router from '@ohos.router';

// 定义后端返回的数据结构
interface SubmissionWithGradeDTO {
  submissionInfo: Record<string, Object>;
  gradeInfo?: Record<string, Object>;
}

@Component
struct SubmissionItem {
  @Prop submission: Submission;
  @Prop grade: Grade;
  @Link selectedSubmissionIds: string[];
  @State private isChecked: boolean = false;

  aboutToAppear(): void {
    this.isChecked = this.selectedSubmissionIds.includes(this.submission.submissionId);
  }

  build() {
    Row({ space: 5 }) {
      // 选择框（左侧）
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
        .margin({ left: 2 })
      // 学生信息卡片
      Row({ space: 10 }) {
        // 学生头像（圆形图标）
        Column({ space: 4 }) {
          Stack() {
            // 使用纯色背景
            Circle({ width: 44, height: 44 })
              .fill('#1890FF')
          }
          .width(44)
          .height(44)
          .alignContent(Alignment.Center)

          // 学号显示在头像下方
          Text(this.submission.studentId)
            .fontSize(11)
            .fontColor('#666666')
        }
        .alignItems(HorizontalAlign.Center)

        // 学生姓名
        Column({ space: 4 }) {
          Text(this.submission.studentName)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')

          Text(`提交时间：${this.submission.submissionTime}`)
            .fontSize(11)
            .fontColor('#999999')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        // 状态和分数
        Column({ space: 6 }) {
          Text(this.submission.statusText)
            .fontSize(11)
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .borderRadius(10)
            .backgroundColor(this.submission.statusColor)
            .fontColor('#FFFFFF')

          // 根据 submission.score 判断是否已评分
          if (this.submission.score !== undefined && this.submission.score !== null) {
            Row({ space: 2 }) {
              Text(this.submission.score.toString())
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FF6B35')
              Text('分')
                .fontSize(12)
                .fontColor('#999999')
            }
            .alignItems(VerticalAlign.Bottom)
          } else {
            Text('待评分')
              .fontSize(12)
              .fontColor('#FAAD14')
              .padding({ left: 6, right: 6, top: 3, bottom: 3 })
              .border({ width: 1, color: '#FAAD14', radius: 6 })
          }
        }
        .alignItems(HorizontalAlign.Start)
      }
      .layoutWeight(1)
      .padding(18)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .shadow({ radius: 8, color: '#15000000', offsetX: 0, offsetY: 2 })
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
            assignmentId: this.submission.assignmentId,
            studentId: this.submission.studentId,
            studentName: this.submission.studentName,
            contentUrl: this.submission.contentUrl,
            submissionTime: this.submission.submissionTime,
            status: this.submission.status,
            score: this.submission.score // 传递评分
          }
        }).then(() => {
          console.log('✅ 跳转成功，传递参数:', {
            submissionId: this.submission.submissionId,
            studentName: this.submission.studentName,
            studentId: this.submission.studentId
          });
        }).catch((err: Error) => {
          console.error('❌ 跳转失败:', err);
        });
      })
    }
    .width('100%')
    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
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

  aboutToAppear(): void {
    console.log('🚀 GradingManagementPage 页面加载');
    // Preview模式下不自动加载，需要手动点击刷新
    // 真机运行时可以自动加载
    if (this.autoLoad) {
      console.log('自动加载已启用，开始连接后端...');
      this.testBackendConnection();
    } else {
      console.log('自动加载已禁用，请点击刷新按钮');
      this.connectionStatus = '点击"刷新"按钮连接后端';
    }
  }

  // ⭐ 页面显示时刷新数据
  onPageShow(): void {
    console.log('🔄 GradingManagementPage 页面显示，刷新数据...');
    if (this.selectedAssignment.assignmentId) {
      // 重新加载当前作业的提交列表
      this.loadSubmissions(this.selectedAssignment.assignmentId);
    }
  }

  // 测试后端连接
  async testBackendConnection(): Promise<void> {
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

  async loadAssignments(): Promise<void> {
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

  async loadSubmissions(assignmentId: string): Promise<void> {
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
        console.log('开始加载评分信息...');
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

  async loadGrades(): Promise<void> {
    try {
      console.log('开始获取评分详情...');
      // ⭐ 从后端获取完整的 SubmissionDetailDTO，包含 gradeInfo
      const http = HttpService.getInstance();
      const response = await http.get<SubmissionWithGradeDTO[]>(
        `/api/v1/grading/assignment/${this.selectedAssignment.assignmentId}/submissions`
      );

      if (response && Array.isArray(response)) {
        console.log(`✅ 获取到 ${response.length} 条详细数据`);

        // 提取 gradeInfo 并转换为 Grade 对象
        this.grades = response
          .filter((item: SubmissionWithGradeDTO) => item.gradeInfo) // 只保留有评分的
          .map((item: SubmissionWithGradeDTO): Grade => {
            const g = new Grade();
            const gradeInfo = item.gradeInfo as Record<string, Object>;
            g.gradeId = (gradeInfo.gradeId as string) || '';
            g.submissionId = (gradeInfo.submissionId as string) || '';
            g.teacherId = (gradeInfo.teacherId as string) || '';
            g.score = (gradeInfo.score as number) || 0;
            g.aiScore = (gradeInfo.aiScore as number) || 0;
            g.finalScore = (gradeInfo.finalScore as number) || 0;
            g.textComment = (gradeInfo.textComment as string) || '';
            g.aiTextComment = (gradeInfo.aiTextComment as string) || '';
            g.voiceCommentUrl = (gradeInfo.voiceCommentUrl as string) || '';
            g.isTeacherRecommended = (gradeInfo.isTeacherRecommended as number) || 0;
            g.gradingTime = (gradeInfo.gradingTime as string) || '';
            g.createdTime = (gradeInfo.createdTime as string) || '';

            console.log(`  评分: submission=${g.submissionId}, score=${g.finalScore}, recommended=${g.isTeacherRecommended}`);
            return g;
          });

        console.log(`✅ 成功获取 ${this.grades.length} 个评分`);
        console.log(`  其中推荐作品: ${this.grades.filter(g => g.isTeacherRecommended === 1).length} 个`);
      } else {
        this.grades = [];
      }
    } catch (error) {
      console.error('❌ 加载评分信息失败:', error);
      this.grades = [];
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

      // 统计信息卡片（美化版）
      Row({ space: 12 }) {
        Column({ space: 4 }) {
          Text(this.submissions.length.toString())
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1890FF')
          Text('总提交')
            .fontSize(13)
            .fontColor('#666666')
        }
        .layoutWeight(1)
        .height(80)
        .padding(16)
        .backgroundColor('#E6F7FF')
        .borderRadius(12)
        .justifyContent(FlexAlign.Center)

        Column({ space: 4 }) {
          // ⭐ 根据 submission.score 判断是否已评分
          Text(this.submissions.filter(s => s.score !== undefined && s.score !== null).length.toString())
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#52C41A')
          Text('已评分')
            .fontSize(13)
            .fontColor('#666666')
        }
        .layoutWeight(1)
        .height(80)
        .padding(16)
        .backgroundColor('#F6FFED')
        .borderRadius(12)
        .justifyContent(FlexAlign.Center)

        Column({ space: 4 }) {
          // ⭐ 根据 grades 表的 isTeacherRecommended 字段统计
          Text(this.grades.filter(g => g.isTeacherRecommended === 1).length.toString())
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF6B35')
          Text('推荐作品')
            .fontSize(13)
            .fontColor('#666666')
        }
        .layoutWeight(1)
        .height(80)
        .padding(16)
        .backgroundColor('#FFF7E6')
        .borderRadius(12)
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })

      // 左右布局：左侧作业列表，右侧学生作业详情
      Row({ space: 8 }) {
        // 左侧：竖向作业列表（美化版）
        Column() {
          Text('作业列表')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .width('100%')
            .padding({ left: 8, top: 10, bottom: 8 })

          List({ space: 6 }) {
            ForEach(this.assignments, (assignment: Assignment, index: number) => {
              ListItem() {
                Column({ space: 3 }) {
                  Text(assignment.assignmentName)
                    .fontSize(12)
                    .fontWeight(this.selectedAssignment.assignmentId === assignment.assignmentId ? FontWeight.Medium : FontWeight.Normal)
                    .fontColor(this.selectedAssignment.assignmentId === assignment.assignmentId ? '#1890FF' : '#333333')
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })

                  Text(`${assignment.assignmentId}`)
                    .fontSize(10)
                    .fontColor('#AAAAAA')
                }
                .width('100%')
                .padding(8)
                .backgroundColor(this.selectedAssignment.assignmentId === assignment.assignmentId ? '#E6F7FF' : '#FFFFFF')
                .borderRadius(6)
                .border({
                  width: this.selectedAssignment.assignmentId === assignment.assignmentId ? 2 : 0.5,
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
        .borderRadius(8)
        .padding(6)

        // 右侧：学生作业列表
        Stack() {
          Column() {
            Row() {
              Text('学生作业列表')
                .fontSize(17)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')

              Blank()

              Text(`共 ${this.submissions.length} 人`)
                .fontSize(14)
                .fontColor('#999999')
            }
            .width('100%')
            .padding({ left: 20, right: 20, top: 16, bottom: 12 })

            List({ space: 10 }) {
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
            .padding({ left: 20, right: 20, bottom: 16 })
            .divider({ strokeWidth: 0 })
          }
          .layoutWeight(1)
          .height('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(12)

          // 批量处理按钮（右下角浮动）
          if (this.selectedSubmissionIds.length > 0) {
            Row() {
              Button(`批量处理 (${this.selectedSubmissionIds.length})`)
                .type(ButtonType.Capsule)
                .backgroundColor('#1890FF')
                .fontColor('#FFFFFF')
                .fontSize(16)
                .padding({ left: 28, right: 28, top: 14, bottom: 14 })
                .shadow({ radius: 16, color: '#40000000', offsetX: 0, offsetY: 6 })
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
            .padding({ right: 28, bottom: 28 })
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