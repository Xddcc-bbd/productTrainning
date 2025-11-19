// entry/src/main/ets/pages/DetailedGradingPage.ets

import { Submission } from '../model/Submission';
import { Grade } from '../model/Grade';
import { gradingService } from '../service/GradingService';

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
  
  startRecording() {
    this.isRecording = true;
    this.recordTime = 0;
    // 模拟录音计时
    this.timerId = setInterval(() => {
      this.recordTime++;
    }, 1000);
  }
  
  stopRecording() {
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
  @State submission: Submission = (() => {
    const s = new Submission();
    s.submissionId = 1;
    s.assignmentId = 1;
    s.studentId = 'S001';
    s.studentName = '张三';
    s.contentUrl = 'https://example.com/submission1';
    s.submissionTime = '2024-01-15 10:30:00';
    s.status = 'submitted';
    s.isLate = false;
    s.createdTime = '2024-01-15 10:30:00';
    return s;
  })();
  
  @State grade: Grade = (() => {
    const g = new Grade();
    g.gradeId = 1;
    g.submissionId = 1;
    g.teacherId = 'T001';
    g.score = 0;
    g.aiScore = 92;
    g.finalScore = 0;
    g.textComment = '';
    g.aiTextComment = '语法正确，结构合理';
    g.voiceCommentUrl = '';
    g.isTeacherRecommended = false;
    g.gradingTime = '';
    g.createdTime = '';
    return g;
  })();
  
  @State teacherScore: number = 0;
  @State maxScore: number = 100;
  @State showAIComment: boolean = true;
  
  aboutToAppear() {
    // 初始化时可以加载实际数据
    console.log('加载作业详情和AI评分建议');
  }
  
  async saveGrade() {
    try {
      // 同步分数
      this.grade.score = this.teacherScore;
      // 保存评分
      const result = await gradingService.submitGrade(this.grade);
      if (result) {
        console.log('评分保存成功');
        // 返回上一页或提示成功
      }
    } catch (error) {
      console.error('评分保存失败:', error);
    }
  }
  
  async toggleRecommendation() {
    try {
      let result: boolean;
      if (this.grade.isTeacherRecommended) {
        result = await gradingService.unmarkAsRecommended(this.submission.submissionId);
      } else {
        result = await gradingService.markAsRecommended(this.submission.submissionId);
      }
      
      if (result) {
        this.grade.isTeacherRecommended = !this.grade.isTeacherRecommended;
        console.log('推荐状态更新成功');
      }
    } catch (error) {
      console.error('更新推荐状态失败:', error);
    }
  }
  
  build() {
    Column() {
      // 顶部导航
      Row() {
        Button('←')
          .type(ButtonType.Normal)
          .width(40)
          .height(40)
          .onClick(() => {
            // 返回上一页
            console.log('返回上一页');
          })
        
        Text(`评分 - ${this.submission.studentName}`)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Button('保存')
          .type(ButtonType.Normal)
          .onClick(() => {
            this.saveGrade();
          })
      }
      .padding({ left: 16, right: 16, top: 16, bottom: 16 })
      
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
        
        Toggle({ type: ToggleType.Switch, isOn: this.grade.isTeacherRecommended })
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
                }
                .width('100%')
                
                Text(this.grade.aiTextComment)
                  .fontSize(14)
                  .backgroundColor('#F0F8FF')
                  .padding(12)
                  .borderRadius(4)
                  .margin({ top: 8 })
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