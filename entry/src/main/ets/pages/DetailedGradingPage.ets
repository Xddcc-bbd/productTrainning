// entry/src/main/ets/pages/DetailedGradingPage.ets

import { Submission } from '../model/Submission';
import { Grade } from '../model/Grade';
// 【修复1】加上大括号，因为报错提示没有 default export
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

// 定义路由参数接口
interface RouterParams {
  submissionId?: string;
  assignmentId?: string;
  studentId?: string;
  studentName?: string;
  contentUrl?: string;
  submissionTime?: string;
  status?: string;
  score?: number;
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
  @State isToggleProcessing: boolean = false; // 防止重复点击

  // 从路由参数获取
  private submissionId: string = '';

  aboutToAppear(): void {
    // 获取路由参数 - 使用明确的类型
    const params: RouterParams = router.getParams() as RouterParams;
    if (params && params.submissionId) {
      this.submissionId = params.submissionId;
      console.log('获取到提交ID:', this.submissionId);

      // 从路由参数中获取已有的评分
      if (params.score !== undefined && params.score !== null) {
        const score: number = params.score;
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

      // 获取提交详情
      const params: RouterParams = router.getParams() as RouterParams;
      if (params) {
        const submission = new Submission();
        submission.submissionId = params.submissionId || '';
        submission.assignmentId = params.assignmentId || '';
        submission.studentId = params.studentId || '';
        submission.studentName = params.studentName || '';
        submission.contentUrl = params.contentUrl || '';
        submission.submissionTime = params.submissionTime || '';
        submission.status = params.status || 'submitted';
        if (params.score !== undefined && params.score !== null) {
          submission.score = params.score;
        }
        this.submission = submission;
      }

      const assignmentId: string = this.submission.assignmentId;
      if (assignmentId) {
        // 使用 gradingService 的方法获取数据
        const submissions: Submission[] = await gradingService.getSubmissions(assignmentId);

        // 找到当前提交
        const currentSubmission: Submission | undefined = submissions.find(s => s.submissionId === this.submissionId);
        if (currentSubmission) {
          this.submission = currentSubmission;
          if (currentSubmission.score !== undefined && currentSubmission.score !== null) {
            this.teacherScore = currentSubmission.score;
            this.grade.finalScore = currentSubmission.score;
            this.grade.score = currentSubmission.score;
          } else {
            this.teacherScore = 0;
          }
        }

        // 尝试获取详细的评分信息（包括AI评分）
        try {
          const http: HttpService = HttpService.getInstance();
          const detailResponse: SubmissionDetailDTO[] = await http.get<SubmissionDetailDTO[]>(
            `/api/v1/grading/assignment/${assignmentId}/submissions`
          );

          if (detailResponse && Array.isArray(detailResponse)) {
            const detail: SubmissionDetailDTO | undefined = detailResponse.find((item: SubmissionDetailDTO) =>
            item.submissionInfo && item.submissionInfo.submissionId === this.submissionId
            );

            if (detail && detail.gradeInfo) {
              const gradeInfo: GradeInfo = detail.gradeInfo;

              if (gradeInfo.aiScore) this.grade.aiScore = gradeInfo.aiScore;
              if (gradeInfo.aiTextComment) this.grade.aiTextComment = gradeInfo.aiTextComment;
              if (gradeInfo.textComment) this.grade.textComment = gradeInfo.textComment;

              this.grade.gradeId = gradeInfo.gradeId;
              this.grade.teacherId = gradeInfo.teacherId;
              
              // ⭐ 简单转换：确保 isTeacherRecommended 是 0 或 1
              const rawValue: number | boolean | string | undefined = gradeInfo.isTeacherRecommended as number | boolean | string | undefined;
              this.grade.isTeacherRecommended = (rawValue === true || Number(rawValue) === 1) ? 1 : 0;
              
              console.log('✅ 加载成功，推荐状态:', this.grade.isTeacherRecommended);
            } else {
              this.grade.isTeacherRecommended = 0;
            }
          }
          // 【修复2】catch去掉类型注解
        } catch (detailError) {
          console.log('⚠️ 获取详细评分信息失败（不影响基本功能）');
          this.grade.isTeacherRecommended = 0;
        }
      }

      // 设置 grade 对象的基本信息
      if (!this.grade.submissionId) {
        this.grade.submissionId = this.submissionId;
      }
      if (!this.grade.teacherId) {
        this.grade.teacherId = 'teacher_zhao';
      }

      // 【修复3】catch去掉类型注解
    } catch (error) {
      const err = error as Error;
      console.error('❌ 加载评分详情失败:', err);
      this.errorMessage = `加载失败: ${err.message}`;
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
      this.grade.teacherId = 'teacher_zhao';
      this.grade.submissionId = this.submission.submissionId || this.grade.submissionId;
      this.grade.score = this.teacherScore;
      this.grade.finalScore = this.teacherScore;

      const result: Grade | null = await gradingService.submitGrade(this.grade);
      if (result) {
        console.log('✅ 评分保存成功');
        return true;
      } else {
        console.error('❌ 评分保存失败：后端返回 null');
        return false;
      }
      // 【修复4】catch去掉类型注解
    } catch (error) {
      const err = error as Error;
      console.error('❌ 评分保存失败:', err);
      this.errorMessage = `保存失败: ${err.message}`;
      return false;
    }
  }

  // 【修复5】重构的推荐切换逻辑：接收目标状态 isOn，解决开关乱跳问题
  async toggleRecommendation(targetIsOn: boolean): Promise<void> {
    // 1. 如果正在处理中，不重复执行
    if (this.isToggleProcessing) {
      return;
    }

    // 记录旧状态（0 或 1），用于失败回滚
    const originalStatus = this.grade.isTeacherRecommended;

    // 目标状态：true -> 1, false -> 0
    const targetStatus = targetIsOn ? 1 : 0;

    try {
      this.isToggleProcessing = true;

      // 2. 乐观更新：先更新UI，让用户看到开关立马切换成功
      this.grade.isTeacherRecommended = targetStatus;
      console.log(`🔄 切换推荐状态: ${originalStatus} -> ${targetStatus}`);

      // 3. 调用 API
      const result: boolean = await gradingService.markAsRecommended(
        this.submission.submissionId,
        targetIsOn // 传递 boolean 值
      );

      if (result) {
        console.log('✅ 推荐状态同步成功');
        // 如果有分数，顺便同步一下 Grade 表的其他字段
        if (this.teacherScore > 0) {
          this.grade.score = this.teacherScore;
          await gradingService.submitGrade(this.grade);
        }
      } else {
        // 只有明确返回 false 时才抛出异常去回滚
        throw new Error('API 返回 false');
      }

    } catch (error) {
      const err = error as Error;
      console.error('❌ 更新推荐状态失败，正在回滚UI:', err);

      // 4. 失败回滚：把状态改回原来的值
      this.grade.isTeacherRecommended = originalStatus;

      // 提示用户
      this.errorMessage = '网络异常，推荐状态更新失败';
    } finally {
      // 5. 稍微延迟一点释放锁，避免快速点击造成的UI抖动
      setTimeout(() => {
        this.isToggleProcessing = false;
      }, 300);
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
            const success: boolean = await this.saveGrade();
            if (success) {
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

        // 推荐开关（简单版）
        Row() {
          Toggle({ type: ToggleType.Switch, isOn: this.grade.isTeacherRecommended === 1 })
            .onChange((isOn: boolean) => {
              this.toggleRecommendation(isOn);
            })
            .enabled(!this.isToggleProcessing)

          Text('推荐作品')
            .fontSize(14)
            .margin({ left: 8 })
        }
        .alignItems(VerticalAlign.Center)
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

                  Button('采用')
                    .type(ButtonType.Normal)
                    .fontSize(12)
                    .padding({ left: 12, right: 12, top: 4, bottom: 4 })
                    .backgroundColor('#E6F7FF')
                    .fontColor('#1890FF')
                    .borderRadius(4)
                    .onClick(() => {
                      this.teacherScore = this.grade.aiScore;
                    })
                }
                .width('100%')

                if (this.grade.aiTextComment && this.grade.aiTextComment.length > 0) {
                  Column() {
                    Text(this.grade.aiTextComment)
                      .fontSize(14)
                      .fontColor('#333333')
                      .width('100%')

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