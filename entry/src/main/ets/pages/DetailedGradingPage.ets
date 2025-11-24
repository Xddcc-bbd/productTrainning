// entry/src/main/ets/pages/DetailedGradingPage.ets

import { Submission } from '../model/Submission';
import { Grade } from '../model/Grade';
import { gradingService } from '../service/GradingService';
import { assignmentService } from '../service/AssignmentService';
import { HttpService } from '../common/HttpService';
import router from '@ohos.router';

// 定义后端返回的数据结构
interface SubmissionInfo {
  submissionId: string;
  assignmentId: string;
  studentId: string;
  studentName: string;
  teamId?: string;
  contentUrl: string;
  contributionRate: number;
  submissionTime: string;
  status: string;
  actualDuration: number;
  isLate: boolean;
  likeCount: number;
  favoriteCount: number;
  createdTime: string;
  score?: number;
}

interface GradeInfo {
  gradeId: string;
  submissionId: string;
  teacherId: string;
  score: number;
  aiScore: number;
  finalScore: number;
  textComment: string;
  aiTextComment: string;
  voiceCommentUrl: string;
  isTeacherRecommended: number;
  gradingTime: string;
  createdTime: string;
}

interface SubmissionDetailDTO {
  submissionInfo: SubmissionInfo;
  gradeInfo?: GradeInfo;
}

@Component
struct ScoreInput {
  @Link score: number;
  @Prop maxScore: number = 100;

  build() {
    Row() {
      Button('-')
        .type(ButtonType.Normal)
        .width(40)
        .height(40)
        .onClick(() => {
          if (this.score > 0) {
            this.score--;
          }
        })

      TextInput({ placeholder: '输入分数', text: this.score.toString() })
        .type(InputType.Number)
        .textAlign(TextAlign.Center)
        .layoutWeight(1)
        .onChange((value: string) => {
          const numValue = parseInt(value);
          if (!isNaN(numValue) && numValue >= 0 && numValue <= this.maxScore) {
            this.score = numValue;
          }
        })

      Button('+')
        .type(ButtonType.Normal)
        .width(40)
        .height(40)
        .onClick(() => {
          if (this.score < this.maxScore) {
            this.score++;
          }
        })
    }
  }
}

@Component
struct VoiceCommentRecorder {
  @State isRecording: boolean = false;
  @State recordTime: number = 0;
  @State timerId: number = -1;

  startRecording(): void {
    this.isRecording = true;
    this.recordTime = 0;
    // 模拟录音计时
    this.timerId = setInterval(() => {
      this.recordTime++;
    }, 1000) as number;
  }

  stopRecording(): void {
    this.isRecording = false;
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  build() {
    Column() {
      // 条件渲染录音状态
      if (this.isRecording) {
        Row() {
          Button('⏹️')
            .type(ButtonType.Normal)
            .width(50)
            .height(50)
            .onClick(() => {
              this.stopRecording();
            })

          Text(this.formatTime(this.recordTime))
            .fontSize(16)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
        }
      } else {
        Button('⏺️ 录制语音评语')
          .type(ButtonType.Normal)
          .width(150)
          .height(50)
          .onClick(() => {
            this.startRecording();
          })
      }
    }
  }

  formatTime(seconds: number): string {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }
}

@Entry
@Component
struct DetailedGradingPage {
  @State submission: Submission = new Submission();
  @State grade: Grade = new Grade();
  @State teacherScore: number = 0;
  @State maxScore: number = 100;
  @State showAIComment: boolean = true;
  @State isLoading: boolean = false;
  @State errorMessage: string = '';

  // 从路由参数获取
  private submissionId: string = '';

  aboutToAppear(): void {
    // 获取路由参数
    const params = router.getParams() as Record<string, Object>;
    if (params && params['submissionId']) {
      this.submissionId = params['submissionId'] as string;
      console.log('获取到提交ID:', this.submissionId);

      // 从路由参数中获取已有的评分
      if (params['score'] !== undefined && params['score'] !== null) {
        const score = params['score'] as number;
        this.teacherScore = score;
        console.log('获取到已有评分:', score);
      }

      this.loadGradeDetail();
    } else {
      console.warn('⚠️ 未提供提交ID，使用默认数据');
      // 使用默认数据供测试
      this.loadDefaultData();
    }
  }

