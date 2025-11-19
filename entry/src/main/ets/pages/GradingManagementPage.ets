// entry/src/main/ets/pages/GradingManagementPage.ets

import { Assignment } from '../model/Assignment';
import { Submission } from '../model/Submission';
import { Grade } from '../model/Grade';
import { assignmentService } from '../service/AssignmentService';
import { gradingService } from '../service/GradingService';
import { studentService } from '../service/StudentService';

@Component
struct SubmissionItem {
  @Prop submission: Submission;
  @Prop grade: Grade;

  build() {
    Row() {
      Column() {
        Row() {
          Text(this.submission.studentName)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
          
          Blank()
          
          Text(this.submission.statusText)
            .fontSize(12)
            .backgroundColor(this.submission.statusColor)
            .padding({ left: 8, right: 8 })
            .borderRadius(4)
            .fontColor(Color.White)
        }
        .width('100%')
        
        Row() {
          Text('提交时间: ' + this.submission.submissionTime)
            .fontSize(12)
            .fontColor('#999999')
          
          Blank()
          
          // 条件渲染得分
          if (this.grade.displayScore > 0) {
            Text('得分: ' + this.grade.displayScore)
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1890FF')
          } else {
            Text('未评分')
              .fontSize(12)
              .fontColor('#999999')
          }
        }
        .width('100%')
        .margin({ top: 4 })
      }
      .layoutWeight(1)
    }
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .onClick(() => {
      // 跳转到详细评分页面
      console.log('点击学生作业:', this.submission);
    })
  }
}

@Entry
@Component
struct GradingManagementPage {
  @State assignments: Assignment[] = [];
  @State selectedAssignment: Assignment = new Assignment();
  @State submissions: Submission[] = [];
  @State grades: Grade[] = [];
  
  aboutToAppear() {
    this.loadAssignments();
  }
  
  async loadAssignments() {
    try {
      this.assignments = await assignmentService.getCourseAssignments(1);
      if (this.assignments.length > 0) {
        this.selectedAssignment = this.assignments[0];
        this.loadSubmissions(this.selectedAssignment.assignmentId);
      }
    } catch (error) {
      console.error('加载作业列表失败:', error);
    }
  }
  
  async loadSubmissions(assignmentId: number) {
    try {
      this.submissions = await gradingService.getSubmissions(assignmentId);
      // 加载评分信息
      this.loadGrades();
    } catch (error) {
      console.error('加载提交列表失败:', error);
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
  
  getGradeBySubmissionId(submissionId: number): Grade {
    const grade = this.grades.find(g => g.submissionId === submissionId);
    return grade || new Grade();
  }
  
  build() {
    Column() {
      // 顶部标题
      Row() {
        Text('作业批改')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Button('推荐学生')
          .type(ButtonType.Normal)
          .fontSize(14)
          .onClick(() => {
            // 跳转到推荐学生页面
            console.log('跳转到推荐学生页面');
          })
      }
      .padding({ left: 16, right: 16, top: 16, bottom: 16 })
      
      // 作业选择
      Scroll() {
        Row() {
          ForEach(this.assignments, (assignment: Assignment, index: number) => {
            Button(assignment.assignmentName)
              .type(this.selectedAssignment.assignmentId === assignment.assignmentId ? ButtonType.Capsule : ButtonType.Normal)
              .backgroundColor(this.selectedAssignment.assignmentId === assignment.assignmentId ? '#1890FF' : '#F5F5F5')
              .fontColor(this.selectedAssignment.assignmentId === assignment.assignmentId ? '#FFFFFF' : '#333333')
              .onClick(() => {
                this.selectedAssignment = assignment;
                this.loadSubmissions(assignment.assignmentId);
              })
              .margin({ right: 8 })
          }, (item: Assignment, index: number) => {
            return item.assignmentId.toString();
          })
        }
      }
      .layoutWeight(1)
      
      // 统计信息
      Row() {
        Column() {
          Text(this.submissions.length.toString())
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
          Text('总提交')
            .fontSize(12)
            .fontColor('#999999')
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        
        Column() {
          Text(this.grades.filter(g => g.displayScore > 0).length.toString())
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
          Text('已评分')
            .fontSize(12)
            .fontColor('#999999')
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        
        Column() {
          Text(this.grades.filter(g => g.isTeacherRecommended).length.toString())
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
          Text('推荐作品')
            .fontSize(12)
            .fontColor('#999999')
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor('#F5F5F5')
      .borderRadius(8)
      .margin({ left: 16, right: 16 })
      
      // 学生作业列表
      List() {
        ForEach(this.submissions, (submission: Submission, index: number) => {
          ListItem() {
            Column() {
              SubmissionItem({
                submission: submission,
                grade: this.getGradeBySubmissionId(submission.submissionId)
              })
              
              Divider()
                .color('#EEEEEE')
                .strokeWidth(1)
            }
          }
        }, (item: Submission, index: number) => {
          return item.submissionId.toString();
        })
      }
      .layoutWeight(1)
      .divider({ strokeWidth: 0 })
    }
    .padding({ bottom: 16 })
  }
}