  // 加载评分详情
  async loadGradeDetail(): Promise<void> {
    try {
      this.isLoading = true;
      console.log(`开始加载提交 ${this.submissionId} 的评分详情...`);

      // 获取提交详情 - 从路由参数中获取
      const params = router.getParams() as Record<string, Object>;
      if (params) {
        console.log('📦 路由参数:', JSON.stringify(params));

        // 从路由参数中构建submission对象
        const submission = new Submission();
        submission.submissionId = (params['submissionId'] as string) || '';
        submission.assignmentId = (params['assignmentId'] as string) || '';
        submission.studentId = (params['studentId'] as string) || '';
        submission.studentName = (params['studentName'] as string) || '';
        submission.contentUrl = (params['contentUrl'] as string) || '';
        submission.submissionTime = (params['submissionTime'] as string) || '';
        submission.status = (params['status'] as string) || 'submitted';
        // ⭐ 关键：获取路由参数中的score
        if (params['score'] !== undefined && params['score'] !== null) {
          submission.score = params['score'] as number;
          console.log('✅ 从路由参数获取到评分:', submission.score);
        }

        this.submission = submission;
        console.log('✅ 学生提交信息加载成功');
        console.log('学生姓名:', this.submission.studentName);
        console.log('学号:', this.submission.studentId);
        console.log('提交时间:', this.submission.submissionTime);
      }

      // ⭐ 从后端获取提交和评分信息
      const assignmentId = this.submission.assignmentId;
      if (assignmentId) {
        console.log(`📡 从后端获取作业 ${assignmentId} 的提交列表...`);

        // 使用 gradingService 的方法获取数据
        const submissions = await gradingService.getSubmissions(assignmentId);

        // 找到当前提交
        const currentSubmission = submissions.find(s => s.submissionId === this.submissionId);
        if (currentSubmission) {
          console.log('✅ 找到当前提交');
          console.log('  学生:', currentSubmission.studentName);
          console.log('  评分:', currentSubmission.score);

          // 更新提交信息
          this.submission = currentSubmission;

          // 设置教师评分
          if (currentSubmission.score !== undefined && currentSubmission.score !== null) {
            this.teacherScore = currentSubmission.score;
            this.grade.finalScore = currentSubmission.score;
            this.grade.score = currentSubmission.score;
            console.log('✅ 设置教师评分:', this.teacherScore);
          } else {
            console.log('⚠️ 该作业尚未评分');
            this.teacherScore = 0;
          }
        }

        // 尝试获取详细的评分信息（包括AI评分）
        try {
          const http = HttpService.getInstance();
          const detailResponse = await http.get<SubmissionDetailDTO[]>(
            `/api/v1/grading/assignment/${assignmentId}/submissions`
          );

          console.log('📦 获取到详细数据:', JSON.stringify(detailResponse));

          if (detailResponse && Array.isArray(detailResponse)) {
            // 修复：使用类型安全的属性访问
            const detail = detailResponse.find((item: SubmissionDetailDTO) =>
            item.submissionInfo && item.submissionInfo.submissionId === this.submissionId
            );

            // 修复：使用类型安全的属性访问
            if (detail && detail.gradeInfo) {
              const gradeInfo = detail.gradeInfo;
              console.log('🎯 找到gradeInfo:', JSON.stringify(gradeInfo));

              // 设置AI评分和评语
              if (gradeInfo.aiScore) {
                this.grade.aiScore = gradeInfo.aiScore;
                console.log('✅ 设置AI评分:', this.grade.aiScore);
              }

              if (gradeInfo.aiTextComment) {
                this.grade.aiTextComment = gradeInfo.aiTextComment;
                console.log('✅ 设置AI评语:', this.grade.aiTextComment);
              }

              // 设置文字评语
              if (gradeInfo.textComment) {
                this.grade.textComment = gradeInfo.textComment;
                console.log('✅ 设置文字评语:', this.grade.textComment);
              }

              // 设置其他信息
              this.grade.gradeId = gradeInfo.gradeId;
              this.grade.teacherId = gradeInfo.teacherId;
              // ⭐ 确保 isTeacherRecommended 是 number 类型（0 或 1）
              this.grade.isTeacherRecommended = gradeInfo.isTeacherRecommended ? 1 : 0;
              console.log('✅ 设置推荐状态:', this.grade.isTeacherRecommended);
            } else {
              console.log('⚠️ 未找到gradeInfo');
            }
          }
        } catch (detailError) {
          console.log('⚠️ 获取详细评分信息失败（不影响基本功能）:', detailError);
        }
      }

      // 设置 grade 对象的基本信息（如果还没有）
      if (!this.grade.submissionId) {
        this.grade.submissionId = this.submissionId;
      }
      if (!this.grade.teacherId) {
        this.grade.teacherId = 'teacher_zhao';
      }

    } catch (error) {
      console.error('❌ 加载评分详情失败:', error);
      this.errorMessage = `加载失败: ${error}`;
    } finally {
      this.isLoading = false;
    }
  }

  // 加载默认数据（用于测试）
  loadDefaultData(): void {
    this.submission = (() => {
      const s = new Submission();
      s.submissionId = 'sub_01';
      s.assignmentId = 'assign_01';
      s.studentId = 'S001';
      s.studentName = '张三';
      s.contentUrl = 'https://example.com/submission1';
      s.submissionTime = '2024-01-15 10:30:00';
      s.status = 'submitted';
      s.isLate = 0;
      s.createdTime = '2024-01-15 10:30:00';
      return s;
    })();

    this.grade = (() => {
      const g = new Grade();
      g.gradeId = 'grade_01';
      g.submissionId = 'sub_01';
      g.teacherId = 'T001';
      g.score = 0;
      g.aiScore = 92;
      g.finalScore = 0;
      g.textComment = '';
      g.aiTextComment = '语法正确，结构合理';
      g.voiceCommentUrl = '';
      g.isTeacherRecommended = 0;
      g.gradingTime = '';
      g.createdTime = '';
      return g;
    })();
  }

  async saveGrade(): Promise<boolean> {
    try {
      console.log('💾 开始保存评分...');
      console.log('  submissionId:', this.submission.submissionId || this.grade.submissionId);
      console.log('  teacherScore:', this.teacherScore);

      // 确保设置正确的teacherId
      this.grade.teacherId = 'teacher_zhao';
      this.grade.submissionId = this.submission.submissionId || this.grade.submissionId;
      this.grade.score = this.teacherScore;
      this.grade.finalScore = this.teacherScore;

      console.log('📦 发送评分数据:', {
        submissionId: this.grade.submissionId,
        teacherId: this.grade.teacherId,
        score: this.grade.score,
        finalScore: this.grade.finalScore,
        textComment: this.grade.textComment
      });

      const result = await gradingService.submitGrade(this.grade);
      if (result) {
        console.log('✅ 评分保存成功');
        return true;
      } else {
        console.error('❌ 评分保存失败：后端返回 null');
        return false;
      }
    } catch (error) {
      console.error('❌ 评分保存失败:', error);
      this.errorMessage = `保存失败: ${error}`;
      return false;
    }
  }

  async toggleRecommendation(): Promise<void> {
    try {
      const newStatus = this.grade.isTeacherRecommended === 1 ? 0 : 1;
      console.log('🔄 切换推荐状态:', this.grade.isTeacherRecommended, '->', newStatus);

      const result = await gradingService.markAsRecommended(
        this.submission.submissionId,
        newStatus === 1
      );

      if (result) {
        // 更新本地状态
        this.grade.isTeacherRecommended = newStatus;
        console.log('✅ 推荐状态更新成功:', newStatus);

        // ⭐ 同时保存到数据库（更新 grades 表）
        this.grade.submissionId = this.submission.submissionId;
        this.grade.teacherId = 'teacher_zhao';
        this.grade.finalScore = this.teacherScore;
        await gradingService.submitGrade(this.grade);
        console.log('✅ 推荐状态已保存到数据库');
      }
    } catch (error) {
      console.error('❌ 更新推荐状态失败:', error);
    }
  }

  build() {
    Column() {
      // 顶部导航
      Row() {
        Row() {
          Text('←')
            .fontSize(24)
            .fontColor('#333333')
        }
        .width(40)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          router.back();
          console.log('返回上一页');
        })

        Text(`评分 - ${this.submission.studentName}`)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Button('保存')
          .type(ButtonType.Capsule)
          .backgroundColor('#1890FF')
          .fontColor('#FFFFFF')
          .fontSize(14)
          .padding({ left: 16, right: 16 })
          .onClick(async () => {
            const success = await this.saveGrade();
            if (success) {
              // 在onClick中调用router.back()，保持UI上下文
              router.back();
            }
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor('#FFFFFF')
      .shadow({ radius: 4, color: '#10000000', offsetX: 0, offsetY: 2 })

      // 学生信息和作业信息
      Row() {
        Column() {
          Text(this.submission.studentName)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)

          Text('提交时间: ' + this.submission.submissionTime)
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 4 })
        }
        .layoutWeight(1)

        Toggle({ type: ToggleType.Switch, isOn: this.grade.isTeacherRecommended === 1 })
          .onChange((isOn: boolean) => {
            this.toggleRecommendation();
          })

        Text('推荐作品')
          .fontSize(14)
          .margin({ left: 8 })
      }
      .padding({ left: 16, right: 16 })

      Divider()
        .color('#EEEEEE')
        .strokeWidth(1)
        .margin({ top: 12, bottom: 12 })

      // 积木作品展示区域（模拟）
      Column() {
        Text('积木作品展示区域')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)

        Row() {
          Blank()
          Image($r('app.media.layered_image'))
            .width(200)
            .height(200)
            .margin({ top: 16, bottom: 16 })
          Blank()
        }

        Text('此处显示学生提交的积木作品')
          .fontSize(12)
          .fontColor('#999999')
      }
      .padding({ top: 16, bottom: 16 })
      .backgroundColor('#F5F5F5')
      .borderRadius(8)
      .margin({ left: 16, right: 16 })

      // 评分区域
      Scroll() {
        Column() {
          // AI评分建议
          Column() {
            Row() {
              Text('AI评分建议')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .layoutWeight(1)

              Checkbox({ name: 'showAI' })
                .select(this.showAIComment)
                .onChange((value: boolean) => {
                  this.showAIComment = value;
                })

              Text('显示')
                .fontSize(14)
                .margin({ left: 4 })
            }

            // 条件渲染AI评语
            if (this.showAIComment) {
              Column() {
                Row() {
                  Text('AI评分:')
                    .fontSize(14)
                    .fontColor('#999999')

                  Text(this.grade.aiScore.toString())
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#1890FF')
                    .margin({ left: 8 })

                  Blank()

                  // ⭐ 采用AI评分按钮
                  Button('采用')
                    .type(ButtonType.Normal)
                    .fontSize(12)
                    .padding({ left: 12, right: 12, top: 4, bottom: 4 })
                    .backgroundColor('#E6F7FF')
                    .fontColor('#1890FF')
                    .borderRadius(4)
                    .onClick(() => {
                      this.teacherScore = this.grade.aiScore;
                      console.log('✅ 采用AI评分:', this.grade.aiScore);
                    })
                }
                .width('100%')

                // ⭐ 只在有AI评语时显示灰色框框
                if (this.grade.aiTextComment && this.grade.aiTextComment.length > 0) {
                  Column() {
                    Text(this.grade.aiTextComment)
                      .fontSize(14)
                      .fontColor('#333333')
                      .width('100%')

                    // ⭐ 采用AI评语按钮
                    Row() {
                      Blank()
                      Button('采用此评语')
                        .type(ButtonType.Normal)
                        .fontSize(12)
                        .padding({ left: 12, right: 12, top: 4, bottom: 4 })
                        .backgroundColor('#1890FF')
                        .fontColor('#FFFFFF')
                        .borderRadius(4)
                        .margin({ top: 8 })
                        .onClick(() => {
                          this.grade.textComment = this.grade.aiTextComment;
                          console.log('✅ 采用AI评语:', this.grade.aiTextComment);
                        })
                    }
                    .width('100%')
                  }
                  .backgroundColor('#F0F8FF')
                  .padding(12)
                  .borderRadius(4)
                  .margin({ top: 8 })
                  .width('100%')
                }
              }
              .padding(12)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .margin({ top: 8 })
            }
          }
          .padding({ left: 16, right: 16 })

          // 教师评分
          Column() {
            Text('教师评分')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .width('100%')
              .margin({ top: 16 })

            ScoreInput({ score: $teacherScore, maxScore: this.maxScore })
              .margin({ top: 12 })

            Text('满分: ' + this.maxScore)
              .fontSize(12)
              .fontColor('#999999')
              .margin({ top: 4 })
          }
          .padding({ left: 16, right: 16 })

          // 文字评语
          Column() {
            Text('文字评语')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .width('100%')
              .margin({ top: 16 })

            TextArea({ placeholder: '请输入评语...', text: this.grade.textComment })
              .onChange((value: string) => {
                this.grade.textComment = value;
              })
              .width('100%')
              .height(100)
              .margin({ top: 8 })
          }
          .padding({ left: 16, right: 16 })

          // 语音评语
          Column() {
            Text('语音评语')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .width('100%')
              .margin({ top: 16 })

            VoiceCommentRecorder()
              .margin({ top: 8 })
          }
          .padding({ left: 16, right: 16 })

          // 最终得分预览
          Column() {
            Text('最终得分预览')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .width('100%')
              .margin({ top: 16 })

            Row() {
              Text('AI评分:')
                .fontSize(14)
                .fontColor('#999999')
                .layoutWeight(1)

              Text(this.grade.aiScore.toString())
                .fontSize(14)
            }
            .width('100%')
            .margin({ top: 8 })

            Row() {
              Text('教师评分:')
                .fontSize(14)
                .fontColor('#999999')
                .layoutWeight(1)

              Text(this.teacherScore > 0 ? this.teacherScore.toString() : '未评分')
                .fontSize(14)
            }
            .width('100%')
            .margin({ top: 4 })

            Divider()
              .color('#EEEEEE')
              .strokeWidth(1)
              .margin({ top: 8, bottom: 8 })

            Row() {
              Text('最终得分:')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .layoutWeight(1)

              Text(this.grade.displayScore.toString())
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1890FF')
            }
            .width('100%')
          }
          .padding({ left: 16, right: 16, top: 16, bottom: 16 })
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .margin({ left: 16, right: 16, top: 16 })
        }
      }
      .layoutWeight(1)
    }
  }
}